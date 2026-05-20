import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/privacy/privacy_consent.dart';
import '../../application/battery_providers.dart';
import '../../domain/models/diagnostic_report.dart';
import '../../../reports/data/local_report_repository.dart';
import '../widgets/diagnostic_summary_card.dart';

class DiagnosticScreen extends ConsumerWidget {
  const DiagnosticScreen({required this.batteryId, super.key});

  final String batteryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(diagnosticSummaryProvider(batteryId));
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico')),
      body: report.when(
        data: (diagnostic) => _DiagnosticView(
          batteryId: batteryId,
          report: diagnostic,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _DiagnosticView extends StatelessWidget {
  const _DiagnosticView({
    required this.batteryId,
    required this.report,
  });

  final String batteryId;
  final DiagnosticReport report;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, report.status);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DiagnosticSummaryCard(
          status: _statusLabel(report.status),
          summary: report.summaryText,
          color: color,
          onCreateReport: () => context.push('/reports/$batteryId'),
        ),
        const SizedBox(height: 12),
        _FindingsSection(report: report),
        const SizedBox(height: 12),
        _RecommendationsSection(report: report),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('/remote-diagnostic/$batteryId'),
          icon: const Icon(Icons.verified_user_outlined),
          label: const Text('Diagnóstico remoto INNPO'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showSupportActions(context),
          icon: const Icon(Icons.support_agent_outlined),
          label: const Text('Enviar a soporte INNPO'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _saveDiagnostic(context, report),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Guardar diagnóstico'),
        ),
      ],
    );
  }

  Future<void> _saveDiagnostic(
    BuildContext context,
    DiagnosticReport report,
  ) async {
    // Local only. No automatic upload.
    await LocalReportRepository().saveDiagnostic(report);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Diagnóstico guardado localmente.')),
    );
  }

  Future<void> _showSupportActions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enviar a soporte',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Puedes iniciar una sesion remota temporal o preparar el envio manual del diagnostico.',
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.support_agent_outlined),
                  title: const Text('Iniciar diagnostico remoto'),
                  subtitle: const Text(
                    'Comparte datos en tiempo real con soporte INNPO.',
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/remote-diagnostic/$batteryId');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.mail_outline),
                  title: const Text('Preparar envio manual'),
                  subtitle: const Text(
                    'Genera consentimiento y deja el envio online para una fase futura.',
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final consent = await PrivacyConsent
                        .requestDiagnosticShareConsent(context);
                    if (!consent || !context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Envio a soporte INNPO pendiente de integracion online.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(BuildContext context, DiagnosticStatus status) {
    final colors = Theme.of(context).extension<BatterySemanticColors>()!;
    return switch (status) {
      DiagnosticStatus.ok => colors.ok,
      DiagnosticStatus.warning => colors.warning,
      DiagnosticStatus.critical => colors.danger,
      DiagnosticStatus.unknown => colors.info,
    };
  }

  String _statusLabel(DiagnosticStatus status) {
    return switch (status) {
      DiagnosticStatus.ok => 'Correcto',
      DiagnosticStatus.warning => 'Revision recomendada',
      DiagnosticStatus.critical => 'Crítico',
      DiagnosticStatus.unknown => 'Desconocido',
    };
  }
}

class _FindingsSection extends StatelessWidget {
  const _FindingsSection({required this.report});

  final DiagnosticReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hallazgos detectados', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final finding in report.findings)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_severityIcon(finding.severity)),
                title: Text(finding.title),
                subtitle: Text(finding.description),
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
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({required this.report});

  final DiagnosticReport report;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recomendaciones', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final recommendation in report.recommendations)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right, size: 22),
                    const SizedBox(width: 4),
                    Expanded(child: Text(recommendation)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
