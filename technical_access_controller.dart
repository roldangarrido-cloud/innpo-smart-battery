import 'secure_settings.dart';
import 'protected_action.dart';

class TechnicalAccessController {
  TechnicalAccessController({required SecureSettings secureSettings})
      : _secureSettings = secureSettings;

  final SecureSettings _secureSettings;

  Future<bool> authorize({
    required ProtectedAction action,
    required String pin,
  }) {
    return _secureSettings.verifyTechnicianPin(pin);
  }
}

