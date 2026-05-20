enum RemoteSessionStatus {
  created,
  waitingForTechnician,
  active,
  paused,
  expired,
  closedByCustomer,
  closedByTechnician,
  connectionLost,
  error,
}

class RemoteDiagnosticSession {
  const RemoteDiagnosticSession({
    required this.sessionId,
    required this.sessionCode,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    required this.technicianConnected,
    required this.consentAccepted,
    this.customerName,
    this.customerEmail,
    this.orderNumber,
    this.batterySerialNumber,
    this.batteryModel,
    this.startedAt,
    this.endedAt,
    this.technicianName,
    this.technicianId,
    this.consentAcceptedAt,
    this.codeExpiresAt,
    this.readOnly = true,
    this.reportGenerated = false,
    this.lastUploadAt,
    this.sequenceNumber = 0,
    this.errorMessage,
  });

  final String sessionId;
  final String sessionCode;
  final String? customerName;
  final String? customerEmail;
  final String? orderNumber;
  final String? batterySerialNumber;
  final String? batteryModel;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final RemoteSessionStatus status;
  final bool technicianConnected;
  final String? technicianName;
  final String? technicianId;
  final bool consentAccepted;
  final DateTime? consentAcceptedAt;

  final DateTime? codeExpiresAt;
  final bool readOnly;
  final bool reportGenerated;
  final DateTime? lastUploadAt;
  final int sequenceNumber;
  final String? errorMessage;

  bool get isActive =>
      status == RemoteSessionStatus.waitingForTechnician ||
      status == RemoteSessionStatus.active;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isCodeExpired {
    final value = codeExpiresAt;
    return value != null && DateTime.now().isAfter(value);
  }

  Duration get remainingTime {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  RemoteDiagnosticSession copyWith({
    String? customerName,
    String? customerEmail,
    String? orderNumber,
    String? batterySerialNumber,
    String? batteryModel,
    DateTime? expiresAt,
    DateTime? startedAt,
    DateTime? endedAt,
    RemoteSessionStatus? status,
    bool? technicianConnected,
    String? technicianName,
    String? technicianId,
    bool? consentAccepted,
    DateTime? consentAcceptedAt,
    DateTime? codeExpiresAt,
    bool? readOnly,
    bool? reportGenerated,
    DateTime? lastUploadAt,
    int? sequenceNumber,
    String? errorMessage,
  }) {
    return RemoteDiagnosticSession(
      sessionId: sessionId,
      sessionCode: sessionCode,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      orderNumber: orderNumber ?? this.orderNumber,
      batterySerialNumber: batterySerialNumber ?? this.batterySerialNumber,
      batteryModel: batteryModel ?? this.batteryModel,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      technicianConnected: technicianConnected ?? this.technicianConnected,
      technicianName: technicianName ?? this.technicianName,
      technicianId: technicianId ?? this.technicianId,
      consentAccepted: consentAccepted ?? this.consentAccepted,
      consentAcceptedAt: consentAcceptedAt ?? this.consentAcceptedAt,
      codeExpiresAt: codeExpiresAt ?? this.codeExpiresAt,
      readOnly: readOnly ?? this.readOnly,
      reportGenerated: reportGenerated ?? this.reportGenerated,
      lastUploadAt: lastUploadAt ?? this.lastUploadAt,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      errorMessage: errorMessage,
    );
  }
}
