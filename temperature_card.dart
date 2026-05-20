import 'package:flutter/material.dart';

class TemperatureCard extends StatelessWidget {
  const TemperatureCard({required this.label, required this.celsius, super.key});

  final String label;
  final double celsius;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.thermostat_outlined),
        title: Text(label),
        trailing: Text('${celsius.toStringAsFixed(1)} C'),
      ),
    );
  }
}

