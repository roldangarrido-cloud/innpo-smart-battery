import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/logging/local_event_log.dart';
import '../../../../core/security/critical_action_confirmation.dart';
import '../../../../core/security/security_providers.dart';
import '../../../../core/utils/validators.dart';
import '../../application/battery_providers.dart';
import '../../data/bms_profile_file_service.dart';
import '../../domain/models/battery_data.dart';
import '../../domain/models/battery_profile.dart';
import '../../domain/services/battery_compatibility_service.dart';

class TechnicalModeScreen extends ConsumerStatefulWidget {
  const TechnicalModeScreen({required this.batteryId, super.key});

  final String batteryId;

  @override
  ConsumerState<TechnicalModeScreen> createState() => _TechnicalModeScreenState();
}

class _TechnicalModeScreenState extends ConsumerState<TechnicalModeScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _unlocked = false;
  bool? _hasPin;

  @override
  void initState() {
    super.initState();
    _loadPinState();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPin = _hasPin;
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        title: const Text('Modo técnico'),
        backgroundColor: AppColors.darkNavy,
        foregroundColor: Colors.white,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.technicalBlueGradientStart,
              AppColors.darkNavy,
            ],
          ),
        ),
        child: hasPin == null
            ? const Center(child: CircularProgressIndicator())
            : !_unlocked
                ? _AccessGate(
                    hasPin: hasPin,
                    pinController: _pinController,
                    confirmPinController: _confirmPinController,
                    onCreatePin: _createPin,
                    onUnlock: _unlock,
                    onResetPin: _resetPin,
                  )
                : _TechnicalContent(batteryId: widget.batteryId),
      ),
    );
  }

  Future<void> _loadPinState() async {
    final hasPin = await ref.read(secureSettingsProvider).hasTechnicianPin();
    if (mounted) {
      setState(() => _hasPin = hasPin);
    }
  }

  Future<void> _createPin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();
    if (!Validators.isValidTechnicalPin(pin) || pin != confirmPin) {
      _showMessage('El PIN debe tener al menos 4 dígitos y coincidir.');
      return;
    }
    await ref.read(secureSettingsProvider).saveTechnicianPin(pin);
    await LocalEventLogRepository().record(
      type: AppLogEventType.security,
      message: 'PIN técnico creado o actualizado.',
      deviceId: widget.batteryId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _hasPin = true;
      _unlocked = true;
    });
  }

  Future<void> _unlock() async {
    final secureSettings = ref.read(secureSettingsProvider);
    if (await secureSettings.isTechnicianPinLocked()) {
      final remaining = await secureSettings.technicianPinLockRemaining();
      _showMessage(
        'Modo técnico bloqueado temporalmente. Intente de nuevo en ${remaining?.inMinutes ?? 1} min.',
      );
      return;
    }
    final authorized =
        await secureSettings.verifyTechnicianPin(_pinController.text.trim());
    if (!mounted) {
      return;
    }
    if (!authorized) {
      await LocalEventLogRepository().record(
        type: AppLogEventType.security,
        message: 'Intento fallido de acceso a modo técnico.',
        deviceId: widget.batteryId,
      );
      _showMessage('PIN técnico incorrecto.');
      return;
    }
    await LocalEventLogRepository().record(
      type: AppLogEventType.security,
      message: 'Modo técnico desbloqueado.',
      deviceId: widget.batteryId,
    );
    setState(() => _unlocked = true);
  }

  Future<void> _resetPin() async {
    final confirmed = await CriticalActionConfirmation.request(
      context,
      title: 'Restablecer PIN técnico',
      message:
          'Se eliminará el PIN técnico guardado en este dispositivo. Deberá crear uno nuevo para acceder al modo avanzado.',
      confirmLabel: 'Restablecer',
    );
    if (!confirmed) {
      return;
    }
    await ref.read(secureSettingsProvider).resetTechnicianPin();
    await LocalEventLogRepository().record(
      type: AppLogEventType.security,
      message: 'PIN técnico restablecido.',
      deviceId: widget.batteryId,
    );
    if (!mounted) {
      return;
    }
    _pinController.clear();
    _confirmPinController.clear();
    setState(() {
      _hasPin = false;
      _unlocked = false;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _AccessGate extends StatelessWidget {
  const _AccessGate({
    required this.hasPin,
    required this.pinController,
    required this.confirmPinController,
    required this.onCreatePin,
    required this.onUnlock,
    required this.onResetPin,
  });

  final bool hasPin;
  final TextEditingController pinController;
  final TextEditingController confirmPinController;
  final VoidCallback onCreatePin;
  final VoidCallback onUnlock;
  final VoidCallback onResetPin;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'El modo técnico permite modificar parámetros avanzados del BMS. Una configuración incorrecta puede afectar al funcionamiento o seguridad de la batería.',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasPin ? 'Introducir PIN técnico' : 'Crear PIN técnico',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'PIN técnico',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                if (!hasPin) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar PIN',
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: hasPin ? onUnlock : onCreatePin,
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: Text(hasPin ? 'Desbloquear' : 'Crear y acceder'),
                ),
                if (hasPin) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onResetPin,
                    icon: const Icon(Icons.lock_reset_outlined),
                    label: const Text('Restablecer PIN técnico'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TechnicalContent extends ConsumerWidget {
  const _TechnicalContent({required this.batteryId});

  final String batteryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battery = ref.watch(batteryStatusProvider(batteryId));
    return battery.when(
      data: (data) => _TechnicalPanel(battery: data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(error.toString())),
    );
  }
}

class _TechnicalPanel extends StatelessWidget {
  const _TechnicalPanel({required this.battery});

  final BatteryData battery;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _ReadOnlyNotice(),
        const SizedBox(height: 12),
        _BmsParametersCard(battery: battery),
        const SizedBox(height: 12),
        _ProtectedActionsCard(battery: battery),
        const SizedBox(height: 12),
        _ConfigurationActionsCard(battery: battery),
      ],
    );
  }
}

