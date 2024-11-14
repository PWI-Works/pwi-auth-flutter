# PwiAuth

PwiAuth is a Flutter package that provides authentication functionalities for the PWI application. It simplifies the process of user authentication by integrating with Firebase Authentication and handling session management, sign-in, sign-up, password reset, and more.

## Features

- **Email and Password Authentication**
- **Google Sign-In Authentication**
- **Session Management with Custom Tokens**
- **Password Reset Functionality**
- **Authentication State Changes Stream**

---

## Table of Contents

- [Installation](#installation)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
  - [1. Add Firebase to Your Flutter App](#1-add-firebase-to-your-flutter-app)
  - [2. Configure Firebase Authentication](#2-configure-firebase-authentication)
  - [3. Set Up Backend Endpoints](#3-set-up-backend-endpoints)
- [Usage](#usage)
  - [Import the Package](#import-the-package)
  - [Initialize PwiAuth](#initialize-pwiauth)
  - [Sign In with Email and Password](#sign-in-with-email-and-password)
  - [Sign Up (Create a New Account)](#sign-up-create-a-new-account)
  - [Sign In with Google](#sign-in-with-google)
  - [Sign Out](#sign-out)
  - [Send Password Reset Email](#send-password-reset-email)
  - [Listen to Authentication State Changes](#listen-to-authentication-state-changes)
  - [Check if User is Signed In](#check-if-user-is-signed-in)
  - [Navigate to Sign-In or Sign-Up Page](#navigate-to-sign-in-or-sign-up-page)
- [Methods](#methods)
- [Dispose](#dispose)
- [Notes](#notes)
- [Contributing](#contributing)
- [License](#license)

---

## Installation

Add `pwi_auth` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  pwi_auth:
    git:
      url: https://github.com/PWI-Works/pwi-auth-flutter.git
```

Then run:

```bash
flutter pub get
```

## Prerequisites

- **Firebase Project**: You need a Firebase project configured for your Flutter application.
- **Firebase Authentication**: Enable Email/Password and Google Sign-In methods in your Firebase console.
- **Backend Endpoint**: A backend server endpoint that handles session cookies and authentication status (`_endPoint`).

## Setup

### 1. Add Firebase to Your Flutter App

Follow the official Firebase documentation to add Firebase to your Flutter app:

- [Adding Firebase to your Flutter App](https://firebase.google.com/docs/flutter/setup)

### 2. Configure Firebase Authentication

- Enable **Email/Password** and **Google Sign-In** in your [Firebase console](https://console.firebase.google.com/).

### 3. Set Up Backend Endpoints

Your backend should handle the following API endpoints:

- `POST /api/set-session-cookie`: Sets a session cookie using the provided ID token.
- `GET /api/auth-status`: Checks the authentication status and returns a custom token if signed in.
- `POST /api/clear-session-cookie`: Clears the session cookie.

Ensure your backend sets cookies with the `HttpOnly` and `Secure` flags.

---

## Usage

### Import the Package

```dart
import 'package:pwi_auth/pwi_auth.dart';
```

### Initialize PwiAuth

Create an instance of `PwiAuth` by providing your backend endpoint. Replace `'your-backend-endpoint.com'` with your actual endpoint.

```dart
final pwiAuth = PwiAuth('your-backend-endpoint.com', loggingEnabled: true);
```

- **`_endPoint`**: The URL of your backend server handling authentication.
- **`loggingEnabled`** _(optional)_: Set to `true` to enable logging for debugging purposes.

### Sign In with Email and Password

It is preferable to call **`pwiAuth.goToSignIn()`** if you have a hosted sign-in page

```dart
try {
  await pwiAuth.signIn(email: 'user@example.com', password: 'your-password');
  print('User signed in successfully');
} catch (e) {
  print('Sign-in error: $e');
}
```

### Sign Up (Create a New Account)

It is preferable to call **`pwiAuth.goToSignUp()`** if you have a hosted sign-up page

```dart
try {
  await pwiAuth.signUp(
    email: 'newuser@example.com',
    password: 'your-password',
    firstName: 'John',
    lastName: 'Doe',
  );
  print('User signed up successfully');
} catch (e) {
  print('Sign-up error: $e');
}
```

### Sign In with Google

It is preferable to call **`pwiAuth.goToSignIn()`** if you have a hosted sign-in page

```dart
try {
  await pwiAuth.signInWithGoogle();
  print('User signed in with Google successfully');
} catch (e) {
  print('Google sign-in error: $e');
}
```

### Sign Out

```dart
await pwiAuth.signOut();
print('User signed out');
```

### Send Password Reset Email

```dart
try {
  await pwiAuth.sendPasswordResetEmail('user@example.com');
  print('Password reset email sent');
} catch (e) {
  print('Password reset error: $e');
}
```

### Listen to Authentication State Changes

```dart
pwiAuth.authStateChanges.listen((user) {
  if (user != null) {
    print('User is signed in: ${user.email}');
  } else {
    print('User is signed out');
  }
});
```

### Check if User is Signed In

```dart
if (pwiAuth.signedIn) {
  print('User is currently signed in');
} else {
  print('No user is signed in');
}
```

### Navigate to Sign-In or Sign-Up Page

If you have hosted sign-in or sign-up pages, you can navigate to them instead implementing your own UI:

```dart
// Navigate to the sign-up page
await pwiAuth.goToSignUp();

// Navigate to the sign-in page
await pwiAuth.goToSignIn();
```

---

## Methods

- **`PwiAuth(String _endPoint, {bool loggingEnabled = false})`**: Constructor to create an instance of `PwiAuth`.

- **`Future<void> signIn({required String email, required String password})`**: Signs in a user with email and password.

- **`Future<void> signUp({required String email, required String password, required String firstName, required String lastName})`**: Creates a new user account.

- **`Future<void> signInWithGoogle()`**: Signs in a user using Google authentication.

- **`Future<void> signOut()`**: Signs out the current user and clears the session cookie.

- **`Future<void> sendPasswordResetEmail(String email)`**: Sends a password reset email to the provided email address.

- **`Stream<void> get authStateChanges`**: A stream that emits authentication state changes.

- **`bool get signedIn`**: Indicates whether the user is currently signed in.

- **`Future<void> goToSignUp()`**: Navigates the user to the sign-up page.

- **`Future<void> goToSignIn()`**: Navigates the user to the sign-in page.

- **`void dispose()`**: Disposes of resources used by this instance.

---

## Dispose

When you're done using the `PwiAuth` instance (e.g., when the app is closed), make sure to dispose of it to release resources:

```dart
pwiAuth.dispose();
```

---

## Notes

- **Backend Integration**: Ensure your backend endpoint (`_endPoint`) is properly set up to handle session management and communicate with Firebase.
- **Error Handling**: All methods that interact with authentication are asynchronous and may throw exceptions. Use `try-catch` blocks to handle errors gracefully.
- **Logging**: Enable logging by setting `loggingEnabled: true` when initializing `PwiAuth` to assist with debugging.

---

## Contributing

Contributions are welcome! If you have any ideas, suggestions, or find a bug, please open an issue or submit a pull request.

---

_Disclaimer: Replace placeholders like `'your-backend-endpoint.com'`, `'user@example.com'`, and `'your-password'` with your actual backend endpoint and user credentials._
