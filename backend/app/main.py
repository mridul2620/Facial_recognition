from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.config import settings
from app.services.face_detection import FaceDetectionService
from app.services.face_recognition import FaceRecognitionService
from app.services.vector_search import VectorSearchService
from app.services.storage import StorageService
from app.api.routes import health, faces

# Global service instances
face_detection_service = None
face_recognition_service = None
vector_search_service = None
storage_service = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan events."""
    # Startup
    print("=" * 50)
    print("Starting Face Recognition API...")
    print("=" * 50)
    
    global face_detection_service, face_recognition_service
    global vector_search_service, storage_service
    
    # Initialize services
    face_detection_service = FaceDetectionService(
        backend=settings.FACE_DETECTION_BACKEND
    )
    
    face_recognition_service = FaceRecognitionService(
        model_name=settings.FACE_RECOGNITION_MODEL,
        distance_metric=settings.FACE_DISTANCE_METRIC
    )
    
    vector_search_service = VectorSearchService()
    
    storage_service = StorageService()
    await storage_service.connect()
    
    print("=" * 50)
    print("All services initialized successfully!")
    print("=" * 50)
    
    yield
    
    # Shutdown
    print("Shutting down...")
    await storage_service.disconnect()

# Create FastAPI app
app = FastAPI(
    title="Face Recognition API",
    description="Face recognition system with registration and identification",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.get_allowed_origins(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, prefix="/api/v1", tags=["Health"])
app.include_router(faces.router, prefix="/api/v1/faces", tags=["Faces"])

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "Face Recognition API",
        "version": "1.0.0",
        "docs": "/docs"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.RELOAD
    )