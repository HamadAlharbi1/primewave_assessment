import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:primewave_assessment/services/local_storage_service.dart';

/// Authentication states
enum AuthState { unauthenticated, authenticated, loading, error }

/// User authentication data
class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final DateTime? lastLogin;

  const AuthUser({required this.id, required this.email, required this.name, this.avatar, this.lastLogin});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'avatar': avatar, 'lastLogin': lastLogin?.toIso8601String()};
  }
}

/// Authentication service for managing user sessions
class AuthService {
  static AuthService? _instance;
  LocalStorageService? _storageService;

  AuthState _authState = AuthState.unauthenticated;
  AuthUser? _currentUser;
  String? _authToken;

  AuthService._();

  /// Singleton instance
  static Future<AuthService> getInstance() async {
    _instance ??= AuthService._();
    _instance!._storageService ??= await LocalStorageService.getInstance();
    await _instance!._loadStoredAuth();
    return _instance!;
  }

  /// Current authentication state
  AuthState get authState => _authState;

  /// Current authenticated user
  AuthUser? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _authState == AuthState.authenticated;

  /// Get current auth token
  String? get authToken => _authToken;

  /// Load stored authentication data
  Future<void> _loadStoredAuth() async {
    try {
      final token = _storageService!.getString('auth_token');
      final userJson = _storageService!.getString('current_user');

      if (token != null && userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        _authToken = token;
        _currentUser = AuthUser.fromJson(userData);
        _authState = AuthState.authenticated;

        if (kDebugMode) {
          print('✅ Stored authentication loaded');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load stored auth: $e');
      }
      await _clearStoredAuth();
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signIn(String email, String password) async {
    try {
      _authState = AuthState.loading;

      // Simulate API call (replace with actual authentication endpoint)
      final response = await _simulateSignIn(email, password);

      if (response['success'] == true) {
        _authToken = response['token'] as String;
        _currentUser = AuthUser.fromJson(response['user'] as Map<String, dynamic>);
        _authState = AuthState.authenticated;

        // Store authentication data
        await _storeAuthData();

        if (kDebugMode) {
          print('✅ User signed in successfully');
        }

        return AuthResult.success(_currentUser!);
      } else {
        _authState = AuthState.unauthenticated;
        return AuthResult.failure(response['message'] as String);
      }
    } catch (e) {
      _authState = AuthState.error;
      if (kDebugMode) {
        print('❌ Sign in failed: $e');
      }
      return AuthResult.failure('Sign in failed: $e');
    }
  }

  /// Sign up with email and password
  Future<AuthResult> signUp(String email, String password, String name) async {
    try {
      _authState = AuthState.loading;

      // Simulate API call (replace with actual registration endpoint)
      final response = await _simulateSignUp(email, password, name);

      if (response['success'] == true) {
        _authToken = response['token'] as String;
        _currentUser = AuthUser.fromJson(response['user'] as Map<String, dynamic>);
        _authState = AuthState.authenticated;

        // Store authentication data
        await _storeAuthData();

        if (kDebugMode) {
          print('✅ User signed up successfully');
        }

        return AuthResult.success(_currentUser!);
      } else {
        _authState = AuthState.unauthenticated;
        return AuthResult.failure(response['message'] as String);
      }
    } catch (e) {
      _authState = AuthState.error;
      if (kDebugMode) {
        print('❌ Sign up failed: $e');
      }
      return AuthResult.failure('Sign up failed: $e');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      // Clear stored authentication data
      await _clearStoredAuth();

      // Reset state
      _authState = AuthState.unauthenticated;
      _currentUser = null;
      _authToken = null;

      if (kDebugMode) {
        print('✅ User signed out');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out failed: $e');
      }
    }
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      if (_authToken == null) return false;

      // Simulate token refresh API call
      final response = await _simulateRefreshToken();

      if (response['success'] == true) {
        _authToken = response['token'] as String;
        await _storageService!.setString('auth_token', _authToken!);

        if (kDebugMode) {
          print('✅ Token refreshed successfully');
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Token refresh failed: $e');
      }
      return false;
    }
  }

  /// Store authentication data locally
  Future<void> _storeAuthData() async {
    if (_authToken != null && _currentUser != null) {
      await _storageService!.setString('auth_token', _authToken!);
      await _storageService!.setString('current_user', jsonEncode(_currentUser!.toJson()));
    }
  }

  /// Clear stored authentication data
  Future<void> _clearStoredAuth() async {
    await _storageService!.setString('auth_token', '');
    await _storageService!.setString('current_user', '');
  }

  /// Simulate sign in API call (replace with actual implementation)
  Future<Map<String, dynamic>> _simulateSignIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Simulate validation
    if (email.isEmpty || password.isEmpty) {
      return {'success': false, 'message': 'Email and password are required'};
    }

    if (email == 'test@example.com' && password == 'password') {
      return {
        'success': true,
        'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': '1',
          'email': email,
          'name': 'Test User',
          'avatar': null,
          'lastLogin': DateTime.now().toIso8601String(),
        },
      };
    }

    return {'success': false, 'message': 'Invalid credentials'};
  }

  /// Simulate sign up API call (replace with actual implementation)
  Future<Map<String, dynamic>> _simulateSignUp(String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Simulate validation
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      return {'success': false, 'message': 'All fields are required'};
    }

    if (password.length < 6) {
      return {'success': false, 'message': 'Password must be at least 6 characters'};
    }

    return {
      'success': true,
      'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'email': email,
        'name': name,
        'avatar': null,
        'lastLogin': DateTime.now().toIso8601String(),
      },
    };
  }

  /// Simulate token refresh API call (replace with actual implementation)
  Future<Map<String, dynamic>> _simulateRefreshToken() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    return {'success': true, 'token': 'refreshed_jwt_token_${DateTime.now().millisecondsSinceEpoch}'};
  }
}

/// Authentication result
class AuthResult {
  final bool isSuccess;
  final AuthUser? user;
  final String? errorMessage;

  AuthResult._(this.isSuccess, this.user, this.errorMessage);

  factory AuthResult.success(AuthUser user) {
    return AuthResult._(true, user, null);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(false, null, message);
  }
}
