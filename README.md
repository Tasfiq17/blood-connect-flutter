<div align="center">

# 🩸 Blood Connect

### Connecting Blood Donors with People in Need

**A Flutter mobile application powered by Firebase to simplify blood donation, donor discovery, and blood requests.**

[![Flutter](https://img.shields.io/badge/Flutter-Mobile_App-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![GitHub](https://img.shields.io/badge/Source-GitHub-181717?logo=github)](https://github.com/Tasfiq17/blood-connect-flutter)

[Features](#-features) • [Technology](#-technology-stack) • [Getting Started](#-getting-started) • [Project Structure](#-project-structure)

</div>

---

## 📖 Overview

**Blood Connect** is a mobile application built with Flutter and Firebase to help connect potential blood donors with people who need blood. The application brings donor discovery, blood requests, donation records, and profile management together in one interface.

The project was developed to make the blood donation process easier to organize and navigate. It is a software platform, not an emergency response or medical verification service.

## ✨ Features

The codebase includes screens and services for:

- **User authentication:** Account registration, sign-in, and authentication-aware navigation using Firebase Authentication.
- **Dashboard:** Firestore-backed streams for user, donor, and request statistics.
- **Find donors:** Search available donors by blood group and district.
- **Blood requests:** Create requests, browse requests, and view a user's request history.
- **Donation history:** Log donations and view personal donation records.
- **Donor availability:** Update whether a user is listed as a donor.
- **Profiles and settings:** View and update profile information.
- **Notifications interface:** A dedicated notifications screen in the application.
- **Blood-group statistics:** Live donor counts for A+, A−, B+, B−, O+, O−, AB+, and AB−.

> **Development note:** The repository includes these interfaces and service methods. Feature completeness, permissions, and end-to-end behavior should be verified against the current app build before production use.

## 🛠️ Technology Stack

| Layer | Technology |
| --- | --- |
| Mobile UI | Flutter, Dart |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Backend services | Firebase |
| Development environment | Android Studio / VS Code |
| Version control | Git and GitHub |

## 📱 Screenshots

Add screenshots to `screenshots/` and replace the placeholders below with your own images.

| Splash | Login | Dashboard |
| --- | --- | --- |
| *Screenshot coming soon* | *Screenshot coming soon* | *Screenshot coming soon* |

| Registration | Find Donor | Blood Request |
| --- | --- | --- |
| *Screenshot coming soon* | *Screenshot coming soon* | *Screenshot coming soon* |

For example, after adding images, use:

```markdown
![Blood Connect Dashboard](screenshots/dashboard.png)
```

## 🗂️ Project Structure

```text
blood/
├── android/                  # Android platform project
├── ios/                      # iOS platform project
├── assets/
│   └── images/               # Application images and logo
├── lib/
│   ├── constants/            # Colors, images, and strings
│   ├── models/               # User, request, and donation models
│   ├── screens/              # App screens and navigation
│   ├── services/             # Authentication and Firestore logic
│   ├── theme/                # Application theme
│   ├── widgets/              # Reusable UI components
│   ├── firebase_options.dart # FlutterFire client configuration
│   └── main.dart             # Application entry point
├── test/                     # Flutter tests
├── pubspec.yaml              # Packages and assets
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart SDK (included with Flutter)
- Android Studio or VS Code
- Android emulator or a physical device
- A Firebase project with Authentication and Cloud Firestore configured
- [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup) if configuring Firebase for your own project

### 1. Clone the repository

```bash
git clone https://github.com/Tasfiq17/blood-connect-flutter.git
cd blood-connect-flutter
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

If you are running your own deployment, create a Firebase project and configure the Flutter application to use it. Enable the required sign-in provider in **Firebase Authentication**, create a **Cloud Firestore** database, and apply appropriate security rules.

From the project directory, follow the [official FlutterFire setup guide](https://firebase.google.com/docs/flutter/setup) and run:

```bash
flutterfire configure
```

This generates or updates platform Firebase configuration and `lib/firebase_options.dart`. Ensure the app's Android package identifier and any other platform identifiers match your Firebase registration.

**Security:** Firebase client configuration is not an Admin SDK private key. Never commit service-account credentials, signing keys, or `.env` files containing secrets. Restrict Firestore access with security rules that protect user profiles, phone numbers, blood requests, and donation records.

### 4. Run the app

```bash
flutter run
```

To inspect available devices:

```bash
flutter devices
```

To create a release APK for testing:

```bash
flutter build apk --release
```

The output is typically available at `build/app/outputs/flutter-apk/app-release.apk`. Configure release signing and test the build before distributing it.

## 🔥 Firestore Data Model

The application services reference these top-level collections:

| Collection | Purpose |
| --- | --- |
| `users` | User profiles, blood groups, districts, and donor availability |
| `requests` | Blood requests, request owners, and creation timestamps |
| `donations` | Donation logs and user donation history |

The exact document fields are defined in the Dart models and services. Some filtered and ordered queries may require Firestore composite indexes.

## 🔐 Privacy and Safety

Blood Connect handles potentially sensitive personal and contact information. Before public deployment:

- Enforce authentication and least-privilege authorization with Firestore Security Rules.
- Restrict profile updates so users cannot modify other users' protected fields.
- Limit exposure of phone numbers and personal details to authorized users.
- Validate blood requests and donation entries; do not treat self-reported information as medically verified.
- Provide an appropriate privacy policy and a way for users to manage their data.

## 🧭 Future Improvements

- Push notifications for relevant blood requests
- Better request status tracking and fulfillment workflows
- Donor eligibility and last-donation reminders
- More advanced filtering and location-based discovery
- Automated tests and accessibility improvements
- Administrative moderation and reporting tools

## 👨‍💻 Developer

**Tasfiq17**  
GitHub: [github.com/Tasfiq17](https://github.com/Tasfiq17)

## 🤝 Contributions

Suggestions, bug reports, and improvements are welcome through GitHub Issues and pull requests.

---

<div align="center">

**Made with Flutter ❤️ to support blood donation.**

</div>
