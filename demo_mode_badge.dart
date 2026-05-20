import 'package:flutter/material.dart';

import '../../data/bms_parser.dart';

class DemoModeBadge extends StatelessWidget {
  const DemoModeBadge({
    required this.batteryId,
    this.compact = false,
    super.key,
  });

  final String batteryId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!MockBmsParser.isMockDeviceId(batteryId)) {
      return const SizedBox.shrink();
    }
    return Semantics(
      label: 'Modo demo',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.35),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 4 : 6,
          ),
          child: Text(
            'MODO DEMO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
          ),
        ),
      ),
    );
  }
}

