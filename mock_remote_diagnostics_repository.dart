import 'dart:async';

import '../../../core/logging/local_event_log.dart';
import '../domain/remote_diagnostic_session.dart';
import '../domain/remote_diagnostic_telemetry.dart';
import '../domain/remote_diagnostics_config.dart';
import '../domain/remote_diagnostics_repository.dart';
import '../domain/remote_support_consent.dart';

class MockRemoteDiagnosticsRepository implements RemoteDiagnosticsRepository {
  final _telemetryBySession = <String, List<RemoteDiagnosticTelemetry>>{};
  final _statusControllers =
      <String, StreamController<RemoteSessionStatus>>{};
  final _usedCodes = <String>{};

  @override
  Future<RemoteDiagnosticSession> createSession({
    required String deviceId,
    required Duration duration,
    required RemoteSupportConsent consent,
  }) async {
    final now = DateTime.now();
    final session = RemoteDiagnosticSession(
      sessionId: 'remote-${now.microsecondsSinceEpoch}',
      sessionCode: _generateUniqueCode(now),
      createdAt: now,
      startedAt: now,
      expiresAt: now.add(duration),
      codeExpiresAt: now.add(RemoteDiagnosticsConfig.mock.sessionCodeTtl),
      status: RemoteSessionStatus.waitingForTechnician,
      technicianConnected: false,
      consentAccepted: consent.accepted,
      consentAcceptedAt: consent.acceptedAt,
      readOnly: true,
    );
    _statusController(session.sessionId).add(session.status);
    await _recordSafely(
      type: AppLogEventType.security,
      message: 'Sesión de diagnóstico remoto creada.',
      deviceId: deviceId,
      details: {
        'sessionId': session.sessionId,
        'sessionCode': session.sessionCode,
        'expiresAt': session.expiresAt.toIso8601String(),
        'codeExpiresAt': session.codeExpiresAt?.toIso8601String(),
        'consentAcceptedAt': session.consentAcceptedAt?.toIso8601String(),
        'consentTextVersion': consent.consentTextVersion,
        'sharedDataCategories': consent.sharedDataCategories,
        'readOnly': session.readOnly,
      },
    );
    return session;
  }

  @override
  Stream<RemoteSessionStatus> watchSessionStatus(String sessionId) {
    return _statusController(sessionId).stream;
  }

  @override
  Future<void> sendHeartbeat(RemoteDiagnosticSession session) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    _statusController(session.sessionId).add(session.status);
  }

  @override
  Future<void> uploadTelemetry({
    required RemoteDiagnosticSession session,
    required RemoteDiagnosticTelemetry telemetry,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _telemetryBySession.putIfAbsent(session.sessionId, () => []).add(telemetry);
  }

  @override
  Future<void> stopSession(RemoteDiagnosticSession session) async {
    _statusController(session.sessionId).add(
      RemoteSessionStatus.closedByCustomer,
    );
    await _recordSafely(
      type: AppLogEventType.security,
      message: 'Sesión de diagnóstico remoto detenida por el cliente.',
      deviceId: session.batterySerialNumber ?? session.sessionId,
      details: {
        'sessionId': session.sessionId,
        'sessionCode': session.sessionCode,
        'endedAt': DateTime.now().toIso8601String(),
        'technicianId': session.technicianId,
        'reportGenerated': session.reportGenerated,
      },
    );
  }

  @override
  Future<RemoteDiagnosticSession> extendSession({
    required RemoteDiagnosticSession session,
    required Duration extension,
  }) async {
    final updated = session.copyWith(
      expiresAt: session.expiresAt.add(extension),
    );
    await _recordSafely(
      type: AppLogEventType.security,
      message: 'Sesión de diagnóstico remoto ampliada con autorización del cliente.',
      deviceId: session.batterySerialNumber,
      details: {
        'sessionId': session.sessionId,
        'sessionCode': session.sessionCode,
        'newExpiresAt': updated.expiresAt.toIso8601String(),
      },
    );
    return updated;
  }

  @override
  Future<void> closeSessionFromBackend(String sessionId) async {
    _statusController(sessionId).add(RemoteSessionStatus.closedByTechnician);
    await _recordSafely(
      type: AppLogEventType.security,
      message: 'Sesión de diagnóstico remoto cerrada por el técnico.',
      details: {'sessionId': sessionId},
    );
  }

  @override
  Future<void> closeSessionByCustomer(RemoteDiagnosticSession session) async {
    await stopSession(session);
  }

  List<RemoteDiagnosticTelemetry> telemetryForSession(String sessionId) {
    return List.unmodifiable(
      _telemetryBySession[sessionId] ?? const <RemoteDiagnosticTelemetry>[],
    );
  }

  String _generateUniqueCode(DateTime now) {
    var code = now.millisecondsSinceEpoch.toString();
    code = code.substring(code.length - 6);
    while (_usedCodes.contains(code)) {
      final next = (int.parse(code) + 1) % 1000000;
      code = next.toString().padLeft(6, '0');
    }
    _usedCodes.add(code);
    return code;
  }

  StreamController<RemoteSessionStatus> _statusController(String sessionId) {
    return _statusControllers.putIfAbsent(
      sessionId,
      () => StreamController<RemoteSessionStatus>.broadcast(),
    );
  }

  Future<void> _recordSafely({
    required AppLogEventType type,
    required String message,
    String? deviceId,
    Map<String, Object?> details = const {},
  }) async {
    try {
      await LocalEventLogRepository().record(
        type: type,
        message: message,
        deviceId: deviceId,
        details: details,
      );
    } catch (_) {
      // Logging must never block an explicitly authorized support session.
    }
  }
}
