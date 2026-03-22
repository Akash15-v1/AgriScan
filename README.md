# AgriScan
AgriScan is a Flutter-based mobile application designed to empower farmers by providing instant, offline chili leaf disease detection. By leveraging on-device machine learning, the app identifies whether an image contains a leaf and subsequently diagnoses specific diseases, offering localized advice in multiple languages.

🚀 Key Features
Dual-Model Pipeline: Uses two specialized TensorFlow Lite (TFLite) models for high-accuracy filtering and classification.

100% On-Device Processing: No internet connection required. All image processing and inference happen locally to ensure privacy and accessibility in rural areas.

Multilingual Support: Fully accessible in English, Telugu, and Hindi.

Actionable Insights: Provides detailed information on the Cause, Prevention, and Solution for detected diseases, sourced from an internal JSON database.

Scan History: A dedicated home screen feature to track and review previous diagnosis results.

🛠 Tech Stack
Frontend: Flutter (Dart)

Machine Learning: TensorFlow Lite (TFLite)

Data Format: JSON (for disease metadata and localized text)

Models: * Model A: Binary Classifier (Leaf vs. Non-leaf)

Model B: Chili Disease Classifier (Healthy vs. Diseased)

⚙️ How It Works
AgriScan follows a rigorous sequential processing workflow to ensure the user receives accurate data:

Input: User captures a photo via the in-app camera or selects an image from the gallery.

Validation: The first TFLite model analyzes the image. If no leaf is detected, the user is prompted to try again.

Classification: If a leaf is confirmed, the second model (trained specifically on healthy and diseased chili leaves) runs inference.

Information Retrieval: The app matches the classification result with a local JSON file to fetch the cause, prevention strategies, and solutions.

Output: The results are displayed instantly on the screen and saved to the local history.

📊 Dataset & Training
The classification model was specifically trained on a curated dataset of:

Healthy Chili Leaves

Diseased Chili Leaves (Various common pathogens)

The focus on chili leaves ensures high precision for farmers specialized in this crop.

📝 Research & Publication
This project is backed by academic research focused on sustainable agricultural technology.

Paper Title: AI-Driven Innovations for Sustainable Development Goals
Conference: International Conference on Future Tech (Future Tech - 2025)
Theme: Sustainable Development Goals (SDGs) through AI.
