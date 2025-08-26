// lib/modules/auth/controller/auth_controller.dart
import 'package:flutter/foundation.dart';

import '../model/user.dart';
import '../model/user.dart';
import '../model/user.dart';
import '../repository/auth_repository.dart'; // also exposes ApiException/CooldownException/AuthException

class AuthController extends ChangeNotifier {
  final AuthRepository _repo;
  AuthController(this._repo);

  User? _user;
  bool _loading = false;
  String? _error;
  String? _token;
  bool _initializing = true; // flag to know when init() finished

  // Cooldown flags
  bool _cooldownActive = false;
  DateTime? _retryAt;

  // ---------- Getters ----------
  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  String? get token => _token;
  bool get initializing => _initializing;

  bool get hasToken => _token != null && _token!.isNotEmpty;
  bool get isAuthenticated => _user != null && hasToken;

  bool get cooldownActive => _cooldownActive;
  DateTime? get retryAt => _retryAt;

  bool get hasActiveSubscription => _user?.hasActiveSubscription == true;
  UserSubscriptionSummary? get userSubscription => _user?.subscription;
  // ---------- Session Init ----------
  /// Call once on app start to restore session from local storage + backend.
  Future<void> init() async {
    _initializing = true;
    notifyListeners();
    try {
      _token = await _repo.currentToken();

      if (hasToken) {
        try {
          final u = await _repo.me(); // calls /api/auth/me (NOT gated by usage.window)
          _user = u;
          _cooldownActive = false;
          _retryAt = null;
        } on CooldownException catch (e) {
          // IMPORTANT: keep token; just mark cooldown
          _cooldownActive = true;
          _retryAt = e.retryAt;
          _error = null;
        }
      } else {
        _user = null;
        _cooldownActive = false;
        _retryAt = null;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  // ---------- Refresh ----------
  Future<void> refreshUser() async {
    _setLoading(true);
    try {
      final u = await _repo.me();
      _user = u;
      _token = await _repo.currentToken();
      _cooldownActive = false;
      _retryAt = null;
      _error = null;
    } on CooldownException catch (e) {
      _cooldownActive = true;
      _retryAt = e.retryAt;
      // keep token and user as-is (could be null if first load)
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ---------- Auth Actions ----------
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _user = await _repo.login(email: email, password: password);
      _token = await _repo.currentToken();
      _cooldownActive = false;
      _retryAt = null;
      _error = null;
      return true;
    } on ApiException catch (e) {
      _error = e.message;           // <- clean French text from API
      return false;
    } catch (e) {
      _error = 'Erreur inattendue. Veuillez réessayer.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? city,
    String? governorate,
  }) async {
    _setLoading(true);
    try {
      _user = await _repo.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        city: city,
        governorate: governorate,
      );
      _token = await _repo.currentToken();
      _cooldownActive = false;
      _retryAt = null;
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMe() async {
    _setLoading(true);
    try {
      final u = await _repo.me();
      _user = u;
      _token = await _repo.currentToken();
      _cooldownActive = false;
      _retryAt = null;
      _error = null;
    } on CooldownException catch (e) {
      _cooldownActive = true;
      _retryAt = e.retryAt;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  //update
  /// Update current user's profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? firstName,
    String? lastName,
    String? address,
    String? city,
    String? governorate,
    String? password,
  }) async {
    _setLoading(true);
    try {
      final updated = await _repo.updateProfile(
        name: name,
        email: email,
        phone: phone,
        location: location,
        firstName: firstName,
        lastName: lastName,
        address: address,
        city: city,
        governorate: governorate,
        password: password,
      );
      print(updated.toString());
      _user = updated;
      _token = await _repo.currentToken();
      _cooldownActive = false;
      _retryAt = null;
      _error = null;
      return true;
    } catch (e) {
      print("eeer" +e.toString());
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repo.logout();
      _user = null;
      _token = null;
      _cooldownActive = false;
      _retryAt = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logoutAll() async {
    _setLoading(true);
    try {
      await _repo.logoutAll();
      _user = null;
      _token = null;
      _cooldownActive = false;
      _retryAt = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ---------- Helpers ----------
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
