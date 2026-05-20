import 'package:flutter/material.dart';

import '../../../../shared/widgets/innpo_status_card.dart';

class BatteryStatusCard extends StatelessWidget {
  const BatteryStatusCard({
    required this.status,
    required this.message,
    required this.color,
    required this.icon,
    super.key,
  });

  final String status;
  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InnpoStatusCard(
      title: status,
      message: message,
      level: _levelFromColor(context),
      icon: icon,
    );
  }

  InnpoStatusLevel _levelFromColor(BuildContext context) {
    final normalized = status.toLowerCase();
    if (normalized.contains('crítico') || normalized.contains('critico')) {
      return InnpoStatusLevel.critical;
    }
    if (normalized.contains('aviso') || normalized.contains('revisión')) {
      return InnpoStatusLevel.warning;
    }
    if (normalized.contains('correcto')) {
      return InnpoStatusLevel.ok;
    }
    final scheme = Theme.of(context).colorScheme;
    if (color == scheme.error) {
      return InnpoStatusLevel.critical;
    }
    if (color == scheme.primary) {
      return InnpoStatusLevel.ok;
    }
    return InnpoStatusLevel.warning;
  }
}
