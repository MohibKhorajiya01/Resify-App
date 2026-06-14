# Resify 🚀

Resify is an AI-powered resume builder application built with Flutter. It leverages the Gemini AI API to help users instantly generate professional, structured resumes from simple text prompts. Users can choose from multiple beautiful templates, preview their resumes, and export them as high-quality PDFs.

## 🌟 Key Features

*   **AI Resume Generation**: Simply describe your experience or role, and the Gemini AI will generate a fully structured resume with impactful bullet points and industry-standard keywords.
*   **Multiple Professional Templates**: Choose from a variety of aesthetically pleasing templates including Modern, Classic, Grid, Minimal, Creative, and Executive.
*   **Real-time PDF Preview & Export**: Preview your resume instantly and download it as a PDF or share it directly from the app.
*   **Resume Management Dashboard**: Save and manage multiple versions of your resumes securely in one place.
*   **Secure Authentication**: Secure user login and registration powered by Firebase Authentication (with mandatory email verification).
*   **Cloud Storage**: Your resumes and profile data are safely backed up using Firebase Firestore.

## 🛠️ Tech Stack

*   **Frontend**: Flutter & Dart
*   **State Management & Routing**: GetX
*   **Backend & Database**: Firebase (Authentication, Firestore, Storage)
*   **AI Integration**: Google Gemini API
*   **PDF Generation**: `pdf` & `printing` packages
*   **Environment Configuration**: `flutter_dotenv`

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK (^3.11.3 or higher)
*   Dart SDK
*   Firebase project setup (for Android/iOS)
*   Google Gemini API Key

### Installation

1.  **Clone the repository**
    ```bash
    git clone https://github.com/MohibKhorajiya01/Resify-App.git
    cd Resify-App
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Setup Environment Variables**
    Create a `.env` file in the root of your project and add your Gemini API key:
    ```env
    GEMINI_API_KEY=your_gemini_api_key_here
    ```

4.  **Run the App**
    ```bash
    flutter run
    ```

## 📂 Project Structure

*   `lib/views/` - Contains all the UI screens (Authentication, Dashboard, Resume Creation, Settings, etc.)
*   `lib/controllers/` - GetX controllers handling state and business logic.
*   `lib/core/services/` - Core services including PDF generation (`pdf_service.dart`) and AI API integration (`gemini_service.dart`).
*   `lib/models/` - Data models for Resumes and Users.
*   `lib/widgets/` - Reusable UI components like custom buttons, text fields, and skill chips.

## 🤝 Contributing
Contributions, issues, and feature requests are welcome!

## 📝 License
This project is for personal use and learning purposes.
