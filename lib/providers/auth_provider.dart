import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/models/user_model.dart';
import 'package:expense_tracker/services/auth_service.dart';
import 'package:expense_tracker/services/category_service.dart';

final authServiceProvider = Provider((ref) => AuthService());
final categoryServiceProvider = Provider((ref) => CategoryService());

// Current user state
final currentUserProvider = StateProvider<UserModel?>((ref) => null);

// Auth state notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthService _authService;
  final CategoryService _categoryService;

  AuthNotifier(this._authService, this._categoryService) : super(const AsyncValue.data(null));

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(email: email, password: password);
      if (user != null) {
        state = AsyncValue.data(user);
        return true;
      }
      state = const AsyncValue.data(null);
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final success = await _authService.register(
        username: username,
        email: email,
        password: password,
      );
      
      if (success) {
        // Login after successful registration
        final user = await _authService.login(email: email, password: password);
        if (user != null) {
          // Initialize default categories for new user
          await _categoryService.initializeDefaultCategories(user.id!);
          state = AsyncValue.data(user);
          return true;
        }
      }
      state = const AsyncValue.data(null);
      return false;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  void logout() {
    _authService.logout();
    state = const AsyncValue.data(null);
  }

  Future<bool> updateProfile(UserModel user) async {
    try {
      final success = await _authService.updateProfile(user);
      if (success) {
        state = AsyncValue.data(user);
      }
      return success;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final user = state.value;
    if (user == null) return false;
    
    return await _authService.changePassword(
      userId: user.id!,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  final categoryService = ref.watch(categoryServiceProvider);
  return AuthNotifier(authService, categoryService);
});
