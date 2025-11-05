import 'package:firebase_auth/firebase_auth.dart';

/// Contract consumed by the global controller for user-related queries.
abstract class UserServiceInterface {
  Future<String?> getEmployeeIdFromUser(User authUser);
}
