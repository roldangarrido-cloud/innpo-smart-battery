import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'secure_settings.dart';
import 'technical_access_controller.dart';

final secureSettingsProvider = Provider<SecureSettings>(
  (ref) => SecureSettings(),
);

final technicalAccessControllerProvider = Provider<TechnicalAccessController>(
  (ref) => TechnicalAccessController(
    secureSettings: ref.watch(secureSettingsProvider),
  ),
);

