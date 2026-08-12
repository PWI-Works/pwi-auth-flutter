# PwiAuth

PwiAuth is a Flutter package that provides authentication functionalities for the PWI application. It simplifies the process of user authentication by integrating with Firebase Authentication and handling session management, sign-in, sign-up, password reset, and more.

## Features

- **Email and Password Authentication**
- **Microsoft Sign-In Authentication**
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
  - [Sign Out](#sign-out)
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
- **Firebase Authentication**: Enable Email/Password and Microsoft methods in your Firebase console.
- **Backend Endpoint**: A backend server endpoint that handles session cookies and authentication status (`_endPoint`).

## Setup

### 1. Add Firebase to Your Flutter App

Follow the official Firebase documentation to add Firebase to your Flutter app:

- [Adding Firebase to your Flutter App](https://firebase.google.com/docs/flutter/setup)

### 2. Configure Firebase Authentication

- Enable **Email/Password** and **Microsoft** in your [Firebase console](https://console.firebase.google.com/).

### 3. Set Up Backend Endpoints

Your backend should handle the following API endpoints:

- `POST /api/set-session-cookie`: Sets a session cookie using the provided ID token.
- `GET /api/auth-status`: Checks the authentication status and returns a custom token if signed in.
- `POST /api/clear-session-cookie`: Clears the session cookie.

Ensure your backend sets cookies with the `HttpOnly` and `Secure` flags.

---

## Testing
You can test package functionality by running the app in `example`. 

For convenience, we've already added a run configuration for VS Code. Pressing `F5` should run it right away.

It's important to note that you must run `flutter pub upgrade` _from the example folder_ whenever you make changes to the package code.

Note that the package import in `example/pubspec.yaml` is a relative import, meaning that it uses the local version of `pwi_auth`. You have immediate access to any code changes you make in the `pwi_auth` package without having to wait for it to be published.

## Usage

### Data repositories

`BaseDataStreamRepository<T>` retains its existing subclass and consumer API.
Consumers call `addListener(callback)` and pair every registration with
`removeListener(callback)`; the shared stream is active only while those
repository consumers exist. The older `subscribeToData(callback)` and
`unsubscribeFromData(callback)` methods remain compatible but are deprecated.
No immediate consumer migration is required; new code should use the standard
listener names.

`BaseDataFetchRepository<T>` supports one immediate Future-based fetch followed
by optional daily, fixed-delay interval, or no automatic refresh. Its default is
daily refresh at local midnight. In both repository types, `data.value == null`
means not loaded or inactive. A successful empty collection remains a loaded
empty collection and is not converted to `null`.

Configure a daily refresh at 1:00 a.m. like this:

```dart
class MyRepository extends BaseDataFetchRepository<MyData> {
  MyRepository()
      : super(
          refreshSchedule: DataRefreshSchedule.daily,
          timeOfDay: const TimeOfDay(hour: 1, minute: 0),
        );

  @override
  Future<MyData> fetchData() => service.fetchData();
}
```

For an interval, use `refreshSchedule: DataRefreshSchedule.interval` with
`numberOfMinutes: 30`. To disable automatic refresh, use
`refreshSchedule: DataRefreshSchedule.never`. All three options still perform
the initial fetch when the first consumer subscribes.

Both repository bases support `resetData()` while active. It clears retained
data, restarts the source lifecycle, and reloads the authoritative value. This
can be used to recover from a failed optimistic update without requiring the
repository base to define an optimistic-state system. The existing
`BaseDataStreamRepository.resetStream()` method remains available and performs
the same reset workflow for backward compatibility. For an interval-based fetch
repository, resetting also replaces the pending timer: the next automatic fetch
waits the full `numberOfMinutes` interval after the replacement fetch completes.
Daily repositories recalculate their next configured wall-clock time.

Fetch failures are contained by the repository so background attempts do not
become uncaught asynchronous errors. Override `onFetchError(error, stackTrace)`
to send failures to application logging or monitoring. Failed refreshes retain
the last successful value and do not disable later scheduled attempts.

Import these APIs from
`package:pwi_auth/data/repositories/base_data_stream_repository.dart` or
`package:pwi_auth/data/repositories/base_data_fetch_repository.dart`.

### Import the Package

```dart
import 'package:pwi_auth/pwi_auth.dart';
```

### Initialize PwiAuth

Create an instance of `PwiAuth` by providing your backend endpoint. Replace `'your-backend-endpoint.com'` with your actual endpoint.

**Note:** this is only necessary if you are actually using the authentication code. Otherwise, you don't need to initialize anything.

```dart
final pwiAuth = PwiAuth('your-backend-endpoint.com', loggingEnabled: true);
```

- **`_endPoint`**: The URL of your backend server handling authentication.
- **`loggingEnabled`** _(optional)_: Set to `true` to enable logging for debugging purposes.


### Sign Out

```dart
await pwiAuth.signOut();
print('User signed out');
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

---

## Methods

- **`PwiAuth(String _endPoint, {bool loggingEnabled = false})`**: Constructor to create an instance of `PwiAuth`.

- **`Future<void> signIn({required String email, required String password})`**: Signs in a user with email and password.

- **`Future<void> signUp({required String email, required String password, required String firstName, required String lastName})`**: Creates a new user account.

- **`Future<void> signInWithMicrosoft()`**: Signs in a user using Microsoft authentication.

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
