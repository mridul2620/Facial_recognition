import numpy as np
from typing import Optional, List
from deepface import DeepFace
from app.config import settings

class FaceRecognitionService:
    def __init__(
        self, 
        model_name: str = "Facenet512",
        distance_metric: str = "cosine"
    ):
        """
        Initialize face recognition service.
        
        Args:
            model_name: Recognition model (VGG-Face, Facenet, Facenet512, OpenFace, 
                       DeepFace, DeepID, ArcFace, Dlib, SFace)
            distance_metric: Distance metric (cosine, euclidean, euclidean_l2)
        """
        self.model_name = model_name
        self.distance_metric = distance_metric
        print(f"Face Recognition Service initialized with model: {model_name}")
    
    def extract_embedding(self, image_path: str) -> Optional[np.ndarray]:
        """
        Extract face embedding from image.
        
        Returns:
            numpy array of embedding or None if failed
        """
        try:
            # Extract embedding using DeepFace
            embedding_objs = DeepFace.represent(
                img_path=image_path,
                model_name=self.model_name,
                enforce_detection=True,
                detector_backend=settings.FACE_DETECTION_BACKEND,
                align=True
            )
            
            if not embedding_objs:
                return None
            
            # Get first face embedding
            embedding = np.array(embedding_objs[0]["embedding"])
            
            # Normalize embedding for cosine similarity
            if self.distance_metric == "cosine":
                embedding = embedding / np.linalg.norm(embedding)
            
            return embedding
            
        except Exception as e:
            print(f"Embedding extraction error: {e}")
            return None
    
    def compare_embeddings(
        self, 
        embedding1: np.ndarray, 
        embedding2: np.ndarray
    ) -> float:
        """
        Compare two embeddings and return distance.
        
        Returns:
            Distance between embeddings (lower is more similar)
        """
        try:
            if self.distance_metric == "cosine":
                # Cosine distance (1 - cosine similarity)
                similarity = np.dot(embedding1, embedding2)
                distance = 1 - similarity
            elif self.distance_metric == "euclidean":
                # Euclidean distance
                distance = np.linalg.norm(embedding1 - embedding2)
            elif self.distance_metric == "euclidean_l2":
                # L2 normalized Euclidean distance
                distance = np.linalg.norm(embedding1 - embedding2)
            else:
                # Default to cosine
                similarity = np.dot(embedding1, embedding2)
                distance = 1 - similarity
            
            return float(distance)
            
        except Exception as e:
            print(f"Embedding comparison error: {e}")
            return 1.0  # Maximum distance on error