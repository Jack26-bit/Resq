# ResQ — AI-Powered Disaster Response System

🌍 **Overview**  
ResQ is an intelligent disaster response platform designed to function even when networks fail.  
It combines AI, offline mesh networking, and real-time emergency coordination to provide a reliable lifeline during critical situations.

⚡ Built for real-world emergencies: disasters, blackouts, war zones, and no-signal environments.

## 📲 Install APK

Use the ready-to-install APK here:

[ResQ.apk](C:/Users/JERANTJENCATH/Desktop/ResQ.apk)

### Quick Access

- Open APK: [ResQ.apk](C:/Users/JERANTJENCATH/Desktop/ResQ.apk)
- Exact file path: `C:\Users\JERANTJENCATH\Desktop\ResQ.apk`
- Install: Transfer the APK to your Android device and open it to install

## 🚨 Core Features

### 🔴 Panic-Ping (SOS System)
- One-tap emergency trigger
- Sends:
  - 📍 Location
  - 📸 Images / 🎥 Video
  - ⚠️ Emergency type (Medical, Fire, Structural, Trapped)
- AI-assisted detection (ML Kit)
- Works online + offline

### 📡 Offline Mesh Network
- Peer-to-peer communication (Nearby Connections)
- No internet required
- Forms a local emergency communication network

### 🧠 AI Assistance
- Smart object detection (ML Kit)
- Context-aware emergency guidance
- Voice + text interaction

### 🎙️ Voice Agent
- Hands-free emergency interaction
- Calm AI responses (ElevenLabs integration)
- Designed for panic scenarios

### 🗺️ Tactical Map System
- Online: Live maps & updates
- Offline: Grid-based fallback
- Shows:
  - Safe zones
  - Nearby responders
  - Active SOS signals

### ⚔️ Disaster & War Modes
- Predefined emergency protocols
- Optimized UI for high-risk environments

### 🤝 Community Response
- Peer-to-peer assistance
- Nearby responders
- Decentralized rescue coordination

## 📱 App Screens

- `/` → Signup / Login
- `/home` → Dashboard
- `/sos` → SOS Report
- `/map` → Tactical Map
- `/community` → Community Help
- `/local` → Local Incidents
- `/disaster` → Disaster Mode
- `/war` → War Mode
- `/mesh` → Offline Mesh Chat

## 🧠 Architecture

```text
            ┌────────────────────────────┐
            │        ResQ App UI         │
            │  (SOS, Map, Mesh, AI UI)   │
            └────────────┬───────────────┘
                         │
         ┌───────────────┼────────────────┐
         │               │                │
         ▼               ▼                ▼
 ┌────────────┐  ┌──────────────┐  ┌──────────────┐
 │ ML Kit AI  │  │ Mesh Network │  │ Voice Agent  │
 │ Detection  │  │ (P2P Nearby) │  │ (ElevenLabs) │
 └────────────┘  └──────────────┘  └──────────────┘
         │               │                │
         └───────┬───────┴───────┬────────┘
                 ▼               ▼
          ┌──────────────┐  ┌──────────────┐
          │ Firebase     │  │ Google Cloud │
          │ Firestore    │  │ APIs         │
          │ Auth + FCM   │  │ Maps/Weather │
          └──────────────┘  └──────────────┘
```

## 🚀 Tech Stack

- **Frontend:** Flutter
- **Backend:** Firebase (Firestore, Auth, FCM)
- **AI:** Google Gemini + ML Kit
- **Voice AI:** ElevenLabs
- **Connectivity:** Nearby Connections (P2P Mesh)
- **APIs:** Google Maps, Weather, Solar

## ⚙️ How to Run the Project

### 1️⃣ Install Dependencies

```bash
flutter pub get
```

### 2️⃣ Run the App

```bash
flutter devices

flutter run -d chrome
flutter run -d emulator-5554
flutter run -d iPhone
```

### 3️⃣ Build APK (IMPORTANT)

```bash
flutter build apk --release
```

📦 Output file:

```text
build/app/outputs/flutter-apk/app-release.apk
```

👉 Use this APK for:
- Demo submission
- Judge testing
- Direct installation

If you want the exact ready-made APK file, use:

[ResQ.apk](C:/Users/JERANTJENCATH/Desktop/ResQ.apk)

### 4️⃣ Run Web Version (Optional)

```bash
flutter build web
cd build/web
python3 -m http.server 8080
```

Open:

```text
http://localhost:8080
```

## 📦 Dependencies

- `google_fonts`
- `flutter_animate`
- `google_maps_flutter`
- `firebase_core`
- `nearby_connections`
- `cryptography`
- `uuid`
- `shared_preferences`

## 🌐 Connectivity Behavior

| Feature | Online | Offline |
|---|---|---|
| SOS | Cloud sync | Mesh broadcast |
| AI | Advanced | Basic/local |
| Maps | Full maps | Grid fallback |
| Communication | Internet | P2P |

## 🎨 Design System

- **Background:** `#131313`
- **Primary:** `#FFFFFF`
- **Accent:** Cyan / Teal
- **Error:** `#FFB4AB`
- **Fonts:**
  - SpaceGrotesk (Headlines)
  - Inter (Body)

## 🏆 Why ResQ Stands Out

- Works without internet
- Real-time Panic-Ping emergency system
- Combines AI + Voice + Mesh Networking
- Built using Google technologies
- Designed for real disaster survival

## ⚠️ Disclaimer

ResQ provides AI-assisted guidance and emergency communication tools.  
Always follow official emergency services when available.

## 🧠 Tagline

“Intelligence that survives.”
