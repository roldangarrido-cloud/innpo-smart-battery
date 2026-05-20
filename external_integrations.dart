import '../../features/battery/domain/models/battery_data.dart';
import '../../features/battery/domain/models/diagnostic_report.dart';

abstract interface class SupportGateway {
  Future<void> sendDiagnostic({
    required BatteryData battery,
    required DiagnosticReport diagnostic,
    required List<int> pdfBytes,
  });
}

abstract interface class WarrantyGateway {
  Future<void> registerWarranty({
    required String serialNumber,
    required String customerReference,
  });
}

abstract interface class CloudHistoryGateway {
  Future<void> syncBatterySnapshot(BatteryData battery);
}

abstract interface class FirmwareUpdateGateway {
  Future<void> checkForUpdates({
    required String model,
    required String firmwareVersion,
  });
}

abstract interface class BusinessSystemGateway {
  Future<void> createSupportCase({
    required String source,
    required String serialNumber,
    required String summary,
  });
}
