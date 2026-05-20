enum ProtectedAction {
  modifyBmsParameters,
  toggleMosfet,
  changeNominalCapacity,
  calibrateVoltageCurrent,
  restoreConfiguration,
  importProfile,
}

extension ProtectedActionLabel on ProtectedAction {
  String get title {
    return switch (this) {
      ProtectedAction.modifyBmsParameters => 'Modificar parametros BMS',
      ProtectedAction.toggleMosfet => 'Activar o desactivar MOSFET',
      ProtectedAction.changeNominalCapacity => 'Cambiar capacidad nominal',
      ProtectedAction.calibrateVoltageCurrent => 'Calibrar voltaje/corriente',
      ProtectedAction.restoreConfiguration => 'Restaurar configuracion',
      ProtectedAction.importProfile => 'Importar perfiles',
    };
  }
}

