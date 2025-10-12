import cv2
import numpy as np
from typing import Optional, Tuple, List, Dict, Any
from deepface import DeepFace
import os

class FaceDetectionService:
    def __init__(self, backend: str = "opencv"):
        """
        Initialize face detection service.
        
        Args:
            backend: Detection backend (opencv, ssd, mtcnn, retinaface, mediapipe)
        """
        self.backend = backend
        print(f"Face Detection Service initialized with backend: {backend}")
    
    def detect_face(self, image_path: str) -> Tuple[bool, Optional[List[Dict]], Optional[str]]:
        """
        Detect face in image.
        
        Returns:
            Tuple of (face_detected, face_regions, error_message)
        """
        print(f"\n{'='*60}")
        print(f"🔍 FACE DETECTION START")
        print(f"{'='*60}")
        
        try:
            print(f"📂 Image path: {image_path}")
            
            # Check if file exists
            if not os.path.exists(image_path):
                print(f"❌ Image file not found!")
                return False, None, "Image file not found"
            
            # Check file size
            file_size = os.path.getsize(image_path)
            print(f"📦 File size: {file_size:,} bytes ({file_size / 1024:.2f} KB)")
            
            if file_size == 0:
                print(f"❌ Image file is empty")
                return False, None, "Image file is empty"
            
            # Try to read image with OpenCV first
            print(f"📖 Reading image with OpenCV...")
            test_img = cv2.imread(image_path)
            
            if test_img is None:
                print(f"❌ Cannot read image with OpenCV")
                return False, None, "Cannot read image file. File may be corrupted."
            
            print(f"✅ Image loaded. Shape: {test_img.shape}, Type: {test_img.dtype}")
            
            # Use DeepFace to detect faces
            print(f"🤖 Starting DeepFace detection with backend: {self.backend}")
            
            face_objs = DeepFace.extract_faces(
                img_path=image_path,
                detector_backend=self.backend,
                enforce_detection=False,
                align=True
            )
            
            print(f"📊 DeepFace returned: {len(face_objs) if face_objs else 0} face object(s)")
            
            if not face_objs or len(face_objs) == 0:
                print("❌ No faces detected by DeepFace")
                return False, None, "No face detected in image. Please ensure your face is clearly visible."
            
            # Extract face regions
            face_regions = []
            
            for idx, face_obj in enumerate(face_objs):
                print(f"\n   👤 Processing face #{idx + 1}")
                print(f"   📋 Face object keys: {list(face_obj.keys())}")
                
                # Get facial area
                facial_area = face_obj.get('facial_area', {})
                print(f"   📐 Facial area: {facial_area}")
                print(f"   📐 Facial area type: {type(facial_area)}")
                
                # Get confidence
                confidence = face_obj.get('confidence', 1.0)
                print(f"   💯 Confidence: {confidence}")
                
                # Extract coordinates
                if isinstance(facial_area, dict) and facial_area:
                    x = facial_area.get('x', 0)
                    y = facial_area.get('y', 0)
                    w = facial_area.get('w', 0)
                    h = facial_area.get('h', 0)
                    
                    print(f"   📏 Coordinates: x={x}, y={y}, w={w}, h={h}")
                    
                    if w > 0 and h > 0:
                        face_region = {
                            'x': int(x),
                            'y': int(y),
                            'w': int(w),
                            'h': int(h),
                            'confidence': float(confidence)
                        }
                        face_regions.append(face_region)
                        print(f"   ✅ Face region added: {face_region}")
                    else:
                        print(f"   ⚠️  Invalid dimensions (w={w}, h={h}), skipping")
                else:
                    # Try to get face array dimensions as fallback
                    print(f"   ⚠️  Facial area is not a valid dict, trying fallback...")
                    face_array = face_obj.get('face')
                    
                    if face_array is not None:
                        print(f"   📊 Face array type: {type(face_array)}")
                        if hasattr(face_array, 'shape'):
                            print(f"   📊 Face array shape: {face_array.shape}")
                            h, w = face_array.shape[:2]
                            
                            face_region = {
                                'x': 0,
                                'y': 0,
                                'w': int(w),
                                'h': int(h),
                                'confidence': float(confidence)
                            }
                            face_regions.append(face_region)
                            print(f"   ✅ Face region added (fallback): {face_region}")
                        else:
                            print(f"   ❌ Face array has no shape attribute")
                    else:
                        print(f"   ❌ No face array found")
            
            if not face_regions:
                print("\n❌ No valid face regions extracted")
                return False, None, "Face detected but could not extract face region"
            
            print(f"\n✅ Successfully detected {len(face_regions)} face(s)")
            print(f"{'='*60}\n")
            
            return True, face_regions, None
            
        except ValueError as e:
            print(f"\n❌ ValueError: {e}")
            print(f"{'='*60}\n")
            return False, None, f"Face detection error: {str(e)}"
            
        except Exception as e:
            print(f"\n❌ Exception: {type(e).__name__}: {e}")
            import traceback
            print("\n📋 Full traceback:")
            traceback.print_exc()
            print(f"{'='*60}\n")
            return False, None, f"Face detection failed: {str(e)}"
    
    def calculate_quality_score(self, image_path: str, face_region: Dict[str, Any]) -> float:
        """
        Calculate face quality score based on various factors.
        
        Returns:
            Quality score between 0 and 1
        """
        try:
            img = cv2.imread(image_path)
            
            if img is None:
                return 0.5
            
            # Extract face region
            x = face_region.get('x', 0)
            y = face_region.get('y', 0)
            w = face_region.get('w', img.shape[1])
            h = face_region.get('h', img.shape[0])
            
            # Ensure coordinates are within image bounds
            x = max(0, min(x, img.shape[1] - 1))
            y = max(0, min(y, img.shape[0] - 1))
            w = min(w, img.shape[1] - x)
            h = min(h, img.shape[0] - y)
            
            if w <= 0 or h <= 0:
                return 0.5
            
            face = img[y:y+h, x:x+w]
            
            if face.size == 0:
                return 0.5
            
            # Calculate blur score using Laplacian variance
            gray = cv2.cvtColor(face, cv2.COLOR_BGR2GRAY)
            blur_score = cv2.Laplacian(gray, cv2.CV_64F).var()
            
            # Normalize blur score (higher is better, typical range: 0-1000)
            blur_score = min(blur_score / 500, 1.0)
            
            # Calculate brightness score
            brightness = np.mean(gray)
            # Ideal brightness is around 127, penalize too dark or too bright
            brightness_score = 1.0 - abs(brightness - 127) / 127
            
            # Face size score (larger faces are generally better)
            face_size = w * h
            image_size = img.shape[0] * img.shape[1]
            size_ratio = face_size / image_size
            size_score = min(size_ratio * 5, 1.0)
            
            # Combined quality score (weighted average)
            quality_score = (
                blur_score * 0.4 + 
                brightness_score * 0.3 + 
                size_score * 0.3
            )
            
            return round(quality_score, 2)
            
        except Exception as e:
            print(f"Quality score calculation error: {e}")
            return 0.5