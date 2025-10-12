# Facial Recognition App (Flutter + FastAPI)

This project is a **face recognition mobile app** built with **Flutter** for the frontend and **FastAPI (Python)** for the backend.  
The app launches the camera and automatically recognizes people based on stored face data.

---

## 🚀 How It Works

1. The app launches the **camera** and captures a face in real time.  
2. The captured image is uploaded to **Firebase Storage**.  
3. The **FastAPI backend** receives the image URL and:
   - downloads the image,  
   - detects the face,  
   - extracts the **facial embedding**,  
   - and saves it to **MongoDB** along with the person’s name and image URL.  
4. When a new face appears, the backend compares it to stored embeddings and sends back the **recognized person’s name**.  
5. The name is displayed on the camera screen in the Flutter app.

---

## 🧩 Tech Stack

**Frontend (Flutter)**
- Flutter framework for Android/iOS  
- Camera integration  
- Firebase SDK for image uploads  
- REST API calls to backend  

**Backend (FastAPI)**
- FastAPI (Python) for API development  
- DeepFace (or FaceNet) for facial recognition  
- MongoDB for storing embeddings and metadata  
- Firebase Admin SDK for image handling  

---


---

## ⚙️ Features

- Real-time face detection and recognition  
- Add new users with name and face image  
- Firebase Storage integration for images  
- MongoDB storage for embeddings and metadata  
- Recognition results displayed on live camera preview  

---

## 📌 Future Improvements

- Multi-face recognition in a single frame  
- Local caching of embeddings for faster recognition  
- User authentication using Firebase Auth  
- Offline support for temporary image storage  

---

## 📚 References

- [Flutter](https://flutter.dev/)  
- [FastAPI](https://fastapi.tiangolo.com/)  
- [DeepFace](https://github.com/serengil/deepface)  
- [Firebase Storage](https://firebase.google.com/products/storage)  
- [MongoDB](https://www.mongodb.com/)


## 📁 Project Structure

