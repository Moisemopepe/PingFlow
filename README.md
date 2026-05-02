# PingFlow

PingFlow is a professional Flutter Android prototype for network diagnostics: ping, traceroute, network information, speed test, history, and settings.

## Run

Install Flutter. If this folder has not been initialized with Flutter platform
files yet, run this once:

```powershell
flutter create --platforms=android .
```

Then run:

```powershell
flutter pub get
flutter run
```

## Backend API

PingFlow uses a local Node.js backend for real `ping`, `traceroute`, and speed-test transfer endpoints.

Start it before running the Android app:

```powershell
cd backend
npm start
```

The Flutter app defaults to `http://10.0.2.2:8787`, which is the Android emulator alias for your computer. For a real phone, run the backend on your computer and start Flutter with your computer LAN IP:

```powershell
flutter run --dart-define=PINGFLOW_API_BASE_URL=http://YOUR_PC_IP:8787
```

For a public app, deploy the backend to a public HTTPS host and build the app
with that URL:

```powershell
flutter build appbundle --release --dart-define=PINGFLOW_API_BASE_URL=https://YOUR_BACKEND_URL
```

The backend includes a Dockerfile because production Linux hosts need the
system tools used by PingFlow:

- `iputils-ping` for ping diagnostics
- `traceroute` for traceroute diagnostics

Render/Railway/Fly.io or a VPS can run this backend. Serverless platforms that
block long-running processes or OS network commands are not a good fit for the
current diagnostic API.

## Build Android Release

```powershell
flutter build appbundle --release
```

The diagnostic layer is isolated in `lib/core/services/diagnostic_service.dart`. The current implementation uses real HTTP calls to the backend and real HTTP upload/download transfers for measurements.

## Architecture

- `lib/app`: app bootstrap, theme, dependency container, shell navigation
- `lib/core`: models, services, repositories, constants, utility logic
- `lib/features`: screen-level modules for dashboard, tools, ping, traceroute, network info, speed test, history, and settings
- `lib/shared`: reusable UI components
