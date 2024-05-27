import 'package:bluez/bluez.dart';

void main() async {
  var client = BlueZClient();
  await client.connect();

  var adapter = client.adapters.first;
  var bpm = adapter.batteryProviderManager;

  var provider = await bpm.registerBatteryProvider();
  var battery =
      await provider.addBattery(percentage: 80, source: 'Dummy Battery');

  battery.percentage = 10;
}
