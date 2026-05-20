import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../models/battery_data.dart';

class CellBalanceThresholds {
  const CellBalanceThresholds({
    required this.correctMaxMv,
    required this.lightWarningMaxMv,
    required this.warningMaxMv,
  });

  final int correctMaxMv;
  final int lightWarningMaxMv;
  final int warningMaxMv;

  static const defaultRules = CellBalanceThresholds(
    correctMaxMv: 20,
    lightWarningMaxMv: 50,
    warningMaxMv: 100,
  );
}

enum CellBalanceHealth {
  correct,
  lightWarning,
  warning,
  critical,
}

class CellBalanceAssessment {
  const CellBalanceAssessment({
    required this.deltaMv,
    required this.health,
    required this.statusLabel,
    required this.message,
  });

  final int deltaMv;
  final CellBalanceHealth health;
  final String statusLabel;
  final String message;

  Color color(BuildContext context) {
    final colors = Theme.of(context).extension<BatterySemanticColors>()!;
    return switch (health) {
      CellBalanceHealth.correct => colors.ok,
      CellBalanceHealth.lightWarning => colors.warning,
      CellBalanceHealth.warning => colors.warning,
      CellBalanceHealth.critical => colors.danger,
    };
  }
}

class CellBalanceRules {
  const CellBalanceRules({
    this.thresholds = CellBalanceThresholds.defaultRules,
  });

  final CellBalanceThresholds thresholds;

  CellBalanceAssessment assess(BatteryData battery) {
    final deltaMv = (battery.cellVoltageDelta * 1000).round();
    if (deltaMv < thresholds.correctMaxMv) {
      return CellBalanceAssessment(
        deltaMv: deltaMv,
        health: CellBalanceHealth.correct,
        statusLabel: 'Correcto',
        message: 'Las celdas están equilibradas.',
      );
    }
    if (deltaMv <= thresholds.lightWarningMaxMv) {
      return CellBalanceAssessment(
        deltaMv: deltaMv,
        health: CellBalanceHealth.lightWarning,
        statusLabel: 'Aviso leve',
        message:
            'Existe una ligera diferencia entre celdas. Realice una carga completa para facilitar el balanceo.',
      );
    }
    if (deltaMv <= thresholds.warningMaxMv) {
      return CellBalanceAssessment(
        deltaMv: deltaMv,
        health: CellBalanceHealth.warning,
        statusLabel: 'Aviso',
        message:
            'Se detecta una diferencia elevada entre celdas. Contacte con soporte técnico si persiste tras una carga completa.',
      );
    }
    return CellBalanceAssessment(
      deltaMv: deltaMv,
      health: CellBalanceHealth.critical,
      statusLabel: 'Crítico',
      message:
          'Se detecta una diferencia elevada entre celdas. Contacte con soporte técnico si persiste tras una carga completa.',
    );
  }
}