class _ReadOnlyNotice extends StatelessWidget {
  const _ReadOnlyNotice();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.visibility_outlined),
        title: Text('Modo seguro de solo lectura'),
        subtitle: Text(
          'La app inicia sin permisos de escritura sobre el BMS. Cualquier acción crítica requiere PIN, confirmación y compatibilidad de perfil.',
        ),
      ),
    );
  }
}

class _BmsParametersCard extends StatelessWidget {
  const _BmsParametersCard({required this.battery});

  final BatteryData battery;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parámetros BMS', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _kv('Firmware', battery.firmwareVersion ?? 'N/D'),
            _kv('Número de serie', battery.serialNumber ?? 'N/D'),
            _kv('Capacidad nominal', '${battery.nominalCapacityAh.toStringAsFixed(0)} Ah'),
            _kv('Límites de voltaje', 'Pendiente de protocolo real'),
            _kv('Límites de corriente', 'Pendiente de protocolo real'),
            _kv('Límites de temperatura', 'Pendiente de protocolo real'),
          ],
        ),
      ),
    );
  }
}

class _ProtectedActionsCard extends StatelessWidget {
  const _ProtectedActionsCard({required this.battery});

  final BatteryData battery;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _TechAction(
        'Desactivar carga',
        'Estado actual: ${battery.chargeMosfetEnabled ? 'activada' : 'bloqueada'}',
      ),
      _TechAction(
        'Desactivar descarga',
        'Estado actual: ${battery.dischargeMosfetEnabled ? 'activada' : 'bloqueada'}',
      ),
      const _TechAction('Cambiar parámetros BMS', 'Disponible si el BMS lo permite.'),
      const _TechAction('Importar perfil', 'Se validará compatibilidad antes de aplicar.'),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Funciones protegidas', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final action in actions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline),
                title: Text(action.title),
                subtitle: Text('${action.subtitle}\nSimulado/desactivado en esta versión.'),
                isThreeLine: true,
                trailing: OutlinedButton(
                  onPressed: () => _requestCriticalAction(context, action),
                  child: const Text('Probar'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestCriticalAction(BuildContext context, _TechAction action) async {
    final profile = BatteryProfile.fromBatteryData(battery);
    final compatibility =
        const BatteryCompatibilityService().canApplyConfiguration(battery, profile);
    if (!compatibility.compatible) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configuración bloqueada: ${compatibility.reason}')),
      );
      return;
    }
    final confirmed = await CriticalActionConfirmation.request(
      context,
      title: action.title,
      message:
          'Esta acción puede afectar al funcionamiento o seguridad de la batería. En esta versión no se escribirá en el BMS porque el protocolo real aún no está disponible.',
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await LocalEventLogRepository().record(
      type: AppLogEventType.configurationChange,
      message: 'Acción crítica confirmada en modo simulado: ${action.title}.',
      deviceId: battery.deviceId,
      details: {'compatible': compatibility.compatible},
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Acción confirmada. Escritura bloqueada por modo solo lectura.'),
      ),
    );
  }
}

class _ConfigurationActionsCard extends StatelessWidget {
  const _ConfigurationActionsCard({required this.battery});

  final BatteryData battery;

  @override
  Widget build(BuildContext context) {
    final actions = const [
      _ConfigAction('Exportar perfil BMS', false, _ConfigActionType.exportProfile),
      _ConfigAction('Importar perfil BMS', true, _ConfigActionType.importProfile),
      _ConfigAction('Restaurar configuración', true),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuración', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final action in actions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  onPressed: () => _confirmConfigAction(context, action),
                  icon: Icon(action.critical
                      ? Icons.lock_outline
                      : Icons.file_download_outlined),
                  label: Text('${action.title} (simulado)'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmConfigAction(BuildContext context, _ConfigAction action) async {
    if (action.critical) {
      final confirmed = await CriticalActionConfirmation.request(
        context,
        title: action.title,
        message:
            'Esta acción requiere confirmación técnica. La escritura real está desactivada por defecto.',
      );
      if (!confirmed) {
        return;
      }
    }
    if (action.type == _ConfigActionType.exportProfile) {
      final file = await const BmsProfileFileService().exportProfile(battery);
      await const BmsProfileFileService().shareProfile(file);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil BMS exportado en JSON.')),
      );
      return;
    }

    if (action.type == _ConfigActionType.importProfile) {
      final profile = await const BmsProfileFileService().importProfile();
      if (profile == null) {
        return;
      }
      final compatibility = const BatteryCompatibilityService()
          .canApplyConfiguration(battery, profile);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            compatibility.compatible
                ? 'Perfil compatible. Aplicación al BMS desactivada hasta tener protocolo real.'
                : 'Perfil incompatible: ${compatibility.reason}',
          ),
        ),
      );
      return;
    }

    await LocalEventLogRepository().record(
      type: AppLogEventType.configurationChange,
      message: 'Acción de configuración simulada: ${action.title}.',
      deviceId: battery.deviceId,
    );
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Acción registrada en logs locales.')),
    );
  }
}

class _TechAction {
  const _TechAction(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class _ConfigAction {
  const _ConfigAction(
    this.title,
    this.critical, [
    this.type = _ConfigActionType.other,
  ]);

  final String title;
  final bool critical;
  final _ConfigActionType type;
}

enum _ConfigActionType {
  exportProfile,
  importProfile,
  other,
}

Widget _kv(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
