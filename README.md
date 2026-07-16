<div align="center">
  <img src="./public/logo.png" alt="CarbonTwin Logo" width="200" />
  <h1>🌱 CarbonTwin</h1>
  <p>Your digital twin for a sustainable future. Track, reduce, and offset your carbon footprint using AI.</p>
</div>

---

## 📖 Overview

CarbonTwin is an interactive platform designed to increase awareness about carbon emissions and promote sustainable habits. It employs a modern, decoupled architecture featuring a **Flutter** mobile application for a rich, cross-platform frontend and a **Next.js (Node.js)** backend acting as a secure REST API.

By combining gamification with artificial intelligence, CarbonTwin makes sustainability engaging and actionable. 

---

## ✨ Core Features

* **Dashboard Tracking:** Monitor your total carbon footprint (CO₂e), active streaks, and XP points.
* **AI Receipt Scanner (OCR):** Upload photos of receipts or energy bills. The app uses Google's Gemini AI to extract data and automatically calculate the carbon footprint of your purchases.
* **Daily AI Check-in (Learn Tab):** Chat with "Carbon Twin", an eco-friendly AI assistant. Submit your daily activities to receive personalized feedback and dynamic, 3-question trivia challenges generated on the fly.
* **Gamification:** Earn XP by logging activities and correctly answering daily eco-challenges.
* **Reward System:** Redeem your earned XP for real-world eco-rewards and sustainable offers.

---

## 🏗️ System Architecture

The project is strictly split into two layers: a Mobile Frontend and an API Backend.

```mermaid
graph TD
    A[Flutter Mobile App] -->|HTTPS REST APIs| B[Next.js API Server]
    B --> C[(PostgreSQL Database)]
    B --> D[Prisma ORM]
    B --> E[Google Gemini AI]
    
    subgraph "Backend (Next.js)"
    B
    D
    end
    
    subgraph "External Services"
    E
    C
    end
```

### 🛠️ Tech Stack

**Backend (API Server)**
* **Framework:** Next.js (utilizing App Router purely for API routes)
* **Database:** PostgreSQL (Cloud-hosted via Neon/Supabase)
* **ORM:** Prisma
* **Authentication:** Custom JWT-based stateless authentication
* **AI Integration:** Google Generative AI (`gemini-flash-latest`) for OCR parsing and dynamic trivia generation.

**Frontend (Mobile App)**
* **Framework:** Flutter (Material 3 Design)
* **Language:** Dart
* **State Management:** Riverpod (Providers & StateNotifiers)
* **Routing:** GoRouter
* **Local Storage:** Flutter Secure Storage (for JWT tokens)
* **HTTP Client:** Dio (with robust interceptors and timeout handling)

---

## 🚀 Developer Setup Guide

Follow these step-by-step instructions to run the CarbonTwin stack locally.

### Prerequisites
- [Node.js](https://nodejs.org/) (v18 or higher)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable)
- Android Studio / Xcode (for mobile emulators)
- A PostgreSQL database instance
- A [Google Gemini API Key](https://aistudio.google.com/)

---

### Step 1: Backend Setup (Next.js API)

1. **Navigate to the root directory:**
   ```bash
   cd carbon-emission-awareness-platform
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure Environment Variables:**
   Create a `.env` file in the root directory and add the following keys:
   ```env
   # PostgreSQL connection string
   DATABASE_URL="postgresql://user:password@host:port/dbname?schema=public"
   
   # JWT Secret for secure authentication tokens
   JWT_SECRET="your-super-secret-key"
   
   # Google Gemini API Key for OCR and AI Check-ins
   GEMINI_API_KEY="your-gemini-api-key"
   ```

4. **Initialize the Database:**
   Push the Prisma schema to your PostgreSQL database to create the required tables:
   ```bash
   npx prisma db push
   ```

5. **Start the API Server:**
   Start the Next.js development server:
   ```bash
   npm run dev
   ```
   *The backend will now be running at `http://localhost:3000`.*

---

### Step 2: Frontend Setup (Flutter App)

1. **Navigate to the Flutter directory:**
   Open a new terminal window and navigate to the mobile app folder:
   ```bash
   cd carbon_twin
   ```

2. **Install Dart dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure the API Client:**
   Ensure the app points to your local Next.js backend. Open `carbon_twin/lib/core/api_client.dart` and verify the `baseUrl`:
   * **Android Emulator:** Use `http://10.0.2.2:3000/api`
   * **iOS Simulator:** Use `http://localhost:3000/api`
   * **Physical Device:** Use your machine's local IP (e.g., `http://192.168.x.x:3000/api`)

4. **Run the Application:**
   Start your emulator or connect a physical device, then run:
   ```bash
   flutter run
   ```

---

## 📂 Repository Structure

```text
/
├── carbon_twin/           # Flutter Mobile Application
│   ├── android/           # Android native configuration
│   ├── ios/               # iOS native configuration
│   ├── lib/               # Dart source code
│   │   ├── core/          # API clients, theme, routing
│   │   ├── features/      # Feature modules (auth, home, learn, etc.)
│   │   └── main.dart      # Flutter entry point
│   └── pubspec.yaml       # Flutter dependencies
│
├── prisma/                # Database configuration
│   └── schema.prisma      # Data models (User, Activity, Reward, etc.)
│
├── src/                   # Backend Next.js API
│   ├── app/
│   │   ├── api/           # REST API routes (/auth, /dashboard, /learn, etc.)
│   │   └── page.js        # API Landing Page
│   └── lib/               # Shared backend utilities (auth.js)
│
├── .env                   # Backend environment variables
└── package.json           # Node.js dependencies
```

---

## 🐛 Troubleshooting

* **Registration/Login Fails (Timeout):** Ensure your emulator can reach the Next.js backend. If using Android, confirm the base URL is `10.0.2.2`. Check your Next.js terminal to verify the server is running on port `3000`.
* **Gemini API Errors:** If the Daily Check-in fails, ensure your `.env` contains a valid `GEMINI_API_KEY` and that the key has access to the `gemini-flash-latest` model.
* **Windows Build Errors:** If you encounter Gradle errors on Windows, ensure `kotlin.incremental=false` is set in your `android/gradle.properties`.

---

## 🤝 Contributing
1. Fork the repository
2. Create a new feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: added amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
