import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../battery/application/battery_providers.dart';
import '../../battery/domain/models/battery_data.dart';
import '../data/mock_remote_diagnostics_repository.dart';
import '../domain/remote_diagnostic_session.dart';
import '../domain/remote_diagnostics_config.dart';
import '../domain/remote_diagnostics_repository.dart';
import '../domain/remote_support_consent.dart';
import 'remote_diagnostic_service.dart';

final remoteDiagnosticsRepositoryProvider =
    Provider<RemoteDiagnosticsRepository>(
  (ref) => MockRemoteDiagnosticsRepository(),
);

final remoteDiagnosticsConfigProvider = Provider<RemoteDiagnosticsConfig>(
  (ref) => RemoteDiagnosticsConfig.mock,
);

final remoteDiagnosticServiceProvider = Provider<RemoteDiagnosticService>((ref) {
  final service = RemoteDiagnosticService(
    repository: ref.watch(remoteDiagnosticsRepositoryProvider),
    config: ref.watch(remoteDiagnosticsConfigProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final remoteDiagnosticsControllerProvider = StateNotifierProvider.family<
    RemoteDiagnosticsController,
    AsyncValue<RemoteDiagnosticSession?>,
    String>((ref, deviceId) {
  return RemoteDiagnosticsController(
    ref: ref,
    deviceId: deviceId,
    service: ref.watch(remoteDiagnosticServiceProvider),
    config: ref.watch(remoteDiagnosticsConfigProvider),
  );
});

class RemoteDiagnosticsController
    extends StateNotifier<AsyncValue<RemoteDiagnosticSession?>> {
  RemoteDiagnosticsController({
    required this.ref,
    required this.deviceId,
    required this.service,
    required this.config,
  }) : super(const AsyncValue.data(null));

  final Ref ref;
  final String deviceId;
  final RemoteDiagnosticService service;
  final RemoteDiagnosticsConfig config;
  StreamSubscription<BatteryData>? _batterySubscription;
  Timer? _expiryTimer;
  Timer? _mockTechnicianTimer;
  DateTime? _lastTelemetrySentAt;

  Future<void> start({
    Duration? duration,
    RemoteSupportConsent? consent,
  }) async {
    state = const AsyncValue.loading();
    try {
      final session = await service.startSession(
        deviceId: deviceId,
        duration: duration,
        consent: consent ?? RemoteSupportConsent.acceptedNow(),
      );
      state = AsyncValue.data(session);
      _scheduleExpiry(session);
      _scheduleMockTechnicianConnection(session);
      await _batterySubscription?.cancel();
      _batterySubscription = ref
          .read(batteryStatusProvider(deviceId).stream)
          .listen((battery) => _upload(session, battery));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> stop() async {
    final session = state.valueOrNull;
    await _batterySubscription?.cancel();
    _batterySubscription = null;
    _expiryTimer?.cancel();
    _mockTechnicianTimer?.cancel();
    if (session != null) {
      await service.stopSession(session);
      state = AsyncValue.data(
        session.copyWith(
          status: RemoteSessionStatus.closedByCustomer,
          endedAt: DateTime.now(),
        ),
      );
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> extendWithCustomerAuthorization({
    Duration? extension,
  }) async {
    final session = state.valueOrNull;
    if (session == null || !session.isActive) {
      return;
    }
    final updated = await service.extendSession(
      session: session,
      extension: extension,
    );
    state = AsyncValue.data(updated);
    _scheduleExpiry(updated);
  }

  Future<void> terminateBecauseAppClosed() async {
    final session = state.valueOrNull;
    if (session == null || !session.isActive) {
      return;
    }
    await _fail(
      session,
      'La sesion se cerro porque la app dejo de estar abierta.',
      RemoteSessionStatus.connectionLost,
    );
  }

  Future<void> _upload(
    RemoteDiagnosticSession session,
    BatteryData battery,
  ) async {
    if (session.isExpired) {
      await _expire(session);
      return;
    }
    if (!battery.isConnected) {
      await _fail(
        session,
        'La bateria se ha desconectado del Bluetooth.',
        RemoteSessionStatus.connectionLost,
      );
      return;
    }
    final now = DateTime.now();
    if (_lastTelemetrySentAt != null &&
        now.difference(_lastTelemetrySentAt!) < config.telemetryInterval) {
      return;
    }
    _lastTelemetrySentAt = now;
    final activeSession = state.valueOrNull ?? session;
    final updated = await service.sendBatterySnapshot(
      session: activeSession,
      battery: battery,
    );
    final current = state.valueOrNull;
    if (current?.sessionId == session.sessionId && mounted) {
      state = AsyncValue.data(updated);
    }
  }

  void _scheduleExpiry(RemoteDiagnosticSession session) {
    _expiryTimer?.cancel();
    _expiryTimer = Timer(session.remainingTime, () => _expire(session));
  }

  Future<void> _expire(RemoteDiagnosticSession session) async {
    await _batterySubscription?.cancel();
    _batterySubscription = null;
    _mockTechnicianTimer?.cancel();
    if (mounted) {
      state = AsyncValue.data(
        session.copyWith(
          status: RemoteSessionStatus.expired,
          endedAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _fail(
    RemoteDiagnosticSession session,
    String message, [
    RemoteSessionStatus status = RemoteSessionStatus.error,
  ]) async {
    await _batterySubscription?.cancel();
    _batterySubscription = null;
    _expiryTimer?.cancel();
    _mockTechnicianTimer?.cancel();
    if (mounted) {
      state = AsyncValue.data(
        session.copyWith(
          status: status,
          endedAt: DateTime.now(),
          errorMessage: message,
        ),
      );
    }
  }

  void _scheduleMockTechnicianConnection(RemoteDiagnosticSession session) {
    _mockTechnicianTimer?.cancel();
    if (config.transport != RemoteRealtimeTransport.mock) {
      return;
    }
    _mockTechnicianTimer = Timer(const Duration(seconds: 3), () {
      final current = state.valueOrNull;
      if (current == null ||
          current.sessionId != session.sessionId ||
          !current.isActive ||
          !mounted) {
        return;
      }
      state = AsyncValue.data(
        current.copyWith(
          status: RemoteSessionStatus.active,
          technicianConnected: true,
          technicianName: 'Soporte INNPO',
          technicianId: 'mock-technician-1',
        ),
      );
    });
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    _expiryTimer?.cancel();
    _mockTechnicianTimer?.cancel();
    super.dispose();
  }
}
