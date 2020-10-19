[![Pub Package](https://img.shields.io/pub/v/bluez.svg)](https://pub.dev/packages/bluez)

Provides a client to connect to [BlueZ](http://www.bluez.org/) - the Linux Bluetooth stack.

```dart
import 'package:dbus/dbus.dart';
import 'package:bluez/bluez.dart';

var systemBus = DBusClient.system();
var client = BlueZClient(systemBus);
await client.connect();

print('Devices:');
for (var device in client.devices) {
  print('  ${device.name}');
}

await systemBus.close();
```

## Contributing to bluez.dart

We welcome contributions! See the [contribution guide](CONTRIBUTING.md) for more details.
