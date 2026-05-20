import 'remote_diagnostic_session.dart';
import 'remote_diagnostic_telemetry.dart';
import 'remote_support_consent.dart';

abstract class RemoteDiagnosticRepository {
  Future<RemoteDiagnosticSession> createSession({
    required String deviceId,
    required Duration duration,
    required RemoteSupportConsent consent,
  });

  Stream<RemoteSessionStatus> watchSessionStatus(String sessionId);

  Future<void> sendHeartbeat(RemoteDiagnosticSession session);

  Future<void> uploadTelemetry({
    required RemoteDiagnosticSession session,
    required RemoteDiagnosticTelemetry telemetry,
  });

  Future<void> stopSession(RemoteDiagnosticSession session);

  Future<RemoteDiagnosticSession> extendSession({
    required RemoteDiagnosticSession session,
    required Duration extension,
  });

  Future<void> closeSessionByCustomer(RemoteDiagnosticSession session);

  Future<void> closeSessionFromBackend(String sessionId);
}
