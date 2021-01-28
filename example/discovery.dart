import 'package:dbus/dbus.dart';
import 'package:bluez/bluez.dart';

import 'package:convert/convert.dart';

void process_ble(var device) {
  var mac = device.address;
  int rssi = device.rssi;
  print('\nName: ${device.name}');
  print('Address: ${mac}\nRSSI: ${rssi}');

  if (device.manufacturerData.isNotEmpty) {
    var mfg;
    int mfgId;
    mfg = hex.encode((device.manufacturerData.values.toList())[0]);
    mfgId = (device.manufacturerData.keys.toList())[0];
    print('ManufacturerData\n   ID: ${mfgId}\n   Data: ${mfg}');
  }

  if (device.uuids.isNotEmpty) {
    print('UUIDS');
    for (var i = 0; i < device.uuids.length; i++) {
      print('   ${device.uuids[i]}');
    }
  }

  if (device.serviceData.isNotEmpty) {
    String uuid;
    var uuid_value;
    uuid = (device.serviceData.keys.toList())[0];
    uuid_value = hex.encode((device.serviceData.values.toList())[0]);
    print('Service Data\n   UUID: ${uuid}\n   Value: ${uuid_value}');
  }
}

void main() async {
  var systemBus = DBusClient.system();
  var client = BlueZClient(systemBus);
  await client.connect();

  if (client.adapters.isEmpty) {
    print('No Bluetooth adapters found');
    await systemBus.close();
    return;
  }
  var adapter = client.adapters[0];

  print('Searching for devices on ${adapter.name}...');
  for (var device in client.devices) {
    process_ble(device);
  }
  client.deviceAddedStream.listen((device) => process_ble(device));

  await adapter.startDiscovery();

  await Future.delayed(Duration(seconds: 1));

  await adapter.stopDiscovery();

  await systemBus.close();
}
