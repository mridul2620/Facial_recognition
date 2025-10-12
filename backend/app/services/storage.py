from motor.motor_asyncio import AsyncIOMotorClient
from typing import Optional, List, Dict, Any
from app.config import settings
from app.models.user import User, UserCreate, UserInDB
from app.models.face import FaceEmbedding, FaceEmbeddingCreate, FaceEmbeddingInDB
from datetime import datetime
from bson import ObjectId
import uuid

class StorageService:
    def __init__(self):
        """Initialize MongoDB storage service."""
        self.client = None
        self.db = None
        self.users_collection = None
        self.embeddings_collection = None
    
    async def connect(self):
        """Connect to MongoDB."""
        try:
            self.client = AsyncIOMotorClient(settings.MONGODB_URL)
            self.db = self.client[settings.MONGODB_DB_NAME]
            self.users_collection = self.db["users"]
            self.embeddings_collection = self.db["face_embeddings"]
            
            # Create indexes
            await self._create_indexes()
            
            print(f"Connected to MongoDB: {settings.MONGODB_DB_NAME}")
        except Exception as e:
            print(f"Error connecting to MongoDB: {e}")
            raise
    
    async def disconnect(self):
        """Disconnect from MongoDB."""
        if self.client:
            self.client.close()
            print("Disconnected from MongoDB")
    
    async def _create_indexes(self):
        """Create database indexes."""
        try:
            # Users collection indexes
            await self.users_collection.create_index("user_id", unique=True)
            await self.users_collection.create_index("email", unique=True)
            
            # Face embeddings collection indexes
            await self.embeddings_collection.create_index("user_id")
            await self.embeddings_collection.create_index("faiss_index_id", unique=True)
            
            print("Database indexes created")
        except Exception as e:
            print(f"Error creating indexes: {e}")
    
    def _serialize_doc(self, doc: Dict) -> Dict:
        """Convert MongoDB document to JSON-serializable format."""
        if doc and "_id" in doc:
            doc["_id"] = str(doc["_id"])
        return doc
    
    # User Operations
    async def create_user(self, user_data: UserCreate) -> User:
        """Create a new user."""
        try:
            user_id = f"user_{uuid.uuid4().hex[:12]}"
            user = User(
                user_id=user_id,
                name=user_data.name,
                email=user_data.email,
                phone=user_data.phone,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow(),
                is_active=True
            )
            
            # Convert to dict for MongoDB
            user_dict = user.model_dump()
            await self.users_collection.insert_one(user_dict)
            
            return user
        except Exception as e:
            print(f"Error creating user: {e}")
            raise
    
    async def get_user_by_id(self, user_id: str) -> Optional[User]:
        """Get user by ID."""
        try:
            user_data = await self.users_collection.find_one({"user_id": user_id})
            if user_data:
                user_data = self._serialize_doc(user_data)
                return User(**user_data)
            return None
        except Exception as e:
            print(f"Error getting user: {e}")
            return None
    
    async def get_user_by_email(self, email: str) -> Optional[User]:
        """Get user by email."""
        try:
            user_data = await self.users_collection.find_one({"email": email})
            if user_data:
                user_data = self._serialize_doc(user_data)
                return User(**user_data)
            return None
        except Exception as e:
            print(f"Error getting user by email: {e}")
            return None
    
    async def get_all_users(self, skip: int = 0, limit: int = 100) -> List[User]:
        """Get all users."""
        try:
            cursor = self.users_collection.find().skip(skip).limit(limit)
            users = []
            async for user_data in cursor:
                user_data = self._serialize_doc(user_data)
                users.append(User(**user_data))
            return users
        except Exception as e:
            print(f"Error getting users: {e}")
            return []
    
    async def update_user(self, user_id: str, update_data: Dict[str, Any]) -> bool:
        """Update user."""
        try:
            update_data["updated_at"] = datetime.utcnow()
            result = await self.users_collection.update_one(
                {"user_id": user_id},
                {"$set": update_data}
            )
            return result.modified_count > 0
        except Exception as e:
            print(f"Error updating user: {e}")
            return False
    
    async def delete_user(self, user_id: str) -> bool:
        """Delete user."""
        try:
            result = await self.users_collection.delete_one({"user_id": user_id})
            return result.deleted_count > 0
        except Exception as e:
            print(f"Error deleting user: {e}")
            return False
    
    # Face Embedding Operations
    async def create_face_embedding(
        self, 
        embedding_data: FaceEmbeddingCreate
    ) -> FaceEmbedding:
        """Create face embedding record."""
        try:
            embedding = FaceEmbedding(**embedding_data.model_dump())
            embedding_dict = embedding.model_dump()
            await self.embeddings_collection.insert_one(embedding_dict)
            return embedding
        except Exception as e:
            print(f"Error creating face embedding: {e}")
            raise
    
    async def get_embedding_by_faiss_id(self, faiss_id: int) -> Optional[FaceEmbedding]:
        """Get embedding by FAISS ID."""
        try:
            embedding_data = await self.embeddings_collection.find_one(
                {"faiss_index_id": faiss_id}
            )
            if embedding_data:
                embedding_data = self._serialize_doc(embedding_data)
                return FaceEmbedding(**embedding_data)
            return None
        except Exception as e:
            print(f"Error getting embedding: {e}")
            return None
    
    async def get_embeddings_by_user_id(self, user_id: str) -> List[FaceEmbedding]:
        """Get all embeddings for a user."""
        try:
            cursor = self.embeddings_collection.find({"user_id": user_id})
            embeddings = []
            async for embedding_data in cursor:
                embedding_data = self._serialize_doc(embedding_data)
                embeddings.append(FaceEmbedding(**embedding_data))
            return embeddings
        except Exception as e:
            print(f"Error getting embeddings: {e}")
            return []
    
    async def delete_face_embedding(self, faiss_id: int) -> bool:
        """Delete face embedding record."""
        try:
            result = await self.embeddings_collection.delete_one(
                {"faiss_index_id": faiss_id}
            )
            return result.deleted_count > 0
        except Exception as e:
            print(f"Error deleting embedding: {e}")
            return False
    
    async def delete_embeddings_by_user_id(self, user_id: str) -> int:
        """Delete all embeddings for a user."""
        try:
            result = await self.embeddings_collection.delete_many({"user_id": user_id})
            return result.deleted_count
        except Exception as e:
            print(f"Error deleting embeddings: {e}")
            return 0