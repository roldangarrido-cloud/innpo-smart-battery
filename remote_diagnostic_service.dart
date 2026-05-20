import 'dart:async';

import '../../battery/domain/models/battery_data.dart';
import '../data/remote_telemetry_mapper.dart';
import '../domain/remote_diagnostic_repository.dart';
import '../domain/remote_diagnostic_session.dart';
import '../domain/remote_diagnostic_telemetry.dart';
import '../domain/remote_diagnostics_config.dart';
import '../domain/remote_support_consent.dart';
import '../domain/remote_telemetry_packet.dart';
import 'remote_consent_service.dart';
import 'remote_session_timer.dart';

class RemoteDiagnosticService {
  RemoteDiagnosticService({
    required this.repository,
    required this.config,
    RemoteTelemetryMapper telemetryMapper = const RemoteTelemetryMapper(),
    RemoteConsentService consentService = const RemoteConsentService(),
    RemoteSessionTimer? sessionTimer,
  })  : telemetryMapper = telemetryMapper,
        consentService = consentService,
        sessionTimer = sessionTimer ?? RemoteSessionTimer();

  final RemoteDiagnosticRepository repository;
  final RemoteDiagnosticsConfig config;
  final RemoteTelemetryMapper telemetryMapper;
  final RemoteConsentService consentService;
  final RemoteSessionTimer sessionTimer;

  final _statusController = StreamController<RemoteSessionStatus>.broadcast();
  RemoteSupportConsent? _consent;
  RemoteDiagnosticSession? _session;

  Future<RemoteDiagnosticSession> createSession({
    String deviceId = 'demo-battery',
    Duration? duration,
  }) async {
    final consent = _consent;
    if (consent == null) {
      throw StateError(
        'No se puede crear una sesion remota sin consentimiento explicito.',
      );
    }
    consentService.validate(consent);
    final session = await repository.createSession(
      deviceId: deviceId,
      duration: duration ?? config.defaultSessionDuration,
      consent: consent,
    );
    _setSession(session);
    _startHeartbeat();
    return session;
  }

  Future<void> acceptConsent() async {
    _consent = consentService.acceptConsent();
  }

  Stream<RemoteSessionStatus> watchSessionStatus() {
    return _statusController.stream;
  }

  Future<void> startStreaming(BatteryData stream) async {
    final session = _requireSession();
    final packet = telemetryMapper.fromBatteryData(
      sessionId: session.sessionId,
      batteryData: stream,
      sequenceNumber: session.sequenceNumber + 1,
    );
    await sendTelemetry(packet);
  }

  Future<void> sendTelemetry(RemoteTelemetryPacket packet) async {
    final session = _requireSession();
    await repository.uploadTelemetry(
      session: session,
      telemetry: packet,
    );
    _setSession(
      session.copyWith(
        lastUploadAt: DateTime.now(),
        sequenceNumber: packet.sequenceNumber,
      ),
    );
  }

  Future<void> stopSession([RemoteDiagnosticSession? session]) async {
    final activeSession = session ?? _session;
    if (activeSession == null) {
      return;
    }
    await repository.stopSession(activeSession);
    sessionTimer.cancel();
    _setSession(
      activeSession.copyWith(
        status: RemoteSessionStatus.closedByCustomer,
        endedAt: DateTime.now(),
      ),
    );
  }

  Future<RemoteDiagnosticSession> extendSession({
    RemoteDiagnosticSession? session,
    Duration? extension,
  }) async {
    final activeSession = session ?? _requireSession();
    final updated = await repository.extendSession(
      session: activeSession,
      extension: extension ?? config.defaultSessionDuration,
    );
    _setSession(updated);
    _scheduleExpiry(updated);
    return updated;
  }

  Future<void> closeSessionByCustomer() async {
    final session = _session;
    if (session == null) {
      return;
    }
    await repository.closeSessionByCustomer(session);
    sessionTimer.cancel();
    _setSession(
      session.copyWith(
        status: RemoteSessionStatus.closedByCustomer,
        endedAt: DateTime.now(),
      ),
    );
  }

  Future<RemoteDiagnosticSession> startSession({
    required String deviceId,
    required RemoteSupportConsent consent,
    Duration? duration,
  }) async {
    _consent = consent;
    return createSession(deviceId: deviceId, duration: duration);
  }

  Future<RemoteDiagnosticSession> sendBatterySnapshot({
    required RemoteDiagnosticSession session,
    required BatteryData battery,
  }) async {
    if (!battery.isConnected) {
      final updated = session.copyWith(
        status: RemoteSessionStatus.connectionLost,
        endedAt: DateTime.now(),
        errorMessage: 'La bateria se ha desconectado del Bluetooth.',
      );
      _setSession(updated);
      sessionTimer.cancel();
      return updated;
    }
    final telemetry = buildRemoteTelemetryPacket(
      sessionId: session.sessionId,
      battery: battery,
      sequenceNumber: session.sequenceNumber + 1,
    );
    _session = session;
    await sendTelemetry(telemetry);
    return _requireSession();
  }

  void dispose() {
    sessionTimer.cancel();
    _statusController.close();
  }

  RemoteDiagnosticSession _requireSession() {
    final session = _session;
    if (session == null) {
      throw StateError('No hay una sesion remota activa.');
    }
    return session;
  }

  void _setSession(RemoteDiagnosticSession session) {
    _session = session;
    _statusController.add(session.status);
    if (session.isActive) {
      _scheduleExpiry(session);
    } else {
      sessionTimer.cancel();
    }
  }

  void _scheduleExpiry(RemoteDiagnosticSession session) {
    sessionTimer.startExpiryTimer(
      duration: session.remainingTime,
      onExpired: () {
        final current = _session;
        if (current == null || current.sessionId != session.sessionId) {
          return;
        }
        _setSession(
          current.copyWith(
            status: RemoteSessionStatus.expired,
            endedAt: DateTime.now(),
          ),
        );
        sessionTimer.stopHeartbeat();
      },
    );
  }

  void _startHeartbeat() {
    sessionTimer.startHeartbeat(
      interval: config.telemetryInterval,
      onHeartbeat: () async {
        final session = _session;
        if (session == null || !session.isActive) {
          return;
        }
        try {
          await repository.sendHeartbeat(session);
        } catch (_) {
          _setSession(
            session.copyWith(
              status: RemoteSessionStatus.error,
              errorMessage: 'Error enviando heartbeat al backend remoto.',
            ),
          );
        }
      },
    );
  }
}
