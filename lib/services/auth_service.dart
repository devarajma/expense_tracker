import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/models/user_model.dart';
import 'package:expense_tracker/utils/constants.dart';
import 'package:expense_tracker/utils/helpers.dart';

class AuthService {
  final _db = DatabaseHelper.instance;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  // Register new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Check if email already exists
      final existingUsers = await _db.queryWhere(
        AppStrings.tableUsers,
        'email = ?',
        [email],
      );

      if (existingUsers.isNotEmpty) {
        return false; // Email already exists
      }

      final user = UserModel(
        username: username,
        email: email,
        password: Helpers.hashPassword(password),
        createdAt: DateTime.now(),
      );

      final id = await _db.insert(AppStrings.tableUsers, user.toMap());
      return id > 0;
    } catch (e) {
      return false;
    }
  }

  // Login user
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final hashedPassword = Helpers.hashPassword(password);
      final users = await _db.queryWhere(
        AppStrings.tableUsers,
        'email = ? AND password = ?',
        [email, hashedPassword],
      );

      if (users.isEmpty) {
        return null;
      }

      _currentUser = UserModel.fromMap(users.first);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserModel user) async {
    try {
      final result = await _db.update(AppStrings.tableUsers, user.toMap());
      if (result > 0) {
        _currentUser = user;
      }
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final users = await _db.queryWhere(
        AppStrings.tableUsers,
        'id = ? AND password = ?',
        [userId, Helpers.hashPassword(oldPassword)],
      );

      if (users.isEmpty) {
        return false; // Old password incorrect
      }

      final user = UserModel.fromMap(users.first);
      final updatedUser = user.copyWith(
        password: Helpers.hashPassword(newPassword),
      );

      final result = await _db.update(
        AppStrings.tableUsers,
        updatedUser.toMap(),
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  // Logout
  void logout() {
    _currentUser = null;
  }

  // Get user by ID
  Future<UserModel?> getUserById(int id) async {
    try {
      final users = await _db.queryWhere(
        AppStrings.tableUsers,
        'id = ?',
        [id],
      );

      if (users.isEmpty) return null;
      return UserModel.fromMap(users.first);
    } catch (e) {
      return null;
    }
  }
}
