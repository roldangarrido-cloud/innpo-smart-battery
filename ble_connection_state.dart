enum BleConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  discoveringServices,
  subscribing,
  error,
}

class BleConnectionState {
  const BleConnectionState({
    required this.status,
    this.deviceId,
    this.errorMessage,
  });

  final BleConnectionStatus status;
  final String? deviceId;
  final String? errorMessage;

  static const disconnected = BleConnectionState(
    status: BleConnectionStatus.disconnected,
  );
}

