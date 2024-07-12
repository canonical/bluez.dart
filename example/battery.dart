import 'package:bluez/bluez.dart';

void main() async {
  var client = BlueZClient();
  await client.connect();

  var adapter = client.adapters.first;
  var device = client.devices.first;
  var bpm = adapter.batteryProviderManager;

  var provider = await bpm.registerBatteryProvider();
  var battery = await provider.addBattery(device,
      percentage: 80, source: 'Dummy Battery');

  battery.percentage = 10;
}
