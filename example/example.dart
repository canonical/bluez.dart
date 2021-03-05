import 'package:bluez/bluez.dart';

void main() async {
  var client = BlueZClient();
  await client.connect();

  for (var device in client.devices) {
    print('Device ${device.address} ${device.alias}');
  }

  await client.close();
}
