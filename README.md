<div align="center">
  <img src="./public/docs/logo.png" alt="CarbonSense Logo" width="200" style="border-radius: 20px; box-shadow: 0 10px 30px rgba(0, 255, 128, 0.2);" />
  
  <h1>CarbonSense</h1>
  <p><strong>A Next-Generation Carbon Emission Awareness Platform</strong></p>
</div>

---

## 🌟 Overview

**CarbonSense** is a modern, AI-powered platform designed to build awareness around daily carbon emissions. It gamifies sustainability by tracking your habits—like food consumption and daily routines—and visualizes your impact through an interactive **Digital Twin Dashboard**.

Built with the cutting-edge **Next.js 16 App Router**, CarbonSense delivers a seamless, glassmorphic user experience, powered dynamically by **Google's Gemini AI**.

---

## 📸 Application Previews

### Magnetic Parallax Login Experience
Enjoy a buttery-smooth, interactive login card that tracks cursor movement with a 3D magnetic spring effect!

![Interactive Login Animation](./public/docs/login_animation.webp)

![Login Dashboard Loaded](./public/docs/login_snapshot.png)

---

## 🏗️ System Architecture

CarbonSense follows a modern full-stack Serverless architecture:

```mermaid
graph TD
    %% Frontend
    Client[User Browser]
    
    %% Next.js Application
    subgraph "Next.js 16 (App Router)"
        UI[React Server Components / Client Components]
        API[Next.js API Routes]
        Auth[NextAuth.js]
    end
    
    %% External Services
    subgraph "External Cloud Services"
        DB[(Supabase PostgreSQL)]
        Gemini[Google Gemini AI]
        OAuth[Google OAuth]
        Weather[OpenWeatherMap API]
    end
    
    %% Infrastructure
    Deploy((Google Cloud Run))
    
    %% Connections
    Client <-->|HTTPS| UI
    Client <-->|OAuth Flow| OAuth
    UI <--> API
    UI <--> Auth
    Auth <--> OAuth
    API <-->|Prisma ORM| DB
    API <-->|Dynamic Content Gen| Gemini
    API <-->|Live Climate Data| Weather
    
    %% Deployment Context
    UI -.- Deploy
    API -.- Deploy
```

### Tech Stack
- **Frontend**: [Next.js 16](https://nextjs.org), React 19, Vanilla CSS Modules (Glassmorphism).
- **Backend**: Next.js API Routes, Server Actions.
- **Database**: [PostgreSQL (via Supabase)](https://supabase.com) mapped using [Prisma ORM](https://www.prisma.io/).
- **Authentication**: [NextAuth.js (Auth.js)](https://next-auth.js.org/) using Google Provider (`proxy.js` edge middleware).
- **AI Integration**: [Google Generative AI](https://ai.google.dev/) (@google/generative-ai) for calculating footprint approximations from text routines.
- **Hosting**: [Google Cloud Run](https://cloud.google.com/run) via Source Buildpacks.

---

## 🚀 Getting Started for Developers

To run this project locally and contribute, follow these steps:

### 1. Prerequisites
- Node.js `v24+` installed.
- A PostgreSQL database (e.g., Supabase).
- API Keys for Google Maps, Google Gemini, OpenWeatherMap, and Google OAuth credentials.

### 2. Clone and Install
```bash
git clone https://github.com/pratyush06-aec/carbon-emission-awareness-platform.git
cd "carbon emission awareness platform"
npm install
```

### 3. Environment Variables
Create a `.env` file in the root of your project and populate the following secrets:
```env
# Database
DATABASE_URL="postgresql://<user>:<password>@<host>:<port>/<db>"

# APIs
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY="your_maps_key"
GEMINI_API_KEY="your_gemini_key"
OPENWEATHERMAP_API_KEY="your_weather_key"

# Authentication
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="generate_a_secure_random_string"
```

### 4. Database Setup (Prisma)
Initialize the database and generate the Prisma client:
```bash
npm run postinstall
npx prisma db push
```

### 5. Run the Development Server
```bash
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) to view the application in your browser.

---

## ☁️ Deployment

This project is configured for **Google Cloud Run** using source-based deployment (Buildpacks). 

To deploy:
1. Ensure the `gcloud` CLI is installed and authenticated.
2. Run the deployment command passing the required environment variables:
```bash
gcloud run deploy carbonsense \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars="DATABASE_URL=...,GEMINI_API_KEY=...,NEXTAUTH_SECRET=..."
```
3. Once deployed, update your Google OAuth Authorized Origins in the Cloud Console to include the newly generated `.run.app` domain. Update your `NEXTAUTH_URL` environment variable to match.

---

## 📄 License
This project is licensed under the MIT License.
