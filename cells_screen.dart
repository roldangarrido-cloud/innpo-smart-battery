import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/battery_providers.dart';
import '../../domain/models/battery_data.dart';
import '../../domain/services/cell_balance_rules.dart';
import '../widgets/cell_voltage_bar.dart';

class CellsScreen extends ConsumerWidget {
  const CellsScreen({required this.batteryId, super.key});

  final String batteryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battery = ref.watch(batteryStatusProvider(batteryId));
    return Scaffold(
      appBar: AppBar(title: const Text('Celdas')),
      body: battery.when(
        data: (data) => _CellsView(battery: data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _CellsView extends StatelessWidget {
  const _CellsView({required this.battery});

  final BatteryData battery;

  @override
  Widget build(BuildContext context) {
    final assessment = const CellBalanceRules().assess(battery);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCard(battery: battery, assessment: assessment),
        const SizedBox(height: 12),
        _BalancingCard(battery: battery),
        const SizedBox(height: 12),
        for (final cell in battery.cells)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CellVoltageTile(
              cell: cell,
              minVoltage: battery.minCellVoltage,
              maxVoltage: battery.maxCellVoltage,
              isLowest: cell.index == battery.minCellIndex,
              isHighest: cell.index == battery.maxCellIndex,
            ),
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.battery,
    required this.assessment,
  });

  final BatteryData battery;
  final CellBalanceAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final color = assessment.color(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.view_module_outlined, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estado: ${assessment.statusLabel}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(assessment.message),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: 'Diferencia máxima',
                  value: '${assessment.deltaMv} mV',
                ),
                _InfoChip(
                  label: 'Celda más alta',
                  value:
                      'C${battery.maxCellIndex ?? '-'} · ${battery.maxCellVoltage.toStringAsFixed(3)} V',
                ),
                _InfoChip(
                  label: 'Celda más baja',
                  value:
                      'C${battery.minCellIndex ?? '-'} · ${battery.minCellVoltage.toStringAsFixed(3)} V',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalancingCard extends StatelessWidget {
  const _BalancingCard({required this.battery});

  final BatteryData battery;

  @override
  Widget build(BuildContext context) {
    final balancingCells = battery.balancingCellIndexes;
    return Card(
      child: ListTile(
        leading: Icon(
          battery.isBalancing ? Icons.sync : Icons.sync_disabled,
          color: battery.isBalancing
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        title: Text(
          battery.isBalancing ? 'Balanceo activo' : 'Balanceo inactivo',
        ),
        subtitle: Text(
          balancingCells.isEmpty
              ? 'No hay celdas balanceando actualmente.'
              : 'Celdas balanceando: ${balancingCells.map((index) => 'C$index').join(', ')}',
        ),
      ),
    );
  }
}

class _CellVoltageTile extends StatelessWidget {
  const _CellVoltageTile({
    required this.cell,
    required this.minVoltage,
    required this.maxVoltage,
    required this.isLowest,
    required this.isHighest,
  });

  final CellData cell;
  final double minVoltage;
  final double maxVoltage;
  final bool isLowest;
  final bool isHighest;

  @override
  Widget build(BuildContext context) {
    return CellVoltageBar(
      cell: cell,
      minVoltage: minVoltage,
      maxVoltage: maxVoltage,
      isLowest: isLowest,
      isHighest: isHighest,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}
