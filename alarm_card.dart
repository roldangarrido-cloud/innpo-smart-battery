import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/models/alarm_data.dart';

class AlarmCard extends StatelessWidget {
  const AlarmCard({
    required this.alarm,
    super.key,
  });

  final AlarmData alarm;

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(context, alarm.severity);
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_severityIcon(alarm.severity), color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    alarm.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(alarm.userFriendlyDescription),
            const SizedBox(height: 12),
            Text(
              'Acción recomendada',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(alarm.recommendedAction),
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: const Text('Detalle técnico'),
              children: [
                _DetailLine(label: 'Código', value: alarm.code),
                _DetailLine(label: 'Descripción', value: alarm.technicalDescription),
                _DetailLine(label: 'Fecha', value: formatter.format(alarm.timestamp)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _severityIcon(AlarmSeverity severity) {
    return switch (severity) {
      AlarmSeverity.info => Icons.info_outline,
      AlarmSeverity.warning => Icons.warning_amber_outlined,
      AlarmSeverity.critical => Icons.report_problem_outlined,
    };
  }

  Color _severityColor(BuildContext context, AlarmSeverity severity) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<BatterySemanticColors>()!;
    return switch (severity) {
      AlarmSeverity.info => scheme.primary,
      AlarmSeverity.warning => colors.warning,
      AlarmSeverity.critical => colors.danger,
    };
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
