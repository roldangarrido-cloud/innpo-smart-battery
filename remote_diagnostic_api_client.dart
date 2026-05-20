import '../domain/remote_diagnostic_repository.dart';
import '../domain/remote_diagnostic_session.dart';
import '../domain/remote_diagnostic_telemetry.dart';
import '../domain/remote_diagnostics_config.dart';
import '../domain/remote_support_consent.dart';
import '../domain/remote_telemetry_packet.dart';
import 'remote_telemetry_mapper.dart';

class RemoteDiagnosticApiClient implements RemoteDiagnosticRepository {
  const RemoteDiagnosticApiClient({
    required this.config,
    this.telemetryMapper = const RemoteTelemetryMapper(),
  });

  final RemoteDiagnosticsConfig config;
  final RemoteTelemetryMapper telemetryMapper;

  @override
  Future<RemoteDiagnosticSession> createSession({
    required String deviceId,
    required Duration duration,
    required RemoteSupportConsent consent,
  }) {
    throw UnimplementedError(
      'RemoteDiagnosticApiClient.createSession debe conectarse al backend INNPO real mediante HTTPS.',
    );
  }

  @override
  Stream<RemoteSessionStatus> watchSessionStatus(String sessionId) {
    throw UnimplementedError(
      'RemoteDiagnosticApiClient.watchSessionStatus debe usar WSS/WebSocket, Socket.io, MQTT o Firebase.',
    );
  }

  @override
  Future<void> sendHeartbeat(RemoteDiagnosticSession session) {
    throw UnimplementedError(
      'RemoteDiagnosticApiClient.sendHeartbeat debe enviar latido seguro al backend.',
    );
  }

  @override
  Future<void> uploadTelemetry({
    required RemoteDiagnosticSession session,
    required RemoteDiagnosticTelemetry telemetry,
  }) {
    return sendTelemetry(telemetry);
  }

  Future<void> sendTelemetry(RemoteTelemetryPacket packet) {
    final payload = telemetryMapper.toOptimizedPayload(packet);
    throw UnimplementedError(
      'RemoteDiagnosticApiClient.sendTelemetry debe enviar el payload por HTTPS/WSS: $payload',
    );
  }

  @override
  Future<void> stopSession(RemoteDiagnosticSession session) {
    throw UnimplementedError(
      'RemoteDiagnosticApiClient.stopSession debe cerrar la sesion en backend.',
    );
  }

  @override
  Future<RemoteDiagnosticSession> extendSession({
    required RemoteDiagnosticSession session,
    required Duration extension,
  }) {
    throw UnimplementedError(
      'RemoteDiagnosticApiClient.extendSession debe solicitar ampliacion autorizada al backend.',
    );
  }

  @override
  Future<void> closeSessionByCustomer(RemoteDiagnosticSession session) {
    throw UnimplementedError(
      'RemoteDiagnosticApiClient.closeSessionByCustomer debe revocar la sesion en backend.',
    );
  }

  @override
  Future<void> closeSessionFromBackend(String sessionId) {
    throw UnimplementedError(
      'RemoteDiagnosticApiClient.closeSessionFromBackend debe procesar cierre remoto emitido por backend.',
    );
  }
}
