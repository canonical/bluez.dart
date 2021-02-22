import 'package:dbus/dbus.dart';
import 'package:bluez/bluez.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = BlueZClient(systemBus);
  await client.connect();

  if (client.adapters.isEmpty) {
    print('No Bluetooth adapters found');
    await systemBus.close();
    return;
  }

  for (var device in client.devices) {
    print('Device ${device.address} ${device.alias}');
  }

  await systemBus.close();
}
