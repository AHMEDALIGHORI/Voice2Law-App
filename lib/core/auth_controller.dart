import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';

/// The server is the authority for identity and the admin role.
class AuthController extends ChangeNotifier {
  AuthController(this._api, {DateTime Function()? now})
    : _now = now ?? DateTime.now;
  final ApiService _api;
  final DateTime Function() _now;
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration lockoutDuration = Duration(minutes: 15);
  UserProfile? _user;
  DateTime? _expiresAt;
  DateTime? _lockedUntil;
  Timer? _expiryTimer;
  Timer? _lockTimer;
  bool _isLoading = false;
  String? _error;
  int _failedAttempts = 0;
  int _generation = 0;

  UserProfile? get user => isAuthenticated ? _user : null;
  bool get isAuthenticated =>
      _user != null && _expiresAt != null && _now().isBefore(_expiresAt!);
  bool get isAdmin => isAuthenticated && (_user?.isAdmin ?? false);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get failedAttempts => _failedAttempts;
  bool get usingDemoCredentials => false;
  bool get isLocked => _lockedUntil != null && _now().isBefore(_lockedUntil!);

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _failedAttempts = prefs.getInt('admin_failed_attempts') ?? 0;
    final lock = prefs.getInt('admin_locked_until');
    if (lock != null) _lockedUntil = DateTime.fromMillisecondsSinceEpoch(lock);
    _scheduleUnlock();
    final started = prefs.getInt('admin_session_started');
    if (started == null || !_api.hasToken) return;
    final expiry = DateTime.fromMillisecondsSinceEpoch(
      started,
    ).add(sessionTimeout);
    if (!_now().isBefore(expiry) ||
        expiry.isAfter(_now().add(sessionTimeout))) {
      await _clearSession();
      return;
    }
    final generation = _generation;
    try {
      final profile = await _api.authMe();
      if (generation != _generation) return;
      if (!profile.isAdmin) throw ApiException('Admin access is required.');
      _accept(profile, expiry);
    } catch (_) {
      await _clearSession();
    }
  }

  /// The configured server validates the token. There is no local demo bypass.
  Future<bool> login(
    String email,
    String password, {
    String? displayName,
  }) async {
    if (_isLoading) return false;
    if (isLocked) {
      _error = 'Too many attempts. Try again after the 15-minute lockout.';
      notifyListeners();
      return false;
    }
    if (_lockedUntil != null) {
      _failedAttempts = 0;
      _lockedUntil = null;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    final generation = _generation;
    try {
      if (!_api.hasToken) {
        throw ApiException('Add an admin token in Settings first.');
      }
      final profile = await _api.authMe();
      if (generation != _generation) return false;
      if (!profile.isAdmin) {
        throw ApiException('Admin access is required.', statusCode: 403);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'admin_session_started',
        _now().millisecondsSinceEpoch,
      );
      await prefs.remove('admin_locked_until');
      await prefs.remove('admin_failed_attempts');
      if (generation != _generation) {
        await _clearSession();
        return false;
      }
      _failedAttempts = 0;
      _lockedUntil = null;
      _accept(profile, _now().add(sessionTimeout));
      return true;
    } catch (_) {
      if (generation != _generation) return false;
      _failedAttempts++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('admin_failed_attempts', _failedAttempts);
      if (_failedAttempts >= 5) {
        _lockedUntil = _now().add(lockoutDuration);
        await prefs.setInt(
          'admin_locked_until',
          _lockedUntil!.millisecondsSinceEpoch,
        );
        _scheduleUnlock();
      }
      _error =
          'Could not verify admin access. Check your server and token in Settings.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _accept(UserProfile profile, DateTime expiry) {
    _user = profile;
    _expiresAt = expiry;
    _expiryTimer?.cancel();
    _expiryTimer = Timer(expiry.difference(_now()), invalidate);
    notifyListeners();
  }

  void _scheduleUnlock() {
    _lockTimer?.cancel();
    if (!isLocked) return;
    _lockTimer = Timer(_lockedUntil!.difference(_now()), () {
      _lockedUntil = null;
      _failedAttempts = 0;
      notifyListeners();
    });
  }

  void invalidate() {
    _generation++;
    _user = null;
    _expiresAt = null;
    _expiryTimer?.cancel();
    unawaited(_clearSession());
    notifyListeners();
  }

  Future<void> logout() async {
    invalidate();
    if (_api.hasToken) await _api.trySilently(() => _api.logoutRequest());
    await _api.clearToken();
    await _clearSession();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      'admin_session_started',
      'admin_session_email',
      'admin_session_name',
    ]) {
      await prefs.remove(key);
    }
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _lockTimer?.cancel();
    super.dispose();
  }
}
