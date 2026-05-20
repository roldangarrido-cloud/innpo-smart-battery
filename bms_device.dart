class BmsDevice {
  const BmsDevice({
    required this.id,
    required this.name,
    this.localName,
    this.manufacturerName,
    this.rssi,
    this.isFavorite = false,
    this.lastConnectedAt,
    this.batteryAlias,
    this.batteryModel,
    this.serialNumber,
  });

  final String id;
  final String name;
  final String? localName;
  final String? manufacturerName;
  final int? rssi;
  final bool isFavorite;
  final DateTime? lastConnectedAt;
  final String? batteryAlias;
  final String? batteryModel;
  final String? serialNumber;

  String get displayName => batteryAlias ?? localName ?? name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'localName': localName,
      'manufacturerName': manufacturerName,
      'rssi': rssi,
      'isFavorite': isFavorite,
      'lastConnectedAt': lastConnectedAt?.toIso8601String(),
      'batteryAlias': batteryAlias,
      'batteryModel': batteryModel,
      'serialNumber': serialNumber,
    };
  }

  factory BmsDevice.fromJson(Map<String, dynamic> json) {
    return BmsDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      localName: json['localName'] as String?,
      manufacturerName: json['manufacturerName'] as String?,
      rssi: json['rssi'] as int?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      lastConnectedAt: json['lastConnectedAt'] == null
          ? null
          : DateTime.parse(json['lastConnectedAt'] as String),
      batteryAlias: json['batteryAlias'] as String?,
      batteryModel: json['batteryModel'] as String?,
      serialNumber: json['serialNumber'] as String?,
    );
  }
}
