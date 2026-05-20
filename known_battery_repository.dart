import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/local_storage.dart';
import '../domain/models/bms_device.dart';

class KnownBatteryRepository {
  Box<String> get _box => Hive.box<String>(LocalStorage.knownBatteriesBox);

  Future<void> save(BmsDevice device) async {
    await _box.put(device.id, jsonEncode(device.toJson()));
  }

  BmsDevice? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) {
      return null;
    }
    return BmsDevice.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  List<BmsDevice> getAll() {
    return _box.values
        .map((raw) => BmsDevice.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) {
        final aDate = a.lastConnectedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.lastConnectedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
  }

  Future<void> delete(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();
}

