# Changelog

## 0.7.4

* Detect BlueZ D-Bus exceptions and provide classes for them.

## 0.7.3

* Report all initial adapters and devices on connect.
* Document where the values of BlueZDevice.appearance are defined.
* Add an example of how to monitor for events.
* Add tests for adapter/device property changes.

## 0.7.2

* Update to dbus 0.6.

## 0.7.1

* Fix detection of removed adapters/devices when they re-appear.
* Update README about supported platforms.

## 0.7.0

* Fix BlueZAdapter.stopDiscovery not working.
* Refactor BlueZAdapter.setDiscoveryFilter.

## 0.6.0

* Reliably detect when an object is removed.
* Update to dbus 0.5.
* Rename test file so can just run 'dart test'.

## 0.5.0

* Replace setters with methods so they can be async.

## 0.4.0

* Update to dbus 0.4.
* Change names of signal streams to match dbus.dart conventions.
* Refactor BlueZUUID.
* Change outputs from Iterable to List so can be easily indexed.
* Drop GATT prefix on variables inside GATT objects.
* Fix properties being removed when a D-Bus object is removed.
* Add regression tests.

## 0.1.4

* Bump dbus dependency to avoid another signal subscription bug.

## 0.1.3

* Bump dbus dependency to avoid a signal subscription bug.

## 0.1.2

* Make the DBusClient parameter optional.
* Add back default example for pub.dev to show.
* Fix examples not correctly closing the BlueZClient.
* Code tidy ups to pass dart analyze in 1.12 final release.

## 0.1.1

* Add initial GATT client support.
* Improve examples.

## 0.1.0

* Initial release
