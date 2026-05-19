import 'package:flutter_test/flutter_test.dart';
import 'package:innpo_smart_battery/features/bluetooth/data/ble_repository_impl.dart';
import 'package:innpo_smart_battery/features/bluetooth/domain/ble_connection_state.dart';

void main() {
  group('BleRepositoryImpl', () {
    test('connects mock device', () async {
      final repository = BleRepositoryImpl();
      final states = <BleConnectionState>[];
      final subscription =
          repository.connectionStates('mock-12v-100ah').listen(states.add);

      await repository.connect('mock-12v-100ah');
      await subscription.cancel();

      expect(states.map((state) => state.status), contains(BleConnectionStatus.connected));
    });

    test('disconnects mock device', () async {
      final repository = BleRepositoryImpl();
      final states = <BleConnectionState>[];
      final subscription =
          repository.connectionStates('mock-12v-100ah').listen(states.add);

      await repository.disconnect('mock-12v-100ah');
      await subscription.cancel();

      expect(states.last.status, BleConnectionStatus.disconnected);
    });

    test('streams mock data frames', () async {
      final repository = BleRepositoryImpl();

      final frame = await repository.notifications('mock-12v-100ah').first;

      expect(frame, isNotEmpty);
    });
  });
}

