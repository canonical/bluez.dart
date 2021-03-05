[![Pub Package](https://img.shields.io/pub/v/bluez.svg)](https://pub.dev/packages/bluez)

Provides a client to connect to [BlueZ](http://www.bluez.org/) - the Linux Bluetooth stack.

```dart
import 'package:bluez/bluez.dart';

var client = BlueZClient();
await client.connect();

for (var device in client.devices) {
  print('Device ${device.address} ${device.alias}');
}

await client.close();
```

## Contributing to bluez.dart

We welcome contributions! See the [contribution guide](CONTRIBUTING.md) for more details.
