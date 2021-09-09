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

This package shows on pub.dev as supporting all platforms, not just Linux.
This is because the package doesn't contain any platform specific code that would limit which platforms it can run on.
It however only makes sense on Linux, as the BlueZ stack is Linux specific, and other platforms have their own Bluetooth stacks.
You can safely include this package when writing applications that work on multiple platforms, it will fail with an exception when being used if the BlueZ is not present.
There is an [open issue](https://github.com/dart-lang/pub/issues/2353) requesting the ability to be able to show which platforms a package is intended for.

## Contributing to bluez.dart

We welcome contributions! See the [contribution guide](CONTRIBUTING.md) for more details.
