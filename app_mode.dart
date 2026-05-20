enum AppUserMode {
  customer,
  technician,
}

extension AppUserModeLabel on AppUserMode {
  String get label {
    return switch (this) {
      AppUserMode.customer => 'Cliente',
      AppUserMode.technician => 'Tecnico',
    };
  }
}

