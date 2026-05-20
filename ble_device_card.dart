import 'package:flutter/material.dart';

import '../../domain/ble_device.dart';
import 'ble_signal_indicator.dart';

class BleDeviceCard extends StatelessWidget {
  const BleDeviceCard({
    required this.device,
    required this.onTap,
    super.key,
  });

  final BleDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.battery_charging_full),
        title: Text(device.name),
        subtitle: Text('RSSI ${device.rssi} dBm'),
        trailing: BleSignalIndicator(rssi: device.rssi),
        onTap: onTap,
      ),
    );
  }
}

