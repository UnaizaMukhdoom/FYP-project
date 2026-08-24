# Vogue AI: Next Gen Fashion Stylist 👗✨

**An AI-powered, culturally-aware fashion styling app built for Pakistani women.**

Vogue AI analyzes your skin tone, undertone, and face shape, then delivers personalized seasonal color palettes, outfit recommendations, jewelry suggestions, and outfit scoring — all through a Flutter mobile app with a bilingual (English / Roman Urdu) AI stylist chatbot.

---

## 📖 Table of Contents

- [About the Project](#about-the-project)
- [Problem Statement](#problem-statement)
- [Core Features](#core-features)
- [How It Works](#how-it-works)
- [Tech Stack](#tech-stack)
- [System Architecture](#system-architecture)
- [AI / ML Details](#ai--ml-details)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Roadmap](#roadmap)
- [Known Challenges](#known-challenges)
- [References](#references)
- [License](#license)

---

## About the Project

The fashion and apparel industry rarely accounts for the physical and cultural nuances of Eastern women — skin tone, undertone, face shape, climate, modesty preferences, and local trends. Traditional shopping experiences and existing fashion-tech platforms are largely built around Western beauty standards, leaving a gap for Pakistani users who want fashion guidance that actually understands them.

**Vogue AI** closes that gap with an intelligent, mobile-first stylist that combines computer vision, NLP, and a retrieval-augmented chatbot to give real-time, personalized, and culturally relevant fashion advice — grounded in fashion data scraped from popular Pakistani brands like Khaadi, Sapphire, Gul Ahmed, Nishat Linen, and Limelight.

## Problem Statement

- Conventional retail ignores skin tone, face shape, body type, and cultural context, leading to poor purchases and low confidence.
- South Asian undertones are underrepresented in existing color-analysis tools.
- High cart-abandonment and return rates are driven by uncertainty around fit and color.
- Professional styling advice is inaccessible or unaffordable for most users.
- No mainstream tool currently offers bilingual (English/Urdu), Pakistan-specific styling support.

## Core Features

| Feature | Description |
|---|---|
| 🎨 **Skin Tone & Undertone Analysis** | Detects skin tone (Very Fair, Medium, Deep/Dark) and undertone (Warm, Cool, Neutral) from a selfie using OpenCV, then maps results to a seasonal color palette. |
| 🧑‍🎨 **Face Shape Detection** | Classifies face shape (Oval, Round, Square, Heart, Diamond, Oblong) using MediaPipe Face Mesh (468 landmarks) with an OpenCV Haar Cascade fallback, then recommends complementary jewelry (earrings/necklaces). |
| 💬 **AI Stylist Chatbot** | A bilingual (English / Roman Urdu) conversational assistant powered by a Retrieval-Augmented Generation (RAG) pipeline for real-time styling Q&A. |
| 👚 **FitMe / Fit Check** | Upload an outfit photo and receive a scored "report card" covering color harmony, coherence, and trend alignment, with styling feedback. |
| 👗 **Virtual Wardrobe** | Digitally organize your closet, track wear history, view usage stats, and get daily outfit suggestions from items you already own. |
| 🛍️ **Trend Discovery** | Scrapes and surfaces current items from Pakistani fashion brands, filtered by the user's color palette and preferences. |
| 🌐 **Multilingual Support** | Full chatbot and UI support for English and Roman Urdu to maximize accessibility. |
| 🛠️ **Admin Panel** | A web dashboard (Flutter Web) for user management, analytics, content moderation, and scraper configuration. |

## How It Works

### AI Stylist Chatbot — RAG Pipeline

```
User Query
   │
   ▼
Preprocess (clean, normalize, detect language)
   │
   ▼
Embed query → Sentence Transformers (all-MiniLM-L6-v2)
   │
   ▼
Intent Classifier predicts intent + confidence
   │
   ├── Low confidence / non-fashion → Fallback response
   │
   └── High confidence + fashion intent
          │
          ▼
     Semantic Search → Top-k relevant chunks (RAG retrieval)
          │
          ▼
     Build LLM context (query + retrieved chunks)
          │
          ▼
     LLaMA (via Groq API) generates response
          │
          ▼
     Postprocess → Response sent to user
```

RAG was chosen over fine-tuning because it grounds every response in verified, retrievable fashion data — eliminating hallucination — while staying cheap and agile to update (only the vector store needs refreshing, not the model).

### Face Shape Analysis

1. User captures/selects a selfie.
2. MediaPipe Face Mesh attempts 468-point landmark detection.
3. Key ratios are calculated (forehead vs. jaw width, face length vs. width).
4. A confidence score is assigned across 6 shape classes and the best match is selected.
5. If MediaPipe fails (poor lighting/angle), the system falls back to an OpenCV Haar Cascade height/width ratio classifier.
6. Matching jewelry recommendations are queried from the database and displayed.

## Tech Stack

### Frontend (Mobile App)

| Technology | Purpose |
|---|---|
| Flutter (Dart) | Cross-platform mobile app (Android, extensible to iOS) |
| Provider | State management |
| Firebase Auth | Email/password + Google Sign-In |
| Cloud Firestore | Real-time NoSQL database |
| Firebase Storage | Image & media storage |
| Material Design 3 | UI/UX design system |
| image_picker, image_compress, cached_network_image | Camera, gallery, and media handling |

### Backend / AI Services

| Technology | Purpose |
|---|---|
| Flask (Python) | REST API server & request orchestration |
| OpenCV | Skin tone extraction, color analysis, Haar Cascade fallback |
| MediaPipe | Facial landmark detection for face shape classification |
| Sentence Transformers (`all-MiniLM-L6-v2`) | Query embeddings for semantic search |
| scikit-learn | Intent classification (Logistic Regression) |
| Groq API (LLaMA-3.1-8B) | LLM response generation |
| BeautifulSoup4 + Requests | Web scraping of Pakistani fashion brands |
| Pandas / NumPy / SciPy | Data processing |
| Gunicorn + Flask-CORS | Production serving |

### Admin Panel

- Flutter Web frontend
- Firebase Firestore backend
- Firebase Auth–gated access with Firestore-verified admin roles

## System Architecture

```
┌─────────────────────────┐        ┌──────────────────────────┐
│      Client Layer        │        │   Data & Infrastructure   │
│  ─────────────────────   │        │  ────────────────────────│
│  Flutter Mobile App       │◄──────►│  Firebase Auth            │
│  Admin Panel (Web)         │        │  Firebase Storage          │
└───────────┬───────────────┘        │  Cloud Firestore            │
            │ REST API                └──────────────┬───────────┘
            ▼                                          │
┌─────────────────────────────┐                        │
│   API Gateway (Flask)         │◄───────────────────────┘
└───────────┬───────────────────┘
            │
┌───────────┴─────────────────────────────────────────────┐
│                  Microservices & AI                        │
│  OpenCV / MediaPipe   Sentence Transformers   Groq LLM       │
│  Web Scraping Engine (BeautifulSoup) → External Fashion Sites │
└─────────────────────────────────────────────────────────────┘
```

## AI / ML Details

**Intent Classification — Model Comparison**

| Model | Accuracy | F1 (Weighted) | F1 (Macro) | Precision | Recall |
|---|---|---|---|---|---|
| **Logistic Regression** ✅ | 0.9099 | 0.9117 | 0.8868 | 0.8850 | 0.8986 |
| Multi-Layer Perceptron | 0.8961 | 0.8946 | 0.8711 | 0.8949 | 0.8617 |
| Support Vector Machine | 0.8776 | 0.8803 | 0.8768 | 0.8777 | 0.8907 |
| Random Forest | 0.8799 | 0.8771 | 0.8693 | 0.8858 | 0.8739 |
| Gradient Boosting | 0.5589 | 0.5655 | 0.5152 | 0.5563 | 0.5203 |

Logistic Regression was selected as the production intent classifier for its strong generalization, resistance to overfitting, and reliable baseline performance.

**Chatbot Dataset & Configuration**

- Dataset: 2,164 samples (`fashion_dataset_balanced.csv`), 52 intent classes
- Embedding model: `all-MiniLM-L6-v2` (384-dim, <10ms/query, 104-language support)
- Chunking: 1000-character chunks with 150-character overlap, top-5 retrieval
- Thresholds: `confidence_threshold=0.6`, `similarity_threshold=0.7`
- Overall accuracy: 90.99% · F1 (weighted): 91.17%
- Average response time: 1.0–2.0 seconds per query

## Screenshots

### Onboarding

| Splash Screen | Sign In | Style Questionnaire |
|---|---|---|
| <img src="https://github.com/user-attachments/assets/713aef70-d670-4f6b-85e3-cbb7b2448c34" width="220"/> | <img src="https://github.com/user-attachments/assets/8652694c-a117-4347-b9ce-09290d44ccf3" width="220"/> | <img src="https://github.com/user-attachments/assets/dc25930e-255d-4659-a963-75bd5cef69c4" width="220"/> |

### Core Features

| Home Dashboard | Personal Color Result |
|---|---|
| <img src="https://github.com/user-attachments/assets/e7c515ff-b210-403f-ad09-f67613322400" width="220"/> | <img src="https://github.com/user-attachments/assets/dc2df7f6-4fcf-415d-b0ba-b2a23b438286" width="220"/> |

| Wardrobe / Plan Your Outfit | Discover (Brand Trends) |
|---|---|
| <img src="https://github.com/user-attachments/assets/081dfb01-50b8-41ef-97a1-0e0fb1a1eedb" width="220"/> | <img src="https://github.com/user-attachments/assets/d56635b1-17b3-4d83-82cb-77b7b03d5234" width="220"/> |

| AI Stylist Chatbot | Profile |
|---|---|
| <img src="https://github.com/user-attachments/assets/91047de3-8504-4895-9c1d-0073a7a6f2af" width="220"/> | <img src="https://github.com/user-attachments/assets/7b8a9357-fe5b-4f8a-a469-102ea22211c2" width="220"/> |

### Admin Panel

<img src="https://github.com/user-attachments/assets/974b013e-44a6-4861-937f-1b79ba62c7df" width="600"/>

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+
- Python 3.x
- Firebase project (Auth, Firestore, Storage enabled)
- Groq API key (for LLaMA chatbot responses)
- Android Studio / VS Code with Flutter & Dart plugins

### Mobile App Setup

```bash
git clone https://github.com/<your-username>/vogue-ai.git
cd vogue-ai/mobile_app

# Install dependencies
flutter pub get

# Add your Firebase config
# - android/app/google-services.json
# - firebase_options.dart (via flutterfire configure)

# Run the app
flutter run
```

### Backend Setup

```bash
cd vogue-ai/backend

# Create a virtual environment
python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set environment variables
export GROQ_API_KEY="your_groq_api_key"
export FIREBASE_CREDENTIALS="path/to/serviceAccount.json"

# Run the Flask API
python app.py
```

The API will be available at `http://localhost:5000` by default. Update the `baseUrl` in the Flutter app's service layer to point to your backend (local or deployed, e.g. Railway).

### Admin Panel Setup

```bash
cd vogue-ai/admin_panel
flutter pub get
flutter run -d chrome
```

## Project Structure

```
vogue-ai/
├── mobile_app/            # Flutter mobile application
│   ├── lib/
│   │   ├── screens/       # UI screens (Login, Home, Chatbot, FitMe, etc.)
│   │   ├── services/      # API, Auth, Firestore, Storage services
│   │   ├── state/         # Provider state classes
│   │   └── widgets/       # Reusable UI components
│   └── pubspec.yaml
├── backend/                # Flask API & AI services
│   ├── routes/             # API endpoints (/analyze, /analyze-face-shape, /chat)
│   ├── services/           # OpenCV, MediaPipe, RAG, scraper modules
│   ├── models/              # Trained intent classifier, embeddings
│   └── requirements.txt
├── admin_panel/             # Flutter Web admin dashboard
├── docs/                    # Diagrams, screenshots, report assets
└── README.md
```

## Roadmap

- [ ] iOS platform support
- [ ] Add styling features for men's fashion
- [ ] Gamification (badges/rewards for engagement)
- [ ] Multi-language expansion beyond English/Roman Urdu
- [ ] Advanced caching & offline mode
- [ ] Custom/targeted admin notifications
- [ ] Cloud storage optimization for media assets

## Known Challenges

- **Firestore data structuring** — resolved via indexing and a scalable collection design.
- **Analysis accuracy across diverse skin tones** — addressed with a MediaPipe + OpenCV fallback pipeline and extensive color-space calibration.
- **Backend reliability for image uploads** — resolved with proper timeout handling, health-check endpoints, and dual local/production environments.
- **Bilingual intent classification** — improved via a balanced training dataset and tuned semantic search thresholds.
- **Cross-platform consistency** — addressed through iterative testing across Android configurations.

## References

1. D. Rodrigues and R. Pereira, "How can artificial intelligence help improve fashion sustainability?," in *Digital Technologies and Transformation in Business, Industry and Organizations*, Springer, 2023.
2. P. N. Evangelista, "Artificial intelligence in fashion," M.S. thesis, Politecnico di Milano, 2020.
3. A. K. Singh, V. A. Kumbhare, K. Arthi, "Real-time human pose detection and recognition using MediaPipe," *Advances in Intelligent Systems and Computing*, 2022.
4. Q. Zhang et al., "The impact of clothing colour on skin tone perception and consumer preference," *Coloration Technology*, 2025.
5. R. Singh, C. Dutta, P. K. Singh, "Comparative analysis of human GAIT across different attires using MediaPipe Pose," 2025.
6. "AI-skin tone Features on Online Shopping to Women's Casual Clothing Purchase Intentions," IEEE Xplore, 2024.
7. M. K. Mishra, R. Pal, R. Nayak, "Chatbots and AI in fashion industry," Springer, 2025.
8. D. Sukhwal, "Retrieval augmented generation: An evaluation of RAG-based chatbot for customer support," UTUPub, 2025.

## License

This project was developed as a Final Year Project for the Bachelor of Science in Computer Science degree at Bahria University, Lahore Campus.

---
