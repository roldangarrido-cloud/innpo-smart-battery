import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_mode.dart';

final appUserModeProvider = StateProvider<AppUserMode>(
  (ref) => AppUserMode.customer,
);

final isTechnicianModeProvider = Provider<bool>(
  (ref) => ref.watch(appUserModeProvider) == AppUserMode.technician,
);

