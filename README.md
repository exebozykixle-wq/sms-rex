# 🐍 SMS REX

**Global. Private. Powerful.**

Ek powerful messaging app jo aapke phone ke notifications forward karta hai — sabko ya selected logo ko!

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 Register/Login | Email + Password se secure login |
| 🌍 Global Mode | Sabhi registered users ko message bhejo |
| 🔒 Private Mode | Sirf selected users ko bhejo (saved list) |
| ⚡ Auto Mode | Phone notifications automatically forward ho |
| 📱 App Whitelist | Choose karo kaun se apps ka notification forward ho |
| 💬 Multi-Channel | SMS, Gmail, App notification, WhatsApp |
| 🟢 Online Status | Users ka online/offline status (privacy control ke saath) |
| 📜 History | Purane messages dekho aur delete karo |
| ⚙️ Settings | Privacy controls, online status toggle |

---

## 🚀 Setup Guide

### Step 1: Firebase Setup Karo
Firebase_SETUP.md file padho — sab kuch step by step likha hai.

### Step 2: GitHub pe Upload Karo

```bash
# Pehli baar
git init
git add .
git commit -m "SMS REX initial commit"
git branch -M main
git remote add origin https://github.com/AAPKA_USERNAME/sms-rex.git
git push -u origin main
```

### Step 3: GitHub Secret Add Karo

1. GitHub repo → Settings → Secrets and variables → Actions
2. **New repository secret** click karo
3. Name: `GOOGLE_SERVICES_JSON`
4. Value: `google-services.json` ka POORA content paste karo
5. Save karo

### Step 4: APK Download Karo

1. GitHub → Actions tab
2. Build complete hone ka wait karo (5-10 min)
3. **SMS-REX-release-apk** download karo
4. Phone pe install karo!

---

## 📁 Project Structure

```
sms_rex/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── theme/
│   │   └── app_theme.dart           # Dark theme
│   ├── screens/
│   │   ├── splash_screen.dart       # Splash
│   │   ├── auth/
│   │   │   ├── login_screen.dart    # Login
│   │   │   └── register_screen.dart # Register + Permissions
│   │   ├── home/
│   │   │   └── home_screen.dart     # Main screen
│   │   ├── compose/
│   │   │   └── compose_screen.dart  # Message likhna + channel select
│   │   ├── private/
│   │   │   └── private_list_screen.dart # Private users manage
│   │   ├── history/
│   │   │   └── history_screen.dart  # Message history
│   │   └── settings/
│   │       ├── settings_screen.dart  # Settings
│   │       └── whitelist_screen.dart # Apps whitelist
│   └── services/
│       └── notification_forward_service.dart # Auto forward logic
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml      # Sab permissions
├── .github/
│   └── workflows/
│       └── build-apk.yml            # Auto APK build
├── pubspec.yaml                     # Dependencies
└── FIREBASE_SETUP.md               # Firebase guide
```

---

## 🔧 Tech Stack

- **Flutter** (Dart) — Cross-platform UI
- **Firebase Auth** — Secure login/register
- **Cloud Firestore** — Real-time database
- **Firebase FCM** — Push notifications
- **Telephony** — SMS bhejne ke liye
- **GitHub Actions** — Auto APK build

---

## 📱 Permissions Required

| Permission | Kyu Chahiye |
|---|---|
| SMS | Messages padhna aur bhejana |
| Notification Listener | Dusre apps ke notifications forward karna |
| Contacts | Private list ke liye |
| Phone State | Call notifications |
| Internet | Firebase ke liye |

---

Made with 🐍 by SMS REX Team
