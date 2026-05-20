import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/models/cell_data.dart';

class CellVoltageBar extends StatelessWidget {
  const CellVoltageBar({
    required this.cell,
    required this.minVoltage,
    required this.maxVoltage,
    this.isLowest = false,
    this.isHighest = false,
    super.key,
  });

  final CellData cell;
  final double minVoltage;
  final double maxVoltage;
  final bool isLowest;
  final bool isHighest;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, cell.status);
    final range = (maxVoltage - minVoltage).abs();
    final normalized = range < 0.001
        ? 1.0
        : ((cell.voltage - minVoltage) / range).clamp(0.08, 1.0).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    cell.index.toString(),
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Celda ${cell.index}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  cell.formattedVoltage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: normalized,
                minHeight: 10,
                color: color,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            if (isHighest || isLowest || cell.isBalancing) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (isHighest) const _CellChip(label: 'Más alta'),
                  if (isLowest) const _CellChip(label: 'Más baja'),
                  if (cell.isBalancing) const _CellChip(label: 'Balanceando'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, CellStatus status) {
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<BatterySemanticColors>()!;
    return switch (status) {
      CellStatus.normal => scheme.primary,
      CellStatus.high || CellStatus.low || CellStatus.warning => colors.warning,
      CellStatus.critical => colors.danger,
    };
  }
}

class _CellChip extends StatelessWidget {
  const _CellChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
