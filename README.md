
# Courses Tracker - for Uni Mobile Apps with Flutter

This is a mobile app built with Flutter designed to help users track and manage their courses. It allows users to monitor their progress across different courses, whether they are online, offline, or self-paced. The app integrates Firebase for backend and storage and provides a seamless user experience for managing learning activities.

## Features

- **User Authentication**: Sign up, log in, and manage user accounts using Firebase Authentication.
- **Course Management**: Add, edit, and delete courses, and track progress with percentage and status updates.
- **Firebase Integration**: All user data and course details are stored securely in Firestore.
- **Responsive UI**: Simple and intuitive design for easy navigation on mobile devices.
- **Offline Support**: Local data storage using shared preferences for a better offline experience.

# Getting Started

To get started with this project, follow the steps below:

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install/macos/mobile-ios)
- [Firebase account and project set up in Firebase Console](https://console.firebase.google.com/project/courses-tracker-57856/overview)
- IDE (VS Code, Android Studio, etc.)

## Installation

Clone the repository to your local machine:

```bash
git clone https://github.com/GabrielFlorea01/uni_mobile_app.git
```

### Install dependencies

```bash
flutter pub get
```


### Firebase Setup

For Firebase authentication and Firestore to work, you'll need to follow these steps:

  

- Create a [Firebase project](https://console.firebase.google.com/u/0/) if you don’t have one already.

- Enable Firebase Authentication for your project.

- Set up Firestore database to store course details.

- Follow the instructions in the FlutterFire documentation to connect your Flutter app with Firebase.


## Run the app

```bash
flutter run
```

  

## Project Structure

  

**lib/** - Contains the Flutter app code.

**ios/** - Contains the files for running the IOS app.

**assets/** - Stores images and other static resources.

  
## Acknowledgments

[Flutter](https://flutter.dev/) for providing a powerful framework for cross-platform mobile development.

[Firebase](https://firebase.google.com/) for providing backend services.
