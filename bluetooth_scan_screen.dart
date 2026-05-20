import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../app/branding_assets.dart';
import '../../../app/localization/l10n.dart';
import '../../../core/permissions/permissions_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../battery/application/battery_providers.dart';
import '../../battery/data/bms_parser.dart';
import '../../battery/domain/models/bms_device.dart';
import '../domain/ble_device.dart';
import 'widgets/ble_signal_indicator.dart';

class BluetoothScanScreen extends ConsumerStatefulWidget {
  const BluetoothScanScreen({super.key});

  @override
  ConsumerState<BluetoothScanScreen> createState() => _BluetoothScanScreenState();
}

class _BluetoothScanScreenState extends ConsumerState<BluetoothScanScreen> {
  final _devices = <BleDevice>[];
  StreamSubscription<List<BleDevice>>? _scanSubscription;
  bool _isScanning = false;
  bool _isConnecting = false;
  String? _statusMessage;
  String? _lastDeviceId;
  String? _lastDeviceName;

  @override
  void initState() {
    super.initState();
    _loadLastDevice();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar batería'),
        actions: [
          IconButton(
            tooltip: 'Ayuda',
            onPressed: () => context.push('/help'),
            icon: const Icon(Icons.help_outline),
          ),
          IconButton(
            tooltip: 'Ajustes',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _ScanBrandHeader(),
            const SizedBox(height: 12),
            _PermissionExplanation(),
            const SizedBox(height: 12),
            if (_lastDeviceId != null) ...[
              _LastDeviceCard(
                name: _lastDeviceName ?? _lastDeviceId!,
                isConnecting: _isConnecting,
                onConnect: () => _connectToDevice(
                  BleDevice(
                    id: _lastDeviceId!,
                    name: _lastDeviceName ?? _lastDeviceId!,
                    rssi: null,
                    isInnpoCandidate: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isScanning ? null : _startScan,
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text('Buscar batería'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _isScanning ? _stopScan : null,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Detener'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/demo'),
              icon: const Icon(Icons.science_outlined),
              label: const Text('Modo demo'),
            ),
            const SizedBox(height: 16),
            if (_statusMessage != null)
              Card(
                child: ListTile(
                  leading: _isScanning || _isConnecting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.info_outline),
                  title: Text(_statusMessage!),
                ),
              ),
            if (_statusMessage != null) const SizedBox(height: 12),
            Text(
              'Dispositivos encontrados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (!_isScanning && _devices.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.search_off_outlined),
                  title: Text('No se han encontrado baterías compatibles.'),
                ),
              ),
            for (final device in _devices)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DeviceResultCard(
                  device: device,
                  isConnecting: _isConnecting,
                  onConnect: device.isInnpoCandidate
                      ? () => _connectToDevice(device)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadLastDevice() async {
    final box = Hive.box<String>(LocalStorage.appPreferencesBox);
    setState(() {
      _lastDeviceId = box.get(LocalStorage.lastConnectedDeviceIdKey);
      _lastDeviceName = box.get(LocalStorage.lastConnectedDeviceNameKey);
    });
  }

  Future<void> _startScan() async {
    setState(() {
      _devices.clear();
      _isScanning = true;
      _statusMessage = 'Buscando baterías cercanas...';
    });

    try {
      final stream = await ref
          .read(bleScannerServiceProvider)
          .scanDevices(onlyCompatible: false);
      await _scanSubscription?.cancel();
      _scanSubscription = stream.listen(
        (items) {
          setState(() {
            _devices
              ..clear()
              ..addAll(items);
            _statusMessage = items.any((device) => device.isInnpoCandidate)
                ? null
                : 'No se han encontrado baterías compatibles.';
          });
        },
        onError: (Object error) {
          setState(() {
            _isScanning = false;
            _statusMessage = error.toString();
          });
        },
      );
    } catch (error) {
      setState(() {
        _isScanning = false;
        _statusMessage = error.toString().contains('bluetooth')
            ? 'Activa el Bluetooth para continuar.'
            : error.toString();
      });
    }
  }

  Future<void> _stopScan() async {
    await _scanSubscription?.cancel();
    await ref.read(bleScannerServiceProvider).stopScan();
    setState(() {
      _isScanning = false;
      _statusMessage = _devices.isEmpty
          ? 'No se han encontrado baterías compatibles.'
          : null;
    });
  }

  Future<void> _connectToDevice(BleDevice device) async {
    setState(() {
      _isConnecting = true;
      _statusMessage = 'Conectando con la batería...';
    });

    try {
      final mockProfile = MockBmsParser.profileForDeviceId(device.id);
      if (mockProfile != null) {
        ref.read(mockBatteryProfileProvider.notifier).state = mockProfile;
        ref.read(mockBmsDemoStateProvider.notifier).state = MockBmsDemoState.normal;
      }
      await ref.read(batteryRepositoryProvider).connect(device.id);
      final box = Hive.box<String>(LocalStorage.appPreferencesBox);
      await box.put(LocalStorage.lastConnectedDeviceIdKey, device.id);
      await box.put(LocalStorage.lastConnectedDeviceNameKey, device.name);
      await ref.read(knownBatteryRepositoryProvider).save(
            BmsDevice(
              id: device.id,
              name: device.name,
              localName: device.localName,
              manufacturerName: device.manufacturerName,
              rssi: device.rssi,
              isFavorite: device.isFavorite,
              lastConnectedAt: DateTime.now(),
              batteryAlias: device.batteryAlias,
              batteryModel: device.batteryModel,
              serialNumber: device.serialNumber,
            ),
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _isConnecting = false;
        _statusMessage = 'Conexión establecida.';
        _lastDeviceId = device.id;
        _lastDeviceName = device.name;
      });
      context.push('/battery/${device.id}');
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isConnecting = false;
        _statusMessage =
            'No se pudo conectar. Comprueba que la batería esté encendida y cerca del móvil.';
      });
    }
  }
}

class _ScanBrandHeader extends StatelessWidget {
  const _ScanBrandHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const InnpoLogo(height: 38),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.bluetoothSecondaryClaim,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.bluetooth_searching,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionExplanation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permisos Bluetooth',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(PermissionRequestCopy.bluetoothRationale),
            SizedBox(height: 8),
            Text(PermissionRequestCopy.androidLocationRationale),
          ],
        ),
      ),
    );
  }
}

