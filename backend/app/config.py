from pydantic_settings import BaseSettings
from typing import List
import os

class Settings(BaseSettings):
    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    RELOAD: bool = True
    
    # MongoDB
    MONGODB_URL: str = "mongodb://localhost:27017"
    MONGODB_DB_NAME: str = "face_recognition"
    
    # FAISS
    FAISS_INDEX_PATH: str = "./faiss_index/faces.index"
    FAISS_MAPPING_PATH: str = "./faiss_index/mapping.json"
    
    # Uploads
    UPLOAD_DIR: str = "./uploads"
    MAX_FILE_SIZE: int = 10485760  # 10MB
    
    # Face Recognition Models
    FACE_DETECTION_BACKEND: str = "retinaface"
    FACE_RECOGNITION_MODEL: str = "Facenet512"
    FACE_DISTANCE_METRIC: str = "cosine"
    RECOGNITION_THRESHOLD: float = 0.6
    
    # CORS
    ALLOWED_ORIGINS: str = "*"
    
    class Config:
        env_file = ".env"
        case_sensitive = True

    def get_allowed_origins(self) -> List[str]:
        if self.ALLOWED_ORIGINS == "*":
            return ["*"]
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]

# Create settings instance
settings = Settings()

# Create necessary directories
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
os.makedirs(os.path.dirname(settings.FAISS_INDEX_PATH), exist_ok=True)