import 'package:flutter/material.dart';

class MosfetStatusWidget extends StatelessWidget {
  const MosfetStatusWidget({
    required this.chargeEnabled,
    required this.dischargeEnabled,
    super.key,
  });

  final bool chargeEnabled;
  final bool dischargeEnabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Chip(label: Text('Carga ${chargeEnabled ? 'ON' : 'OFF'}')),
        const SizedBox(width: 8),
        Chip(label: Text('Descarga ${dischargeEnabled ? 'ON' : 'OFF'}')),
      ],
    );
  }
}