class _LastDeviceCard extends StatelessWidget {
  const _LastDeviceCard({
    required this.name,
    required this.isConnecting,
    required this.onConnect,
  });

  final String name;
  final bool isConnecting;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.history_outlined),
        title: Text('Ultimo dispositivo conectado'),
        subtitle: Text('$name\nAutoconexión disponible en futuras aperturas.'),
        isThreeLine: true,
        trailing: FilledButton(
          onPressed: isConnecting ? null : onConnect,
          child: const Text('Conectar'),
        ),
      ),
    );
  }
}

class _DeviceResultCard extends StatelessWidget {
  const _DeviceResultCard({
    required this.device,
    required this.isConnecting,
    required this.onConnect,
  });

  final BleDevice device;
  final bool isConnecting;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    final compatible = device.isInnpoCandidate;
    return Card(
      child: ListTile(
        leading: Icon(
          compatible ? Icons.battery_charging_full : Icons.bluetooth,
        ),
        title: Text(device.name),
        subtitle: Text(
          '${device.rssi == null ? 'RSSI no disponible' : 'RSSI ${device.rssi} dBm'}\n'
          '${compatible ? 'Compatible' : 'No identificado'}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (device.rssi != null) BleSignalIndicator(rssi: device.rssi!),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: compatible && !isConnecting ? onConnect : null,
              child: const Text('Conectar'),
            ),
          ],
        ),
      ),
    );
  }
}
