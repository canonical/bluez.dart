import 'package:bluez/src/bluez_advertisement.dart';
import 'package:bluez/src/bluez_battery.dart';
import 'package:bluez/src/bluez_client.dart';
import 'package:bluez/src/bluez_device.dart';
import 'package:bluez/src/bluez_enums.dart';
import 'package:bluez/src/bluez_object.dart';
import 'package:bluez/src/bluez_uuid.dart';
import 'package:dbus/dbus.dart';

/// A Bluetooth adapter.
class BlueZAdapter {
  final String _adapterInterfaceName = 'org.bluez.Adapter1';

  final BlueZClient _client;
  final BlueZObject _object;
  BlueZAdvertisingManager? _advertisingManager;
  BlueZBatteryProviderManager? _batteryProviderManager;

  BlueZAdapter(this._client, this._object);

  /// Retrive the advertisement manager associated with the adapter.
  BlueZAdvertisingManager get advertisingManager {
    _advertisingManager ??= BlueZAdvertisingManager(_client, _object);
    return _advertisingManager!;
  }

  /// Retrive the battery provider manager associated with the adapter.
  BlueZBatteryProviderManager get batteryProviderManager {
    _batteryProviderManager ??= BlueZBatteryProviderManager(_client, _object);
    return _batteryProviderManager!;
  }

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChanged {
    var interface = _object.interfaces[_adapterInterfaceName];
    if (interface == null) {
      throw 'BlueZ adapter missing $_adapterInterfaceName interface';
    }
    return interface.propertiesChangedStreamController.stream;
  }

  /// Gets the available filters that can be given to [setDiscoveryFilter].
  Future<List<String>> getDiscoveryFilters() async {
    var result = await _object.callMethod(
        _adapterInterfaceName, 'GetDiscoveryFilters', [],
        replySignature: DBusSignature('as'));
    return result.returnValues[0].asStringArray().toList();
  }

  /// Sets the device discovery filter.
  Future<void> setDiscoveryFilter(
      {List<String>? uuids,
      int? rssi,
      int? pathloss,
      String? transport,
      bool? duplicateData,
      bool? discoverable,
      String? pattern}) async {
    var filter = <String, DBusValue>{};
    if (uuids != null) {
      filter['UUIDs'] = DBusArray.string(uuids);
    }
    if (rssi != null) {
      filter['RSSI'] = DBusInt16(rssi);
    }
    if (pathloss != null) {
      filter['Pathloss'] = DBusUint16(pathloss);
    }
    if (transport != null) {
      filter['Transport'] = DBusString(transport);
    }
    if (duplicateData != null) {
      filter['DuplicateData'] = DBusBoolean(duplicateData);
    }
    if (discoverable != null) {
      filter['Discoverable'] = DBusBoolean(discoverable);
    }
    if (pattern != null) {
      filter['Pattern'] = DBusString(pattern);
    }
    await _object.callMethod(_adapterInterfaceName, 'SetDiscoveryFilter',
        [DBusDict.stringVariant(filter)],
        replySignature: DBusSignature(''));
  }

  /// Start discovery of devices on this adapter.
  Future<void> startDiscovery() async {
    await _object.callMethod(_adapterInterfaceName, 'StartDiscovery', [],
        replySignature: DBusSignature(''));
  }

  /// Stop discovery of devices on this adapter.
  Future<void> stopDiscovery() async {
    await _object.callMethod(_adapterInterfaceName, 'StopDiscovery', [],
        replySignature: DBusSignature(''));
  }

  /// Removes settings for [device] from this adapter.
  Future<void> removeDevice(BlueZDevice device) async {
    await _object.callMethod(
        _adapterInterfaceName, 'RemoveDevice', [device.path],
        replySignature: DBusSignature(''));
  }

  /// Bluetooth device address of this adapter.
  String get address =>
      _object.getStringProperty(_adapterInterfaceName, 'Address') ?? '';

  /// The Bluetooth address type.
  BlueZAddressType get addressType =>
      _object.getAddressType(_adapterInterfaceName, 'AddressType') ??
      BlueZAddressType.public;

  /// The alternative name for this adapter.
  String get alias =>
      _object.getStringProperty(_adapterInterfaceName, 'Alias') ?? '';

  /// Sets the alternative name for this adapter.
  Future<void> setAlias(String value) async {
    await _object.setProperty(
        _adapterInterfaceName, 'Alias', DBusString(value));
  }

  /// Bluetooth device class.
  int get deviceClass =>
      _object.getUint32Property(_adapterInterfaceName, 'Class') ?? 0;

  /// True if this adapter is discoverable by other Bluetooth devices.
  bool get discoverable =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Discoverable') ??
      false;

  /// Sets if this adapter can be discovered by other Bluetooth devices.
  Future<void> setDiscoverable(bool value) async {
    await _object.setProperty(
        _adapterInterfaceName, 'Discoverable', DBusBoolean(value));
  }

  int get discoverableTimeout =>
      _object.getUint32Property(_adapterInterfaceName, 'DiscoverableTimeout') ??
      0;

  Future<void> setDiscoverableTimeout(int value) async {
    await _object.setProperty(
        _adapterInterfaceName, 'DiscoverableTimeout', DBusUint32(value));
  }

  /// True if currently discovering devices.
  bool get discovering =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Discovering') ?? false;

  /// Local Device ID information in modalias format used by the kernel and udev.
  String get modalias =>
      _object.getStringProperty(_adapterInterfaceName, 'Modalias') ?? '';

  /// Name of this adapter.
  String get name =>
      _object.getStringProperty(_adapterInterfaceName, 'Name') ?? '';

  /// True if other Bluetooth devices can pair with this adapter.
  bool get pairable =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Pairable') ?? false;

  /// Sets if other Bluetooth devices can pair with this adapter.
  Future<void> setPairable(bool value) async {
    await _object.setProperty(
        _adapterInterfaceName, 'Pairable', DBusBoolean(value));
  }

  /// Timeout in seconds when pairing.
  int get pairableTimeout =>
      _object.getUint32Property(_adapterInterfaceName, 'PairableTimeout') ?? 0;

  /// Sets the timeout in seconds when pairing.
  Future<void> setPairableTimeout(int value) async {
    await _object.setProperty(
        _adapterInterfaceName, 'PairableTimeout', DBusUint32(value));
  }

  /// True if this adapter is powered on.
  bool get powered =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Powered') ?? false;

  /// Sets if this adapter is powered on.
  Future<void> setPowered(bool value) async {
    await _object.setProperty(
        _adapterInterfaceName, 'Powered', DBusBoolean(value));
  }

  List<String> get roles =>
      _object.getStringArrayProperty(_adapterInterfaceName, 'Roles') ?? [];

  /// List of 128-bit UUIDs that represents the available local services.
  List<BlueZUUID> get uuids =>
      (_object.getStringArrayProperty(_adapterInterfaceName, 'UUIDs') ?? [])
          .map((value) => BlueZUUID.fromString(value))
          .toList();
}
