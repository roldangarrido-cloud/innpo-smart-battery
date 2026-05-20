import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class SecureSettings {
  SecureSettings({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _technicianModePinKey = 'technician_mode_pin';
  static const _failedAttemptsKey = 'technician_pin_failed_attempts';
  static const _lockedUntilKey = 'technician_pin_locked_until';
  static const _hashPrefix = 'sha256';

  final FlutterSecureStorage _storage;

  Future<bool> hasTechnicianPin() async {
    final storedHash = await _storage.read(key: _technicianModePinKey);
    return storedHash != null && storedHash.isNotEmpty;
  }

  Future<void> saveTechnicianPin(String pin) {
    final salt = _createSalt();
    final encoded = '$_hashPrefix:$salt:${_hashPin(pin, salt)}';
    return _storage.write(key: _technicianModePinKey, value: encoded).then((_) {
      return _clearLockout();
    });
  }

  Future<bool> verifyTechnicianPin(String pin) async {
    if (await isTechnicianPinLocked()) {
      return false;
    }
    final storedHash = await _storage.read(key: _technicianModePinKey);
    if (storedHash == null || storedHash.isEmpty) {
      return false;
    }
    final parts = storedHash.split(':');
    if (parts.length == 3 && parts.first == _hashPrefix) {
      final matches = _hashPin(pin, parts[1]) == parts[2];
      await _recordAttempt(matches);
      return matches;
    }
    final matches = storedHash == pin;
    await _recordAttempt(matches);
    return matches;
  }

  Future<void> resetTechnicianPin() async {
    await _storage.delete(key: _technicianModePinKey);
    await _clearLockout();
  }

  Future<bool> isTechnicianPinLocked() async {
    final raw = await _storage.read(key: _lockedUntilKey);
    if (raw == null) {
      return false;
    }
    final lockedUntil = DateTime.tryParse(raw);
    if (lockedUntil == null || DateTime.now().isAfter(lockedUntil)) {
      await _clearLockout();
      return false;
    }
    return true;
  }

  Future<Duration?> technicianPinLockRemaining() async {
    final raw = await _storage.read(key: _lockedUntilKey);
    final lockedUntil = raw == null ? null : DateTime.tryParse(raw);
    if (lockedUntil == null) {
      return null;
    }
    final remaining = lockedUntil.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  String _createSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  Future<void> _recordAttempt(bool success) async {
    if (success) {
      await _clearLockout();
      return;
    }
    final raw = await _storage.read(key: _failedAttemptsKey);
    final attempts = (int.tryParse(raw ?? '0') ?? 0) + 1;
    await _storage.write(key: _failedAttemptsKey, value: attempts.toString());
    if (attempts >= AppConstants.maxTechnicalPinAttempts) {
      await _storage.write(
        key: _lockedUntilKey,
        value: DateTime.now()
            .add(const Duration(minutes: AppConstants.technicalPinLockoutMinutes))
            .toIso8601String(),
      );
    }
  }

  Future<void> _clearLockout() async {
    await _storage.delete(key: _failedAttemptsKey);
    await _storage.delete(key: _lockedUntilKey);
  }
}
