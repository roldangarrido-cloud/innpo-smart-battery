import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/logging/local_event_log.dart';
import '../domain/models/battery_data.dart';
import '../domain/models/battery_profile.dart';

class BmsProfileFileService {
  const BmsProfileFileService();

  Future<File> exportProfile(BatteryData battery) async {
    final profile = BatteryProfile.fromBatteryData(battery);
    final directory = await getApplicationDocumentsDirectory();
    final filename = _safeFilename(profile.name);
    final file = File('${directory.path}/$filename.json');
    final payload = const JsonEncoder.withIndent('  ').convert(
      profile.toBmsJson(
        modelName: battery.modelName,
        firmwareVersion: battery.firmwareVersion,
      ),
    );
    await file.writeAsString(payload, flush: true);
    await LocalEventLogRepository().record(
      type: AppLogEventType.configurationChange,
      message: 'Perfil BMS exportado a JSON.',
      deviceId: battery.deviceId,
      details: {'path': file.path},
    );
    return file;
  }

  Future<void> shareProfile(File file) {
    return Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Perfil BMS INNPO',
      text: 'Perfil BMS exportado desde INNPO Smart Battery.',
    );
  }

  Future<BatteryProfile?> importProfile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) {
      return null;
    }
    final content = file.bytes == null
        ? await File(file.path!).readAsString()
        : utf8.decode(file.bytes!);
    final json = jsonDecode(content) as Map<String, dynamic>;
    final profile = BatteryProfile.fromBmsJson(json);
    await LocalEventLogRepository().record(
      type: AppLogEventType.configurationChange,
      message: 'Perfil BMS importado desde JSON.',
      details: {'profileName': profile.name},
    );
    return profile;
  }

  String _safeFilename(String value) {
    return 'innpo_bms_profile_${value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';
  }
}

