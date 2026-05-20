import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../settings/presentation/app_settings_screen.dart';
import '../widgets/demo_mode_badge.dart';
import 'battery_dashboard_screen.dart';
import 'cells_screen.dart';
import 'diagnostic_screen.dart';
import 'history_screen.dart';

class BatteryTabScaffold extends StatelessWidget {
  const BatteryTabScaffold({
    required this.batteryId,
    required this.initialIndex,
    super.key,
  });

  final String batteryId;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BatteryDashboardScreen(batteryId: batteryId),
      CellsScreen(batteryId: batteryId),
      HistoryScreen(batteryId: batteryId),
      DiagnosticScreen(batteryId: batteryId),
      AppSettingsScreen(batteryId: batteryId),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: initialIndex,
            children: pages,
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 10,
            right: 56,
            child: DemoModeBadge(batteryId: batteryId),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: initialIndex,
        onDestinationSelected: (index) {
          context.go(_routeFor(index));
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.battery_charging_full_outlined),
            selectedIcon: Icon(Icons.battery_charging_full),
            label: 'Estado',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_module_outlined),
            selectedIcon: Icon(Icons.view_module),
            label: 'Celdas',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Diagnóstico',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  String _routeFor(int index) {
    return switch (index) {
      0 => '/battery/$batteryId',
      1 => '/battery/$batteryId/cells',
      2 => '/battery/$batteryId/history',
      3 => '/battery/$batteryId/diagnostic',
      4 => '/battery/$batteryId/settings',
      _ => '/battery/$batteryId',
    };
  }
}
