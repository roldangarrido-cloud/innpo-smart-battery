import 'package:flutter/material.dart';

class BleSignalIndicator extends StatelessWidget {
  const BleSignalIndicator({required this.rssi, super.key});

  final int rssi;

  @override
  Widget build(BuildContext context) {
    final icon = rssi > -55
        ? Icons.signal_cellular_alt
        : rssi > -70
            ? Icons.signal_cellular_alt_2_bar
            : Icons.signal_cellular_alt_1_bar;
    return Icon(icon, color: Theme.of(context).colorScheme.primary);
  }
}

