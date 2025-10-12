from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from typing import Optional, List
from pydantic import BaseModel, EmailStr
import time
import os

from app.utils.image_processing import save_upload_file, validate_image
from app.models.user import UserCreate
from app.models.face import FaceEmbeddingCreate

router = APIRouter()

# Response Models
class RegistrationResponse(BaseModel):
    user_id: str
    faiss_index_id: int
    face_detected: bool
    quality_score: float
    image_url: Optional[str] = None

class RecognitionResponse(BaseModel):
    matched: bool
    user_id: Optional[str] = None
    name: Optional[str] = None
    confidence: float
    processing_time_ms: int
    alternatives: Optional[List[dict]] = None

class ApiResponse(BaseModel):
    success: bool
    message: str
    data: Optional[dict] = None

@router.post("/register")
async def register_face(
    image: UploadFile = File(...),
    name: str = Form(...),
    email: EmailStr = Form(...),
    phone: Optional[str] = Form(None),
    notes: Optional[str] = Form(None),
):
    """Register a new face."""
    from app.main import (
        face_detection_service,
        face_recognition_service,
        vector_search_service,
        storage_service,
        settings
    )
    
    # DEBUG: Log all received data
    print("\n" + "=" * 60)
    print("🔵 NEW REGISTRATION REQUEST")
    print("=" * 60)
    print(f"📝 Name: {name}")
    print(f"📧 Email: {email}")
    print(f"📱 Phone: {phone}")
    print(f"📋 Notes: {notes}")
    print(f"🖼️  Image filename: {image.filename}")
    print(f"📦 Image content type: {image.content_type}")
    print(f"📏 Image size: {image.size if hasattr(image, 'size') else 'unknown'}")
    print("=" * 60 + "\n")
    
    start_time = time.time()
    image_path = None
    
    try:
        # Validate image
        await validate_image(image, settings.MAX_FILE_SIZE)
        
        # Save uploaded file
        image_path = await save_upload_file(image, settings.UPLOAD_DIR)
        
        # Detect face
        face_detected, face_regions, error = face_detection_service.detect_face(image_path)
        
        if not face_detected:
            # Clean up
            if os.path.exists(image_path):
                os.remove(image_path)
            raise HTTPException(status_code=400, detail=error or "No face detected")
        
        # Check if multiple faces
        if len(face_regions) > 1:
            if os.path.exists(image_path):
                os.remove(image_path)
            raise HTTPException(
                status_code=400, 
                detail=f"Multiple faces detected ({len(face_regions)}). Please provide image with single face."
            )
        
        # Calculate quality score
        quality_score = face_detection_service.calculate_quality_score(
            image_path, 
            face_regions[0]
        )
        
        # Extract embedding
        embedding = face_recognition_service.extract_embedding(image_path)
        
        if embedding is None:
            if os.path.exists(image_path):
                os.remove(image_path)
            raise HTTPException(status_code=500, detail="Failed to extract face embedding")
        
        # Check if user already exists
        existing_user = await storage_service.get_user_by_email(email)
        if existing_user:
            if os.path.exists(image_path):
                os.remove(image_path)
            raise HTTPException(
                status_code=400, 
                detail=f"User with email {email} already exists"
            )
        
        # Create user in database
        user_data = UserCreate(name=name, email=email, phone=phone)
        user = await storage_service.create_user(user_data)
        
        # Add embedding to FAISS
        faiss_id = vector_search_service.add_embedding(embedding, user.user_id)
        
        # Store embedding metadata in database
        embedding_metadata = FaceEmbeddingCreate(
            user_id=user.user_id,
            faiss_index_id=faiss_id,
            embedding_model=settings.FACE_RECOGNITION_MODEL,
            image_url=image_path,
            metadata={
                "quality_score": quality_score,
                "face_region": face_regions[0],
                "notes": notes
            }
        )
        await storage_service.create_face_embedding(embedding_metadata)
        
        processing_time = int((time.time() - start_time) * 1000)
        
        return {
            "success": True,
            "message": "Face registered successfully",
            "data": {
                "user_id": user.user_id,
                "faiss_index_id": faiss_id,
                "face_detected": True,
                "quality_score": quality_score,
                "image_url": image_path,
                "processing_time_ms": processing_time
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Registration error: {e}")
        raise HTTPException(status_code=500, detail=f"Registration failed: {str(e)}")

@router.post("/recognize")
async def recognize_face(
    image: UploadFile = File(...),
    threshold: float = Form(0.6),
    top_k: int = Form(1),
):
    """Recognize a face."""
    from app.main import (
        face_detection_service,
        face_recognition_service,
        vector_search_service,
        storage_service,
        settings
    )
    
    start_time = time.time()
    
    try:
        # Validate image
        await validate_image(image, settings.MAX_FILE_SIZE)
        
        # Save uploaded file temporarily
        image_path = await save_upload_file(image, settings.UPLOAD_DIR)
        
        # Detect face
        face_detected, face_regions, error = face_detection_service.detect_face(image_path)
        
        if not face_detected:
            # Clean up
            if os.path.exists(image_path):
                os.remove(image_path)
            return {
                "success": True,
                "message": "No face detected",
                "data": {
                    "matched": False,
                    "user_id": None,
                    "name": None,
                    "confidence": 0.0,
                    "processing_time_ms": int((time.time() - start_time) * 1000)
                }
            }
        
        # Extract embedding
        embedding = face_recognition_service.extract_embedding(image_path)
        
        # Clean up temporary file
        if os.path.exists(image_path):
            os.remove(image_path)
        
        if embedding is None:
            raise HTTPException(status_code=500, detail="Failed to extract face embedding")
        
        # Search in FAISS
        # Convert cosine distance to similarity threshold
        # For cosine distance: distance = 1 - similarity
        # So if threshold is 0.6 (60% similarity), distance threshold is 0.4
        distance_threshold = 1.0 - threshold
        
        results = vector_search_service.search(
            embedding, 
            k=top_k,
            threshold=distance_threshold
        )
        
        if not results:
            return {
                "success": True,
                "message": "No match found",
                "data": {
                    "matched": False,
                    "user_id": None,
                    "name": None,
                    "confidence": 0.0,
                    "processing_time_ms": int((time.time() - start_time) * 1000)
                }
            }
        
        # Get top match
        top_match = results[0]
        user_id, distance, faiss_id = top_match
        
        # Convert distance to confidence (similarity)
        confidence = 1.0 - distance
        
        # Get user details
        user = await storage_service.get_user_by_id(user_id)
        
        # Prepare alternatives
        alternatives = []
        for alt_user_id, alt_distance, alt_faiss_id in results[1:]:
            alt_user = await storage_service.get_user_by_id(alt_user_id)
            if alt_user:
                alternatives.append({
                    "user_id": alt_user_id,
                    "name": alt_user.name,
                    "confidence": 1.0 - alt_distance
                })
        
        processing_time = int((time.time() - start_time) * 1000)
        
        return {
            "success": True,
            "message": "Recognition completed",
            "data": {
                "matched": True,
                "user_id": user_id,
                "name": user.name if user else "Unknown",
                "confidence": confidence,
                "processing_time_ms": processing_time,
                "alternatives": alternatives if alternatives else None
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Recognition error: {e}")
        raise HTTPException(status_code=500, detail=f"Recognition failed: {str(e)}")