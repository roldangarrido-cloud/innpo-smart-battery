import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class L10n {
  const L10n._();

  static const supportedLanguageCodes = ['es', 'en', 'fr', 'pt', 'it', 'de'];
  static const supportedLocales = [
    Locale('es'),
    Locale('en'),
    Locale('fr'),
    Locale('pt'),
    Locale('it'),
    Locale('de'),
  ];
}

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _values = {
    'es': {
      'appName': 'INNPO Smart Battery',
      'appClaim': 'Control inteligente de tu batería',
      'onboardingDescription':
          'Monitoriza, protege y optimiza tus baterías inteligentes desde el móvil.',
      'bluetoothSecondaryClaim':
          'Conecta tu batería y toma el control desde tu móvil.',
      'supportBrandClaim':
          'Control inteligente de tu batería, con soporte técnico INNPO.',
      'technicalBatteryReport': 'Informe técnico de batería',
      'searchBattery': 'Buscar batería',
      'connect': 'Conectar',
      'disconnect': 'Desconectar',
      'batteryConnected': 'Batería conectada',
      'disconnected': 'Sin conexión',
      'status': 'Estado',
      'cells': 'Celdas',
      'history': 'Histórico',
      'diagnosis': 'Diagnóstico',
      'settings': 'Ajustes',
      'technicalMode': 'Modo técnico',
      'generateTechnicalReport': 'Generar informe técnico',
      'sendToInnpoSupport': 'Enviar a soporte INNPO',
      'batteryWorkingCorrectly': 'La batería funciona correctamente.',
      'noActiveAlarmsDetected': 'No se detectan alarmas activas.',
      'batteryReviewRecommended': 'Se recomienda revisar la batería.',
      'bmsProtectionActive': 'Protección activa del BMS.',
      'chargeBlocked': 'Carga bloqueada.',
      'dischargeBlocked': 'Descarga bloqueada.',
      'cellImbalance': 'Diferencia entre celdas.',
      'highTemperature': 'Temperatura elevada.',
      'lowTemperature': 'Temperatura baja.',
      'highCurrent': 'Corriente elevada.',
      'lowStateOfCharge': 'Nivel de carga bajo.',
      'demoMode': 'Modo demo',
      'registerWarranty': 'Registrar garantía',
      'userManual': 'Manual de uso',
      'maintenanceTips': 'Consejos de mantenimiento',
    },
    'en': {
      'appName': 'INNPO Smart Battery',
      'appClaim': 'Smart control for your battery',
      'onboardingDescription':
          'Monitor, protect and optimize your smart batteries from your mobile.',
      'bluetoothSecondaryClaim':
          'Connect your battery and take control from your mobile.',
      'supportBrandClaim':
          'Smart control for your battery, with INNPO technical support.',
      'technicalBatteryReport': 'Battery technical report',
      'searchBattery': 'Search battery',
      'connect': 'Connect',
      'disconnect': 'Disconnect',
      'batteryConnected': 'Battery connected',
      'disconnected': 'Disconnected',
      'status': 'Status',
      'cells': 'Cells',
      'history': 'History',
      'diagnosis': 'Diagnosis',
      'settings': 'Settings',
      'technicalMode': 'Technical mode',
      'generateTechnicalReport': 'Generate technical report',
      'sendToInnpoSupport': 'Send to INNPO support',
      'batteryWorkingCorrectly': 'The battery is working correctly.',
      'noActiveAlarmsDetected': 'No active alarms detected.',
      'batteryReviewRecommended': 'Battery review is recommended.',
      'bmsProtectionActive': 'BMS protection active.',
      'chargeBlocked': 'Charge blocked.',
      'dischargeBlocked': 'Discharge blocked.',
      'cellImbalance': 'Cell imbalance.',
      'highTemperature': 'High temperature.',
      'lowTemperature': 'Low temperature.',
      'highCurrent': 'High current.',
      'lowStateOfCharge': 'Low state of charge.',
      'demoMode': 'Demo mode',
      'registerWarranty': 'Register warranty',
      'userManual': 'User manual',
      'maintenanceTips': 'Maintenance tips',
    },
    'fr': {
      'appName': 'INNPO Smart Battery',
      'appClaim': 'Le contrôle intelligent de votre batterie',
      'onboardingDescription':
          'Surveillez, protégez et optimisez vos batteries intelligentes depuis votre mobile.',
      'bluetoothSecondaryClaim':
          'Connectez votre batterie et prenez le contrôle depuis votre mobile.',
      'supportBrandClaim':
          'Le contrôle intelligent de votre batterie, avec le support technique INNPO.',
      'technicalBatteryReport': 'Rapport technique de batterie',
    },
    'pt': {
      'appName': 'INNPO Smart Battery',
      'appClaim': 'Controlo inteligente da sua bateria',
      'onboardingDescription':
          'Monitorize, proteja e otimize as suas baterias inteligentes a partir do telemóvel.',
      'bluetoothSecondaryClaim':
          'Ligue a sua bateria e assuma o controlo a partir do telemóvel.',
      'supportBrandClaim':
          'Controlo inteligente da sua bateria, com suporte técnico INNPO.',
      'technicalBatteryReport': 'Relatório técnico da bateria',
    },
    'it': {
      'appName': 'INNPO Smart Battery',
      'appClaim': 'Controllo intelligente della tua batteria',
      'onboardingDescription':
          'Monitora, proteggi e ottimizza le tue batterie intelligenti dal telefono.',
      'bluetoothSecondaryClaim':
          'Collega la batteria e prendi il controllo dal telefono.',
      'supportBrandClaim':
          'Controllo intelligente della tua batteria, con supporto tecnico INNPO.',
      'technicalBatteryReport': 'Report tecnico della batteria',
    },
    'de': {
      'appName': 'INNPO Smart Battery',
      'appClaim': 'Intelligente Kontrolle deiner Batterie',
      'onboardingDescription':
          'Überwache, schütze und optimiere deine intelligenten Batterien direkt vom Smartphone.',
      'bluetoothSecondaryClaim':
          'Verbinde deine Batterie und übernimm die Kontrolle per Smartphone.',
      'supportBrandClaim':
          'Intelligente Kontrolle deiner Batterie, mit technischem INNPO Support.',
      'technicalBatteryReport': 'Technischer Batteriebericht',
    },
  };

  String _text(String key) {
    final languageCode = L10n.supportedLanguageCodes.contains(locale.languageCode)
        ? locale.languageCode
        : 'es';
    return _values[languageCode]?[key] ?? _values['es']![key] ?? key;
  }

  String get appName => _text('appName');
  String get appClaim => _text('appClaim');
  String get onboardingDescription => _text('onboardingDescription');
  String get bluetoothSecondaryClaim => _text('bluetoothSecondaryClaim');
  String get supportBrandClaim => _text('supportBrandClaim');
  String get technicalBatteryReport => _text('technicalBatteryReport');
  String get searchBattery => _text('searchBattery');
  String get connect => _text('connect');
  String get disconnect => _text('disconnect');
  String get batteryConnected => _text('batteryConnected');
  String get disconnected => _text('disconnected');
  String get status => _text('status');
  String get cells => _text('cells');
  String get history => _text('history');
  String get diagnosis => _text('diagnosis');
  String get settings => _text('settings');
  String get technicalMode => _text('technicalMode');
  String get generateTechnicalReport => _text('generateTechnicalReport');
  String get sendToInnpoSupport => _text('sendToInnpoSupport');
  String get batteryWorkingCorrectly => _text('batteryWorkingCorrectly');
  String get noActiveAlarmsDetected => _text('noActiveAlarmsDetected');
  String get batteryReviewRecommended => _text('batteryReviewRecommended');
  String get bmsProtectionActive => _text('bmsProtectionActive');
  String get chargeBlocked => _text('chargeBlocked');
  String get dischargeBlocked => _text('dischargeBlocked');
  String get cellImbalance => _text('cellImbalance');
  String get highTemperature => _text('highTemperature');
  String get lowTemperature => _text('lowTemperature');
  String get highCurrent => _text('highCurrent');
  String get lowStateOfCharge => _text('lowStateOfCharge');
  String get demoMode => _text('demoMode');
  String get registerWarranty => _text('registerWarranty');
  String get userManual => _text('userManual');
  String get maintenanceTips => _text('maintenanceTips');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return L10n.supportedLanguageCodes.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
