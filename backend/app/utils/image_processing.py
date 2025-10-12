from fastapi import UploadFile, HTTPException
from PIL import Image
import io
import os
import uuid
from pathlib import Path
from typing import Tuple

async def save_upload_file(upload_file: UploadFile, directory: str) -> str:
    """Save uploaded file and return the file path."""
    try:
        # Generate unique filename
        file_extension = Path(upload_file.filename).suffix
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        file_path = os.path.join(directory, unique_filename)
        
        # Save file
        contents = await upload_file.read()
        with open(file_path, "wb") as f:
            f.write(contents)
        
        return file_path
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save file: {str(e)}")

async def validate_image(upload_file: UploadFile, max_size: int = 10485760) -> bool:
    """Validate image file."""
    # Check file size
    contents = await upload_file.read()
    await upload_file.seek(0)  # Reset file pointer
    
    if len(contents) > max_size:
        raise HTTPException(status_code=400, detail="File size exceeds maximum allowed size")
    
    # Check if it's a valid image
    try:
        image = Image.open(io.BytesIO(contents))
        image.verify()
        await upload_file.seek(0)  # Reset file pointer again
        return True
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid image file")

def resize_image(image_path: str, max_size: Tuple[int, int] = (800, 800)) -> str:
    """Resize image if it exceeds max size."""
    try:
        with Image.open(image_path) as img:
            # Only resize if image is larger than max_size
            if img.size[0] > max_size[0] or img.size[1] > max_size[1]:
                img.thumbnail(max_size, Image.Resampling.LANCZOS)
                img.save(image_path, quality=85, optimize=True)
        return image_path
    except Exception as e:
        print(f"Error resizing image: {e}")
        return image_path