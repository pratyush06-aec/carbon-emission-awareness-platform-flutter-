<div align="center">
  <img src="./public/logo.png" alt="CarbonTwin Logo" width="200" />
  <h1>🌱 CarbonTwin</h1>
  <p>Your digital twin for a sustainable future. Track, reduce, and offset your carbon footprint.</p>
</div>

---

## 📖 Overview

CarbonTwin is a platform designed to increase carbon emission awareness. It features a decoupled architecture with a **Flutter mobile application** for the frontend and a **Next.js (Node.js)** backend acting as a pure REST API.

Users can track their daily activities, upload receipts for AI-powered carbon footprint analysis (via Google Gemini), complete eco-challenges, and redeem rewards.

## 🏗️ System Architecture

The project is split into two primary layers: a Mobile Frontend and an API Backend.

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

### 1. Backend (API Server)
* **Framework:** Next.js (used purely for API routes)
* **Database:** PostgreSQL (hosted remotely, e.g., Supabase/Neon)
* **ORM:** Prisma
* **Authentication:** Custom JWT-based authentication
* **AI Integration:** Google Generative AI (`gemini-1.5-flash`) for OCR and carbon estimation

### 2. Frontend (Mobile App)
* **Framework:** Flutter
* **Language:** Dart
* **State Management:** Riverpod
* **Routing:** GoRouter
* **Local Storage:** Flutter Secure Storage (for JWT tokens)

---

## 🛠️ Developer Setup Guide

Follow these steps to run the project locally.

### Prerequisites
- [Node.js](https://nodejs.org/) (v18 or higher)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable)
- Android Studio or Xcode (for mobile emulators)
- PostgreSQL database instance

### 1. Backend Setup (Next.js API)

1. **Navigate to the root directory:**
   ```bash
   cd carbon-emission-awareness-platform
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Environment Variables:**
   Create a `.env` file in the root directory and add the following:
   ```env
   # Database connection string
   DATABASE_URL="postgresql://user:password@host:port/dbname?schema=public"
   
   # JWT Secret for authentication
   JWT_SECRET="your-super-secret-key"
   
   # Google Gemini API Key for OCR features
   GEMINI_API_KEY="your-gemini-api-key"
   ```

4. **Initialize the Database:**
   Push the Prisma schema to your PostgreSQL database:
   ```bash
   npx prisma db push
   ```
   *(Optional)* Seed the database if you have a seed script:
   ```bash
   npx prisma db seed
   ```

5. **Start the API Server:**
   ```bash
   npm run dev
   ```
   The backend will start at `http://localhost:3000`.

### 2. Frontend Setup (Flutter App)

1. **Navigate to the Flutter directory:**
   ```bash
   cd carbon_twin
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Environment Variables:**
   Create a `.env` file in the `carbon_twin` directory. This points the app to your backend:
   ```env
   # Use your machine's local IP (e.g., 192.168.x.x) if testing on a physical device
   # Use 10.0.2.2 if testing on an Android Emulator
   # Use localhost if testing on an iOS Simulator
   API_BASE_URL="http://10.0.2.2:3000"
   ```

4. **Fix Windows Incremental Build Bug (If on Windows):**
   Ensure `android/gradle.properties` has `kotlin.incremental=false` to prevent cross-drive caching errors.

5. **Run the App:**
   Make sure you have an emulator running or a device connected, then execute:
   ```bash
   flutter run
   ```

---

## 📂 Folder Structure

```text
/
├── carbon_twin/           # Flutter Mobile Application
│   ├── android/           # Android native code
│   ├── ios/               # iOS native code
│   ├── lib/               # Dart source code (screens, widgets, providers)
│   └── pubspec.yaml       # Flutter dependencies
│
├── prisma/                # Database schema
│   └── schema.prisma      # Models (User, Activity, Reward, etc.)
│
├── src/                   # Backend Next.js API
│   ├── app/
│   │   ├── api/           # REST API endpoints (/auth, /dashboard, etc.)
│   │   └── page.js        # API Landing Page
│   └── lib/               # Utility functions (db.js, auth.js, gemini.js)
│
├── .env                   # Backend environment variables
└── package.json           # Node.js dependencies
```

## 🤝 Contributing
1. Fork the repository
2. Create a new feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: added amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
