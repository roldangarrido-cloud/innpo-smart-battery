import 'package:flutter/material.dart';

import '../../../../shared/widgets/innpo_app_header.dart';

class BatteryConnectionHeader extends StatelessWidget {
  const BatteryConnectionHeader({
    required this.name,
    required this.connected,
    this.rssi,
    this.onSettings,
    super.key,
  });

  final String name;
  final bool connected;
  final int? rssi;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return InnpoAppHeader(
      batteryName: name,
      connected: connected,
      rssi: rssi,
      onSettings: onSettings,
    );
  }
}
