// providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../utils/database_helper.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final _db = DatabaseHelper();
  final _uuid = const Uuid();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.unknown;

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      final user = await _db.getUserById(userId);
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> register(String name, String email, String password) async {
    _errorMessage = null;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _errorMessage = 'All fields are required.';
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _errorMessage = 'Please enter a valid email address.';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Password must be at least 6 characters.';
      notifyListeners();
      return false;
    }

    final existing = await _db.getUserByEmail(email);
    if (existing != null) {
      _errorMessage = 'An account with this email already exists.';
      notifyListeners();
      return false;
    }

    final user = UserModel(
      id: _uuid.v4(),
      name: name,
      email: email,
      passwordHash: _hashPassword(password),
    );

    await _db.insertUser(user);
    await _saveSession(user.id);

    _currentUser = user;
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;

    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Please enter your email and password.';
      notifyListeners();
      return false;
    }

    final user = await _db.getUserByEmail(email);
    if (user == null) {
      _errorMessage = 'No account found with this email.';
      notifyListeners();
      return false;
    }

    if (user.passwordHash != _hashPassword(password)) {
      _errorMessage = 'Incorrect password.';
      notifyListeners();
      return false;
    }

    await _saveSession(user.id);
    _currentUser = user;
    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}