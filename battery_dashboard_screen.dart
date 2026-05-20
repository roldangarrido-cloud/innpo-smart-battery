import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/app_mode/app_mode_providers.dart';
import '../../../../core/logging/local_event_log.dart';
import '../../../../core/security/critical_action_confirmation.dart';
import '../../../../core/security/protected_action.dart';
import '../../../../core/security/security_providers.dart';
import '../../application/battery_providers.dart';
import '../../domain/models/battery_data.dart';
import '../../domain/models/diagnostic_report.dart';
import '../widgets/battery_connection_header.dart';
import '../widgets/battery_status_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/soc_gauge.dart';

class BatteryDashboardScreen extends ConsumerWidget {
  const BatteryDashboardScreen({required this.batteryId, super.key});

  final String batteryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(batteryStatusProvider(batteryId));
    final diagnostics = ref.watch(diagnosticSummaryProvider(batteryId));
    final isTechnician = ref.watch(isTechnicianModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado'),
        actions: [
          IconButton(
            tooltip: 'Ajustes',
            onPressed: () => context.go('/battery/$batteryId/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: status.when(
        data: (battery) => _BatteryStatusView(
          battery: battery,
          diagnostics: diagnostics.valueOrNull,
          isTechnician: isTechnician,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _BatteryStatusView extends ConsumerWidget {
  const _BatteryStatusView({
    required this.battery,
    required this.diagnostics,
    required this.isTechnician,
  });

  final BatteryData battery;
  final DiagnosticReport? diagnostics;
  final bool isTechnician;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = _HealthState.from(battery, diagnostics);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _ConnectionHeader(battery: battery),
        const SizedBox(height: 12),
        _SocAndHealthCard(battery: battery, health: health),
        const SizedBox(height: 12),
        _MetricGrid(battery: battery),
        const SizedBox(height: 12),
        _OperatingStatusCard(battery: battery),
        const SizedBox(height: 12),
        _QuickActions(batteryId: battery.deviceId),
        if (isTechnician) ...[
          const SizedBox(height: 12),
          _TechnicalPanel(battery: battery),
        ],
      ],
    );
  }
}

class _ConnectionHeader extends StatelessWidget {
  const _ConnectionHeader({required this.battery});

  final BatteryData battery;

  @override
  Widget build(BuildContext context) {
    return BatteryConnectionHeader(
      name: battery.deviceName,
      connected: battery.isConnected,
      rssi: battery.rssi,
      onSettings: () => context.go('/battery/${battery.deviceId}/settings'),
    );
  }
}

class _SocAndHealthCard extends StatelessWidget {
  const _SocAndHealthCard({
    required this.battery,
    required this.health,
  });

  final BatteryData battery;
  final _HealthState health;

  @override
  Widget build(BuildContext context) {
    final color = health.color(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gauge = SocGauge(
              socPercent: battery.socPercent,
              statusText: _operatingStateLabel(battery.operationStatus),
              color: color,
            );
            final copy = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado general',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  health.label,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(health.message),
              ],
            );
            if (constraints.maxWidth < 420) {
              return Column(
                children: [
                  gauge,
                  const SizedBox(height: 14),
                  copy,
                ],
              );
            }
            return Row(
              children: [
                gauge,
                const SizedBox(width: 18),
                Expanded(child: copy),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.battery});

  final BatteryData battery;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _Metric(
        'Voltaje total',
        battery.totalVoltage.toStringAsFixed(2),
        'V',
        Icons.bolt_outlined,
        'Tensión del pack',
      ),
      _Metric(
        'Corriente',
        battery.current.toStringAsFixed(1),
        'A',
        Icons.swap_vert,
        battery.current >= 0 ? 'Entrada de energía' : 'Salida de energía',
      ),
      _Metric(
        'Potencia',
        battery.power.toStringAsFixed(0),
        'W',
        Icons.speed_outlined,
        'Flujo instantáneo',
      ),
      _Metric(
        'Temperatura',
        battery.temperatureMax.toStringAsFixed(1),
        '°C',
        Icons.thermostat_outlined,
        'Sensor más alto',
      ),
      _Metric(
        'Capacidad',
        battery.remainingCapacityAh.toStringAsFixed(1),
        'Ah',
        Icons.battery_5_bar_outlined,
        'Disponible estimada',
      ),
      _Metric('Ciclos', battery.cycleCount.toString(), '', Icons.repeat),
      _Metric(
        'Autonomía',
        _estimatedRuntimeLabel(battery),
        '',
        Icons.schedule_outlined,
        'Según consumo actual',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 640 ? 3 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.55,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            for (final metric in metrics)
              MetricCard(
                icon: metric.icon,
                title: metric.label,
                value: metric.value,
                unit: metric.unit,
                description: metric.description,
              ),
          ],
        );
      },
    );
  }
}

class _OperatingStatusCard extends StatelessWidget {
  const _OperatingStatusCard({required this.battery});

  final BatteryData battery;

  @override
  Widget build(BuildContext context) {
    final protection = battery.operationStatus == BatteryOperationStatus.protection;
    return BatteryStatusCard(
      status: _operatingStateLabel(battery.operationStatus),
      message: protection
          ? 'El BMS ha limitado el uso para proteger la batería. Revisa las alarmas antes de continuar.'
          : _operatingStateDescription(battery.operationStatus),
      color: protection
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primary,
      icon: protection ? Icons.shield_outlined : Icons.power_settings_new,
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.batteryId});

