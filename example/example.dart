import 'package:dbus/dbus.dart';
import 'package:bluez/bluez.dart';

void main() async {
  var systemBus = DBusClient.system();
  var client = BlueZClient(systemBus);
  await client.connect();
  await systemBus.close();
}
