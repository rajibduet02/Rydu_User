import 'package:flutter_test/flutter_test.dart';
import 'package:rydu_user/core/device/passenger_device_identity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('stable device UUID generated once', () async {
    final prefs = await SharedPreferences.getInstance();
    var generated = 0;
    final identity = PassengerDeviceIdentity(
      prefs,
      generateId: () {
        generated++;
        return 'device-1';
      },
    );

    final first = await identity.getOrCreate();
    final second = await identity.getOrCreate();
    expect(first, 'device-1');
    expect(second, 'device-1');
    expect(generated, 1);
  });

  test('device UUID persists across instances', () async {
    final prefs = await SharedPreferences.getInstance();
    final first = PassengerDeviceIdentity(
      prefs,
      generateId: () => 'persisted-id',
    );
    expect(await first.getOrCreate(), 'persisted-id');

    final second = PassengerDeviceIdentity(
      prefs,
      generateId: () => 'should-not-run',
    );
    expect(await second.getOrCreate(), 'persisted-id');
  });

  test('logout does not clear device UUID', () async {
    final prefs = await SharedPreferences.getInstance();
    final identity = PassengerDeviceIdentity(
      prefs,
      generateId: () => 'keep-me',
    );
    expect(await identity.getOrCreate(), 'keep-me');

    // Logout clears auth keys only; device id must remain.
    await prefs.remove('backend_jwt');
    await prefs.remove('session_id');

    expect(prefs.getString(PassengerDeviceIdentity.storageKey), 'keep-me');
    final afterLogout = PassengerDeviceIdentity(
      prefs,
      generateId: () => 'new-id',
    );
    expect(await afterLogout.getOrCreate(), 'keep-me');
  });
}