  final String batteryId;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction('Ver celdas', Icons.view_module_outlined, '/battery/$batteryId/cells'),
      _QuickAction('Ver alarmas', Icons.warning_amber_outlined, '/battery/$batteryId/alarms'),
      _QuickAction('Generar informe', Icons.picture_as_pdf_outlined, '/reports/$batteryId'),
      _QuickAction('Ver histórico', Icons.history_outlined, '/battery/$batteryId/history'),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accesos rápidos', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in actions)
                  OutlinedButton.icon(
                    onPressed: () => context.push(action.route),
                    icon: Icon(action.icon),
                    label: Text(action.label),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TechnicalPanel extends ConsumerWidget {
  const _TechnicalPanel({required this.battery});

  final BatteryData battery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Panel técnico', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Firmware ${battery.firmwareVersion ?? 'N/D'} · Señal ${battery.rssi ?? 0} dBm',
            ),
            const SizedBox(height: 12),
            for (final action in ProtectedAction.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  onPressed: () => _requestProtectedAction(
                    context: context,
                    ref: ref,
                    action: action,
                  ),
                  icon: const Icon(Icons.lock_outline),
                  label: Text(action.title),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestProtectedAction({
    required BuildContext context,
    required WidgetRef ref,
    required ProtectedAction action,
  }) async {
    final pinController = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action.title),
        content: TextField(
          controller: pinController,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'PIN técnico'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(pinController.text),
            child: const Text('Autorizar'),
          ),
        ],
      ),
    );
    pinController.dispose();
    if (pin == null || !context.mounted) {
      return;
    }
    final confirmed = await CriticalActionConfirmation.request(
      context,
      title: action.title,
      message:
          'Esta acción técnica puede modificar el comportamiento del BMS. La app permanece en modo seguro de solo lectura hasta disponer del protocolo real.',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    final authorized = await ref.read(technicalAccessControllerProvider).authorize(
          action: action,
          pin: pin,
        );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          authorized
              ? 'Acción autorizada. Pendiente de protocolo BMS real.'
              : 'PIN técnico incorrecto.',
        ),
      ),
    );
    await LocalEventLogRepository().record(
      type: authorized ? AppLogEventType.configurationChange : AppLogEventType.security,
      message: authorized
          ? 'Acción protegida autorizada: ${action.title}.'
          : 'Acción protegida rechazada por PIN incorrecto: ${action.title}.',
      deviceId: battery.deviceId,
    );
  }
}

class _HealthState {
  const _HealthState({
    required this.label,
    required this.message,
    required this.icon,
    required this.kind,
  });

  final String label;
  final String message;
  final IconData icon;
  final _HealthKind kind;

  factory _HealthState.from(BatteryData battery, DiagnosticReport? diagnostics) {
    if (!battery.isConnected) {
      return const _HealthState(
        label: 'Sin conexión',
        message: 'Sin conexión con la batería.',
        icon: Icons.bluetooth_disabled,
        kind: _HealthKind.disconnected,
      );
    }
    if (battery.hasCriticalAlarm ||
        diagnostics?.status == DiagnosticStatus.critical ||
        battery.operationStatus == BatteryOperationStatus.protection) {
      return const _HealthState(
        label: 'Crítico',
        message:
            'La batería ha activado una protección del BMS. Revisa las alarmas antes de continuar usando el equipo.',
        icon: Icons.report_problem_outlined,
        kind: _HealthKind.critical,
      );
    }
    if (battery.hasWarning || diagnostics?.status == DiagnosticStatus.warning) {
      return const _HealthState(
        label: 'Aviso',
        message:
            'Se recomienda revisar el estado de la batería. Consulta el apartado de diagnóstico.',
        icon: Icons.warning_amber_outlined,
        kind: _HealthKind.warning,
      );
    }
    return const _HealthState(
      label: 'Correcto',
      message: 'La batería funciona correctamente. No se detectan alarmas activas.',
      icon: Icons.check_circle_outline,
      kind: _HealthKind.ok,
    );
  }

  Color color(BuildContext context) {
    final colors = Theme.of(context).extension<BatterySemanticColors>()!;
    return switch (kind) {
      _HealthKind.ok => colors.ok,
      _HealthKind.warning => colors.warning,
      _HealthKind.critical => colors.danger,
      _HealthKind.disconnected => colors.info,
    };
  }
}

enum _HealthKind {
  ok,
  warning,
  critical,
  disconnected,
}

class _Metric {
  const _Metric(this.label, this.value, this.unit, this.icon, [this.description]);

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final String? description;
}

class _QuickAction {
  const _QuickAction(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

String _operatingStateLabel(BatteryOperationStatus state) {
  return switch (state) {
    BatteryOperationStatus.idle => 'En reposo',
    BatteryOperationStatus.charging => 'Cargando',
    BatteryOperationStatus.discharging => 'Descargando',
    BatteryOperationStatus.full => 'Completa',
    BatteryOperationStatus.protection => 'Protección activa',
    BatteryOperationStatus.unknown => 'Desconocido',
  };
}

String _operatingStateDescription(BatteryOperationStatus state) {
  return switch (state) {
    BatteryOperationStatus.idle => 'Sin carga ni descarga relevante.',
    BatteryOperationStatus.charging => 'La batería está recibiendo carga.',
    BatteryOperationStatus.discharging => 'La batería está alimentando el equipo.',
    BatteryOperationStatus.full => 'Carga completa disponible.',
    BatteryOperationStatus.protection => 'Protección activa.',
    BatteryOperationStatus.unknown => 'Estado pendiente de confirmar.',
  };
}

String _estimatedRuntimeLabel(BatteryData battery) {
  if (battery.operationStatus == BatteryOperationStatus.charging) {
    return 'Cargando';
  }
  if (battery.current.abs() < 0.1) {
    return 'En reposo';
  }
  final hours = battery.remainingCapacityAh / battery.current.abs();
  final totalMinutes = (hours * 60).round();
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  if (h <= 0) {
    return '${m} min';
  }
  return '${h} h ${m} min';
}
