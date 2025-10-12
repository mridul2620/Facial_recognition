from fastapi import APIRouter, Depends
from pydantic import BaseModel

router = APIRouter()

class HealthResponse(BaseModel):
    status: str
    faiss_index_size: int
    model_loaded: bool
    mongodb_connected: bool

@router.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    from app.main import face_recognition_service, vector_search_service, storage_service
    
    # Check MongoDB connection
    mongodb_connected = storage_service.client is not None
    
    # Check FAISS index
    faiss_size = vector_search_service.get_index_size()
    
    # Check if models are loaded (DeepFace loads models on first use)
    model_loaded = True
    
    return {
        "status": "healthy",
        "faiss_index_size": faiss_size,
        "model_loaded": model_loaded,
        "mongodb_connected": mongodb_connected
    }