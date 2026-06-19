# Resify 🚀 - AI-Powered Resume Builder

A modern, highly responsive Flutter application that leverages Google Gemini AI to help professionals craft perfect ATS-optimized resumes in minutes. Resify takes a simple text prompt and generates a complete, structured resume with impactful bullet points. Users can select from multiple professional templates, preview the output natively, and export it as a high-quality PDF.

## 📸 App Screenshots

| Splash Screen & Auth | Dashboard & Templates |
| :---: | :---: |
| <img src="Resify%20Screenshots/SpleshScreen.png" width="250"/> | <img src="Resify%20Screenshots/HomePage.png" width="250"/> |
| <img src="Resify%20Screenshots/login.png" width="250"/> | <img src="Resify%20Screenshots/SelectTemplate.png" width="250"/> |
| <img src="Resify%20Screenshots/Signup.png" width="250"/> | <img src="Resify%20Screenshots/userProfile.png" width="250"/> |

| AI Generation Process | Resume Editing |
| :---: | :---: |
| <img src="Resify%20Screenshots/proptPage.png" width="250"/> | <img src="Resify%20Screenshots/EditResume1.png" width="250"/> |
| <img src="Resify%20Screenshots/inputProcess.png" width="250"/> | <img src="Resify%20Screenshots/EditResume2.png" width="250"/> |
| <img src="Resify%20Screenshots/GenerateResume.png" width="250"/> | <img src="Resify%20Screenshots/verify.png" width="250"/> |

---

## 🌟 Key Features

*   **AI Resume Generation**: Write a brief prompt about your field, and the Gemini AI engine generates a fully structured, industry-standard resume.
*   **Template Variety**: Choose from multiple polished themes (Modern, Classic, Grid, Minimal, Creative, Executive) that automatically adjust layout based on your data.
*   **Dynamic Editor**: A multi-step form editor that allows manual overriding and tweaking of AI-generated content (Personal Info, Experience, Skills, Projects, etc.).
*   **Real-time PDF Preview**: Natively rasterizes the generated PDF inside the app for a crisp, real-time preview before exporting.
*   **Dashboard & Cloud Sync**: Firebase integration ensures your resumes and personal data are securely backed up and accessible across devices.
*   **Authentication**: Built-in email verification and secure login flow via Firebase Auth.

## 🛠️ Tech Stack

*   **Framework**: Flutter & Dart
*   **Architecture & State Management**: MVC Pattern using **GetX** (Routing, State, Dependency Injection)
*   **Backend as a Service (BaaS)**: Firebase (Firestore, Authentication)
*   **AI Engine**: Google Gemini API (`generative-ai`)
*   **PDF Engine**: `pdf` (creation) & `printing` (rasterization & export)
*   **Security**: `flutter_dotenv` for environment variable protection

## 📂 Folder Structure

```text
lib/
│
├── controllers/          # GetX Controllers (Business logic & State)
│   ├── auth_controller.dart
│   └── resume_controller.dart
│
├── core/                 # Core utilities, constants, and external services
│   ├── constants/        # AppColors, AppTextStyles
│   └── services/         # GeminiService, PdfService
│
├── models/               # Data structures (ResumeModel, ChatMessage)
│
├── views/                # UI Screens grouped by feature
│   ├── auth/             # Login, Register, Verify Email
│   ├── create_resume/    # AI Input chat, Multi-step manual form editor
│   ├── dashboard/        # Main hub, saved resumes list
│   ├── preview/          # PDF visual preview
│   ├── settings/         # Profile, Edit Profile, Privacy Policy
│   └── templates/        # Resume template selector
│
└── widgets/              # Reusable customized UI components
    ├── custom_button.dart
    ├── custom_textfield.dart
    └── resume_card.dart
```

## 🚀 Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/MohibKhorajiya01/Resify-App.git
   cd Resify-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment Setup**
   Create a `.env` file in the root directory and add your Google Gemini API key:
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

## 📝 License
This project is for personal use and portfolio demonstration.
