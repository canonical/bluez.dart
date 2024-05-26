import 'package:dbus/dbus.dart';
import 'package:bluez/bluez.dart';

void main() async {
  var client = BlueZClient();
  await client.connect();

  var adapter = client.adapters.first;
  var advertMngr = adapter.advertisingManager;

  await advertMngr.registerAdvertisement(
    type: BlueZAdvertisementType.broadcast,
    manufacturerData: {
      BlueZManufacturerId(0x004c): DBusArray.byte([
        0x02,
        0x15,
        0xE2,
        0xC5,
        0x6D,
        0xB5,
        0xDF,
        0xFB,
        0x48,
        0xD2,
        0xB0,
        0x60,
        0xD0,
        0xF5,
        0xA7,
        0x10,
        0x96,
        0xE0,
        0x00,
        0x01,
        0x00,
        0x02,
        0x0c
      ]),
    },
    localName: 'Example Advert',
  );

  while (true) {}
}
