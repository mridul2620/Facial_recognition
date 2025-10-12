import faiss
import numpy as np
import json
import os
from typing import List, Tuple, Optional, Dict
from app.config import settings

class VectorSearchService:
    def __init__(self):
        """Initialize FAISS vector search service."""
        self.index = None
        self.mapping = {}  # Maps FAISS index ID to user_id
        self.dimension = 512  # Facenet512 embedding dimension
        self.index_path = settings.FAISS_INDEX_PATH
        self.mapping_path = settings.FAISS_MAPPING_PATH
        
        # Load existing index if available
        self._load_or_create_index()
        print(f"Vector Search Service initialized. Index size: {self.get_index_size()}")
    
    def _load_or_create_index(self):
        """Load existing FAISS index or create new one."""
        if os.path.exists(self.index_path) and os.path.exists(self.mapping_path):
            try:
                # Load index
                self.index = faiss.read_index(self.index_path)
                
                # Load mapping
                with open(self.mapping_path, 'r') as f:
                    self.mapping = json.load(f)
                
                print(f"Loaded existing FAISS index with {self.index.ntotal} vectors")
            except Exception as e:
                print(f"Error loading index: {e}. Creating new index.")
                self._create_new_index()
        else:
            self._create_new_index()
    
    def _create_new_index(self):
        """Create a new FAISS index."""
        # Using IndexFlatL2 for exact search (good for < 10K vectors)
        # For larger datasets, use IndexIVFFlat or IndexHNSW
        self.index = faiss.IndexFlatL2(self.dimension)
        self.mapping = {}
        print("Created new FAISS index")
    
    def add_embedding(self, embedding: np.ndarray, user_id: str) -> int:
        """
        Add embedding to FAISS index.
        
        Args:
            embedding: Face embedding vector
            user_id: User identifier
            
        Returns:
            FAISS index ID
        """
        try:
            # Ensure embedding is the right shape
            if embedding.ndim == 1:
                embedding = embedding.reshape(1, -1)
            
            # Ensure correct dimension
            if embedding.shape[1] != self.dimension:
                raise ValueError(f"Expected dimension {self.dimension}, got {embedding.shape[1]}")
            
            # Add to FAISS index
            faiss_id = self.index.ntotal
            self.index.add(embedding.astype('float32'))
            
            # Update mapping
            self.mapping[str(faiss_id)] = user_id
            
            # Save index and mapping
            self._save_index()
            
            print(f"Added embedding for user {user_id} with FAISS ID {faiss_id}")
            return faiss_id
            
        except Exception as e:
            print(f"Error adding embedding: {e}")
            raise
    
    def search(
        self, 
        query_embedding: np.ndarray, 
        k: int = 5,
        threshold: float = None
    ) -> List[Tuple[str, float, int]]:
        """
        Search for similar embeddings.
        
        Args:
            query_embedding: Query face embedding
            k: Number of results to return
            threshold: Distance threshold (optional)
            
        Returns:
            List of tuples (user_id, distance, faiss_id)
        """
        try:
            if self.index.ntotal == 0:
                return []
            
            # Ensure embedding is the right shape
            if query_embedding.ndim == 1:
                query_embedding = query_embedding.reshape(1, -1)
            
            # Search in FAISS
            distances, indices = self.index.search(query_embedding.astype('float32'), k)
            
            # Process results
            results = []
            for dist, idx in zip(distances[0], indices[0]):
                if idx == -1:  # No more results
                    continue
                
                # Apply threshold if specified
                if threshold is not None and dist > threshold:
                    continue
                
                user_id = self.mapping.get(str(idx))
                if user_id:
                    results.append((user_id, float(dist), int(idx)))
            
            return results
            
        except Exception as e:
            print(f"Error searching embeddings: {e}")
            return []
    
    def delete_embedding(self, faiss_id: int) -> bool:
        """
        Delete embedding from index.
        Note: FAISS doesn't support deletion, so we remove from mapping only.
        For production, consider rebuilding index periodically.
        """
        try:
            if str(faiss_id) in self.mapping:
                del self.mapping[str(faiss_id)]
                self._save_index()
                return True
            return False
        except Exception as e:
            print(f"Error deleting embedding: {e}")
            return False
    
    def get_index_size(self) -> int:
        """Get number of vectors in index."""
        return self.index.ntotal if self.index else 0
    
    def _save_index(self):
        """Save FAISS index and mapping to disk."""
        try:
            # Save FAISS index
            faiss.write_index(self.index, self.index_path)
            
            # Save mapping
            with open(self.mapping_path, 'w') as f:
                json.dump(self.mapping, f, indent=2)
            
        except Exception as e:
            print(f"Error saving index: {e}")
    
    def rebuild_index(self, embeddings: List[Tuple[np.ndarray, str]]):
        """
        Rebuild index from scratch (useful for cleanup).
        
        Args:
            embeddings: List of (embedding, user_id) tuples
        """
        self._create_new_index()
        
        for embedding, user_id in embeddings:
            self.add_embedding(embedding, user_id)
        
        print(f"Rebuilt index with {len(embeddings)} embeddings")