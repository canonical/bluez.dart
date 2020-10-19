import 'package:dbus/dbus.dart';
import 'package:bluez/bluez.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = BlueZClient(systemBus);
  await client.connect();

  print('Devices:');
  for (var device in client.devices) {
    print('  ${device.name}');
  }

  await systemBus.close();
}
