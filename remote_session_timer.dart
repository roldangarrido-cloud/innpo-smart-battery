import 'dart:async';

class RemoteSessionTimer {
  RemoteSessionTimer();

  Timer? _expiryTimer;
  Timer? _heartbeatTimer;

  void startExpiryTimer({
    required Duration duration,
    required void Function() onExpired,
  }) {
    _expiryTimer?.cancel();
    _expiryTimer = Timer(duration, onExpired);
  }

  void startHeartbeat({
    required Duration interval,
    required Future<void> Function() onHeartbeat,
  }) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(interval, (_) => onHeartbeat());
  }

  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void cancel() {
    _expiryTimer?.cancel();
    _heartbeatTimer?.cancel();
    _expiryTimer = null;
    _heartbeatTimer = null;
  }
}
