import 'package:flutter_test/flutter_test.dart';
import 'package:innpo_smart_battery/core/capabilities/app_capability.dart';

void main() {
  test('core monitoring capabilities are offline-first', () {
    expect(
      offlineCapabilities,
      everyElement(
        predicate<AppCapability>(
          (capability) =>
              capability.networkRequirement == NetworkRequirement.offline,
        ),
      ),
    );
  });

  test('internet capabilities are optional or protected future work', () {
    expect(
      optionalInternetCapabilities,
      everyElement(
        predicate<AppCapability>(
          (capability) =>
              capability.networkRequirement ==
              NetworkRequirement.optionalInternet,
        ),
      ),
    );
  });
}

