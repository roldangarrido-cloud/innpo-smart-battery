import 'package:flutter_test/flutter_test.dart';
import 'package:innpo_smart_battery/features/remote_diagnostics/data/mock_remote_diagnostics_repository.dart';
import 'package:innpo_smart_battery/features/remote_diagnostics/domain/remote_diagnostic_session.dart';
import 'package:innpo_smart_battery/features/remote_diagnostics/domain/remote_support_consent.dart';

void main() {
  group('MockRemoteDiagnosticsRepository', () {
    test('creates a temporary session after explicit consent', () async {
      final repository = MockRemoteDiagnosticsRepository();

      final session = await repository.createSession(
        deviceId: 'mock-12v-100ah',
        duration: const Duration(minutes: 15),
        consent: RemoteSupportConsent.acceptedNow(),
      );

      expect(session.status, RemoteSessionStatus.waitingForTechnician);
      expect(session.sessionCode.length, 6);
      expect(session.consentAccepted, isTrue);
      expect(session.readOnly, isTrue);
      expect(session.expiresAt.isAfter(session.createdAt), isTrue);
    });
  });
}
