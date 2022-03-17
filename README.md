[![Pub Package](https://img.shields.io/pub/v/bluez.svg)](https://pub.dev/packages/bluez)
[![codecov](https://codecov.io/gh/canonical/bluez.dart/branch/main/graph/badge.svg?token=95SGM9BIF5)](https://codecov.io/gh/canonical/bluez.dart)

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

## Supported platforms

This package is designed for use on Linux, as the BlueZ stack is Linux-specific
(other platforms have their own Bluetooth stacks). You can safely include this
package when writing applications that work on multiple platforms, but it will
fail with an exception when being used if the BlueZ is not present.

## Contributing to bluez.dart

We welcome contributions! See the [contribution guide](CONTRIBUTING.md) for more details.
