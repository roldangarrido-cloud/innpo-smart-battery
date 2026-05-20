import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/battery_providers.dart';
import '../../domain/models/alarm_data.dart';
import '../../domain/services/bms_alarm_catalog.dart';
import '../widgets/alarm_card.dart';
import '../widgets/demo_mode_badge.dart';

class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({required this.batteryId, super.key});

  final String batteryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battery = ref.watch(batteryStatusProvider(batteryId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarmas'),
        actions: [
          Center(child: DemoModeBadge(batteryId: batteryId, compact: true)),
          const SizedBox(width: 12),
        ],
      ),
      body: battery.when(
        data: (data) {
          final historical = data.historicalAlarms.isEmpty
              ? BmsAlarmCatalog.samples()
              : data.historicalAlarms;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AlarmSection(
                title: 'Alarmas activas',
                emptyText: 'No hay alarmas activas.',
                alarms: data.activeAlarms,
              ),
              const SizedBox(height: 16),
              _AlarmSection(
                title: 'Histórico de alarmas',
                emptyText: 'No hay alarmas históricas registradas.',
                alarms: historical,
              ),
              const SizedBox(height: 16),
              const _ProtectionExplanationCard(),
              const SizedBox(height: 24),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _AlarmSection extends StatelessWidget {
  const _AlarmSection({
    required this.title,
    required this.emptyText,
    required this.alarms,
  });

  final String title;
  final String emptyText;
  final List<AlarmData> alarms;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (alarms.isEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(emptyText),
            ),
          )
        else
          for (final alarm in alarms)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AlarmCard(alarm: alarm),
            ),
      ],
    );
  }
}

class _ProtectionExplanationCard extends StatelessWidget {
  const _ProtectionExplanationCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explicación de protecciones',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Cuando el BMS detecta una condición fuera de rango, puede limitar la carga, la descarga o ambas para proteger la batería, el equipo conectado y al usuario.',
            ),
            SizedBox(height: 8),
            Text(
              'No fuerce el uso de la batería si existe una protección activa. Revise la acción recomendada y genere un informe para soporte si el problema persiste.',
            ),
          ],
        ),
      ),
    );
  }
}

