import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/battery_providers.dart';
import '../../data/bms_parser.dart';

class DemoModeScreen extends ConsumerWidget {
  const DemoModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(mockBatteryProfileProvider);
    final state = ref.watch(mockBmsDemoStateProvider);
    final demoCase = ref.watch(mockBmsDemoCaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Modo demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const ListTile(
              leading: Icon(Icons.science_outlined),
              title: Text('MODO DEMO'),
              subtitle: Text(
                'Usa la app completa sin batería física: estado, celdas, alarmas, histórico e informe PDF.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Casos demo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final item in MockBmsDemoCase.values)
                  RadioListTile<MockBmsDemoCase>(
                    value: item,
                    groupValue: demoCase,
                    title: Text(item.title),
                    subtitle: Text(item.description),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      _selectDemoCase(ref, value);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _activateDemoCase(context, ref, demoCase),
            icon: const Icon(Icons.play_arrow_outlined),
            label: const Text('Entrar en modo demo'),
          ),
          const SizedBox(height: 24),
          Text('Perfil de batería', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final item in MockBatteryProfile.values)
                  RadioListTile<MockBatteryProfile>(
                    value: item,
                    groupValue: profile,
                    title: Text(_profileLabel(item)),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      ref.read(mockBatteryProfileProvider.notifier).state = value;
                      ref.invalidate(batteryStatusProvider);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Estado simulado', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final item in MockBmsDemoState.values)
                  RadioListTile<MockBmsDemoState>(
                    value: item,
                    groupValue: state,
                    title: Text(_stateLabel(item)),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      ref.read(mockBmsDemoStateProvider.notifier).state = value;
                      ref.invalidate(batteryStatusProvider);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _activateDemoCase(
    BuildContext context,
    WidgetRef ref,
    MockBmsDemoCase demoCase,
  ) {
    _selectDemoCase(ref, demoCase);
    final deviceId = MockBmsParser.deviceIdForProfile(demoCase.profile);
    context.go('/battery/$deviceId');
  }

  void _selectDemoCase(WidgetRef ref, MockBmsDemoCase demoCase) {
    ref.read(mockBmsDemoCaseProvider.notifier).state = demoCase;
    ref.read(mockBatteryProfileProvider.notifier).state = demoCase.profile;
    ref.read(mockBmsDemoStateProvider.notifier).state = demoCase.state;
    ref.invalidate(batteryStatusProvider);
  }
}

String _profileLabel(MockBatteryProfile profile) {
  return switch (profile) {
    MockBatteryProfile.innpo12v100ah => 'INNPO LiFePO4 12.8V 100Ah',
    MockBatteryProfile.innpo24v100ah => 'INNPO LiFePO4 25.6V 100Ah',
    MockBatteryProfile.innpoGolf51v100ah => 'INNPO Golf Battery 51.2V 100Ah',
  };
}

String _stateLabel(MockBmsDemoState state) {
  return switch (state) {
    MockBmsDemoState.normal => 'Normal',
    MockBmsDemoState.charging => 'Charging',
    MockBmsDemoState.discharging => 'Discharging',
    MockBmsDemoState.warning => 'Warning',
    MockBmsDemoState.critical => 'Critical',
    MockBmsDemoState.cellImbalance => 'Cell imbalance',
    MockBmsDemoState.lowTemperature => 'Low temperature',
    MockBmsDemoState.highTemperature => 'High temperature',
    MockBmsDemoState.overVoltage => 'Over voltage',
    MockBmsDemoState.underVoltage => 'Under voltage',
    MockBmsDemoState.overCurrent => 'Over current',
    MockBmsDemoState.chargeBlocked => 'Charge blocked',
    MockBmsDemoState.dischargeBlocked => 'Discharge blocked',
  };
}
