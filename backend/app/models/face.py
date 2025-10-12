from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, Dict, Any
from datetime import datetime
from bson import ObjectId

class FaceEmbedding(BaseModel):
    model_config = ConfigDict(arbitrary_types_allowed=True, populate_by_name=True)
    
    user_id: str
    faiss_index_id: int
    embedding_model: str
    image_url: Optional[str] = None
    thumbnail_url: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    metadata: Optional[Dict[str, Any]] = None

class FaceEmbeddingCreate(BaseModel):
    user_id: str
    faiss_index_id: int
    embedding_model: str
    image_url: Optional[str] = None
    thumbnail_url: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None

class FaceEmbeddingInDB(FaceEmbedding):
    model_config = ConfigDict(arbitrary_types_allowed=True, populate_by_name=True)
    
    id: Optional[str] = Field(default=None, alias="_id")