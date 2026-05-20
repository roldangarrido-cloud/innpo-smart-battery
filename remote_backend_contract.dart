class RemoteBackendContract {
  const RemoteBackendContract._();

  static const createSession = 'POST /remote-diagnostics/sessions';
  static const activeSessions = 'GET /remote-diagnostics/sessions/active';
  static const uploadTelemetry =
      'POST /remote-diagnostics/sessions/{sessionId}/telemetry';
  static const heartbeat =
      'POST /remote-diagnostics/sessions/{sessionId}/heartbeat';
  static const stopSession = 'POST /remote-diagnostics/sessions/{sessionId}/stop';
  static const getSessionByCode = 'GET /remote-diagnostics/sessions/{code}';
  static const getSessionById = 'GET /remote-diagnostics/sessions/{sessionId}';
  static const getSessionEvents =
      'GET /remote-diagnostics/sessions/{sessionId}/events';
  static const addInternalNote =
      'POST /remote-diagnostics/sessions/{sessionId}/notes';
  static const createReport =
      'POST /remote-diagnostics/sessions/{sessionId}/report';
  static const registerOutcome =
      'POST /remote-diagnostics/sessions/{sessionId}/outcome';
  static const closeSession =
      'POST /remote-diagnostics/sessions/{sessionId}/close';
  static const technicianLogin = 'POST /technicians/login';
  static const mobileRealtimeChannel =
      'wss://api.innpo.es/remote-diagnostics/realtime/mobile/{sessionId}';
  static const panelRealtimeChannel =
      'wss://api.innpo.es/remote-diagnostics/realtime/panel/{sessionId}';
}

class RemoteTechnicianAccessLog {
  const RemoteTechnicianAccessLog({
    required this.id,
    required this.sessionId,
    required this.technicianId,
    required this.action,
    required this.timestamp,
  });

  final String id;
  final String sessionId;
  final String technicianId;
  final String action;
  final DateTime timestamp;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'technicianId': technicianId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
