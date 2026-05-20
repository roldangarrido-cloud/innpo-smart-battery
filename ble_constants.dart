class BmsProtocolConfig {
  const BmsProtocolConfig({
    required this.serviceUuid,
    required this.readCharacteristicUuid,
    required this.writeCharacteristicUuid,
    required this.notifyCharacteristicUuid,
  });

  final String serviceUuid;
  final String readCharacteristicUuid;
  final String writeCharacteristicUuid;
  final String notifyCharacteristicUuid;
}

const mockBmsProtocolConfig = BmsProtocolConfig(
  serviceUuid: 'mock-service',
  readCharacteristicUuid: 'mock-read-characteristic',
  writeCharacteristicUuid: 'mock-write-characteristic',
  notifyCharacteristicUuid: 'mock-notify-characteristic',
);

