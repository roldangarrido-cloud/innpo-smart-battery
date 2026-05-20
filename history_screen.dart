import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../application/battery_providers.dart';
import '../../domain/models/history_sample.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({required this.batteryId, super.key});

  final String batteryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(historyRangeProvider);
    final interval = ref.watch(historySampleIntervalProvider);
    final samples = ref.watch(batteryHistoryProvider(batteryId));
    return Scaffold(
      appBar: AppBar(title: const Text('Historico')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _RangeSelector(range: range),
          const SizedBox(height: 12),
          _IntervalSelector(interval: interval),
          const SizedBox(height: 12),
          if (samples.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.history_outlined),
                title: Text(
                  'Conecta una batería para comenzar a registrar datos.',
                ),
              ),
            )
          else ...[
            _Summary(samples: samples),
            const SizedBox(height: 12),
            _ChartCard(title: 'SOC', samples: samples, value: (s) => s.socPercent, unit: '%'),
            _ChartCard(title: 'Voltaje', samples: samples, value: (s) => s.totalVoltage, unit: 'V'),
            _ChartCard(title: 'Corriente', samples: samples, value: (s) => s.current, unit: 'A'),
            _ChartCard(
              title: 'Temperatura',
              samples: samples,
              value: (s) => s.temperatureMax,
              unit: 'C',
            ),
            _ChartCard(
              title: 'Delta de celdas',
              samples: samples,
              value: (s) => s.cellVoltageDelta * 1000,
              unit: 'mV',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportCsv(context, ref, samples),
                    icon: const Icon(Icons.table_chart_outlined),
                    label: const Text('Exportar CSV'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _exportPdf(samples),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('PDF resumido'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _clearHistory(context, ref),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Borrar histórico'),
            ),
          ],
        ],
      ),
    );
  }

  void _exportCsv(
    BuildContext context,
    WidgetRef ref,
    List<BatteryHistorySample> samples,
  ) {
    final csv = ref.read(batteryHistoryRepositoryProvider).buildCsv(samples);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV generado (${csv.length} caracteres).'),
      ),
    );
  }

  Future<void> _exportPdf(List<BatteryHistorySample> samples) async {
    final doc = pw.Document();
    final first = samples.first;
    final last = samples.last;
    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INNPO Smart Battery - Historico resumido'),
            pw.SizedBox(height: 16),
            pw.Text('Muestras: ${samples.length}'),
            pw.Text('Desde: ${first.timestamp.toIso8601String()}'),
            pw.Text('Hasta: ${last.timestamp.toIso8601String()}'),
            pw.SizedBox(height: 12),
            pw.Text('SOC final: ${last.socPercent.toStringAsFixed(0)}%'),
            pw.Text('Voltaje final: ${last.totalVoltage.toStringAsFixed(2)} V'),
            pw.Text('Corriente final: ${last.current.toStringAsFixed(1)} A'),
            pw.Text('Temperatura final: ${last.temperatureMax.toStringAsFixed(1)} C'),
            pw.Text(
              'Delta celdas final: ${(last.cellVoltageDelta * 1000).round()} mV',
            ),
          ],
        ),
      ),
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'innpo_history_summary.pdf',
    );
  }

  Future<void> _clearHistory(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar histórico'),
        content: const Text(
          'Se eliminarán las lecturas locales de esta batería. Esta acción no envía datos a INNPO.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(batteryHistoryRepositoryProvider).clearHistory(
          deviceId: batteryId,
        );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Histórico borrado localmente.')),
    );
  }
}

class _IntervalSelector extends ConsumerWidget {
  const _IntervalSelector({required this.interval});

  final Duration interval;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const options = [
      Duration(seconds: 10),
      Duration(seconds: 30),
      Duration(seconds: 60),
      Duration(minutes: 5),
    ];
    return Card(
      child: ListTile(
        leading: const Icon(Icons.timer_outlined),
        title: const Text('Frecuencia de registro'),
        subtitle: const Text('Valor recomendado inicial: cada 30 segundos.'),
        trailing: DropdownButton<Duration>(
          value: interval,
          onChanged: (value) {
            if (value == null) {
              return;
            }
            ref.read(historySampleIntervalProvider.notifier).state = value;
          },
          items: [
            for (final option in options)
              DropdownMenuItem(
                value: option,
                child: Text(_intervalLabel(option)),
              ),
          ],
        ),
      ),
    );
  }

  String _intervalLabel(Duration duration) {
    if (duration.inMinutes >= 1) {
      return '${duration.inMinutes} min';
    }
    return '${duration.inSeconds} s';
  }
}

class _RangeSelector extends ConsumerWidget {
  const _RangeSelector({required this.range});

  final HistoryRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<HistoryRange>(
        selected: {range},
        onSelectionChanged: (selection) {
          ref.read(historyRangeProvider.notifier).state = selection.first;
        },
        segments: [
          for (final item in HistoryRange.values)
            ButtonSegment(value: item, label: Text(item.label)),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.samples});

  final List<BatteryHistorySample> samples;

  @override
  Widget build(BuildContext context) {
    final last = samples.last;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('Muestras: ${samples.length}')),
            Chip(label: Text('SOC: ${last.socPercent.toStringAsFixed(0)}%')),
            Chip(label: Text('Ciclos: ${last.cycleCount}')),
            Chip(label: Text('Alarmas: ${last.activeAlarmCount}')),
            Chip(
              label: Text(
                'Delta: ${(last.cellVoltageDelta * 1000).round()} mV',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.samples,
    required this.value,
    required this.unit,
  });

  final String title;
  final String unit;
  final List<BatteryHistorySample> samples;
  final double Function(BatteryHistorySample sample) value;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < samples.length; i++)
        FlSpot(i.toDouble(), value(samples[i])),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(
                      topTitles: AxisTitles(),
                      rightTitles: AxisTitles(),
                      bottomTitles: AxisTitles(),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text('${value(samples.last).toStringAsFixed(1)} $unit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
