enum NetworkRequirement {
  offline,
  optionalInternet,
}

enum CapabilityRisk {
  safe,
  protected,
  future,
}

class AppCapability {
  const AppCapability({
    required this.id,
    required this.title,
    required this.description,
    required this.networkRequirement,
    required this.risk,
  });

  final String id;
  final String title;
  final String description;
  final NetworkRequirement networkRequirement;
  final CapabilityRisk risk;
}

const offlineCapabilities = [
  AppCapability(
    id: 'ble-connect',
    title: 'Conexion Bluetooth',
    description: 'Escaneo, conexion y lectura de datos BMS mediante BLE.',
    networkRequirement: NetworkRequirement.offline,
    risk: CapabilityRisk.safe,
  ),
  AppCapability(
    id: 'local-diagnostics',
    title: 'Diagnostico local',
    description: 'Reglas locales para traducir datos tecnicos a estados claros.',
    networkRequirement: NetworkRequirement.offline,
    risk: CapabilityRisk.safe,
  ),
  AppCapability(
    id: 'local-pdf',
    title: 'Informe PDF local',
    description: 'Generacion de informes sin depender de servidores externos.',
    networkRequirement: NetworkRequirement.offline,
    risk: CapabilityRisk.safe,
  ),
  AppCapability(
    id: 'local-help',
    title: 'Ayuda basica local',
    description: 'Guia de estados, alarmas y acciones recomendadas integrada.',
    networkRequirement: NetworkRequirement.offline,
    risk: CapabilityRisk.safe,
  ),
];

const optionalInternetCapabilities = [
  AppCapability(
    id: 'support-send',
    title: 'Enviar diagnostico a soporte',
    description: 'Envio opcional de informe y logs al soporte INNPO.',
    networkRequirement: NetworkRequirement.optionalInternet,
    risk: CapabilityRisk.future,
  ),
  AppCapability(
    id: 'warranty',
    title: 'Registro de garantia',
    description: 'Registro opcional de garantia y datos de compra.',
    networkRequirement: NetworkRequirement.optionalInternet,
    risk: CapabilityRisk.future,
  ),
  AppCapability(
    id: 'cloud-history',
    title: 'Historico en la nube',
    description: 'Sincronizacion futura de sesiones, flotas y panel web.',
    networkRequirement: NetworkRequirement.optionalInternet,
    risk: CapabilityRisk.future,
  ),
  AppCapability(
    id: 'firmware-update',
    title: 'Actualizacion de firmware',
    description: 'Disponible solo si el BMS soporta firmware update seguro.',
    networkRequirement: NetworkRequirement.optionalInternet,
    risk: CapabilityRisk.protected,
  ),
];

