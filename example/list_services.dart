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
    var services = device.gattServices;
    if (services.isEmpty) {
      continue;
    }
    print('Device ${device.alias}');
    await device.connect();
    for (var service in device.gattServices) {
      print('  Service ${service.uuid}');
      for (var characteristic in service.characteristics) {
        String characteristicValue;
        try {
          characteristicValue = '${await characteristic.readValue()}';
        } on BlueZNotPermittedException {
          characteristicValue = '<write only>';
        } on BlueZException catch (e) {
          characteristicValue = '<${e.message}>';
        } catch (e) {
          characteristicValue = '<$e>';
        }
        print(
            '    Characteristic ${characteristic.uuid} = $characteristicValue');
        for (var descriptor in characteristic.descriptors) {
          String descriptorValue;
          try {
            descriptorValue = '${await descriptor.readValue()}';
          } on BlueZNotPermittedException {
            descriptorValue = '<write only>';
          } on BlueZException catch (e) {
            descriptorValue = '<${e.message}>';
          } catch (e) {
            descriptorValue = '<$e>';
          }
          print('      Descriptor ${descriptor.uuid} = $descriptorValue');
        }
      }
    }
  }

  await client.close();
}
