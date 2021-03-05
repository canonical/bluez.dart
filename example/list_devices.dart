import 'package:bluez/bluez.dart';

void main() async {
  var client = BlueZClient();
  await client.connect();

  if (client.adapters.isEmpty) {
    print('No Bluetooth adapters found');
    await client.close();
    return;
  }

  for (var device in client.devices) {
    print('Device ${device.address} ${device.alias}');
  }

  await client.close();
}
