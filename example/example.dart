import 'package:dbus/dbus.dart';
import 'package:bluez/bluez.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = BlueZClient(systemBus);
  await client.connect();

  for (var device in client.devices) {
    print('Device ${device.address} ${device.alias}');
  }

  client.close();
  await systemBus.close();
}
