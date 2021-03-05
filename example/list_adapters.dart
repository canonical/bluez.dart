import 'package:bluez/bluez.dart';

void main() async {
  var client = BlueZClient();
  await client.connect();

  if (client.adapters.isEmpty) {
    print('No Bluetooth adapters found');
    await client.close();
    return;
  }

  for (var adapter in client.adapters) {
    print('Controller ${adapter.address} ${adapter.alias}');
  }

  await client.close();
}
