import 'dart:async';

import 'package:dbus/dbus.dart';

import 'bluez_uuid.dart';

/// Types of Bluetooth address.
enum BlueZAddressType { public, random }

/// Types of writes to a GATT characteristic.
enum BlueZGattCharacteristicWriteType { command, request, reliable }

/// Defines how a GATT characteristic value can be used.
enum BlueZGattCharacteristicFlag {
  broadcast,
  read,
  writeWithoutResponse,
  write,
  notify,
  indicate,
  authenticatedSignedWrites,
  extendedProperties,
  reliableWrite,
  writableAuxiliaries,
  encryptRead,
  encryptWrite,
  encryptAuthenticatedRead,
  encryptAuthenticatedWrite,
  secureRead,
  secureWrite,
  authorize,
}

/// Bluetooth manufacturer Id.
class BlueZManufacturerId {
  final int id;

  const BlueZManufacturerId(this.id);

  @override
  String toString() => "BlueZManufacturerId('$id')";

  @override
  bool operator ==(other) => other is BlueZManufacturerId && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

final _bluezAddressTypeMap = <String, BlueZAddressType>{
  'public': BlueZAddressType.public,
  'random': BlueZAddressType.random
};

/// A Bluetooth adapter.
class BlueZAdapter {
  final String _adapterInterfaceName = 'org.bluez.Adapter1';

  final _BlueZObject _object;

  BlueZAdapter(this._object);

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
    var result = await _object
        .callMethod(_adapterInterfaceName, 'GetDiscoveryFilters', []);
    var values = result.returnValues;
    if (values.length != 1 || values[0].signature != DBusSignature('as')) {
      throw 'GetDiscoveryFilters returned invalid result: $values';
    }
    return (values[0] as DBusArray)
        .children
        .map((v) => (v as DBusString).value)
        .toList();
  }

  /// Sets the device discovery filter for the caller. [filter] contains filter values as returnd by [getDiscoveryFilters].
  Future<void> setDiscoveryFilter(Map<String, DBusValue> filter) async {
    await _object.callMethod(_adapterInterfaceName, 'SetDiscoveryFilter',
        [DBusDict.stringVariant(filter)]);
  }

  /// Start discovery of devices on this adapter.
  Future<void> startDiscovery() async {
    await _object.callMethod(_adapterInterfaceName, 'StartDiscovery', []);
  }

  /// Stop discovery of devices on this adapter.
  Future<void> stopDiscovery() async {
    await _object.callMethod(_adapterInterfaceName, 'stopDiscovery', []);
  }

  /// Removes settings for [device] from this adapter.
  Future<void> removeDevice(BlueZDevice device) async {
    await _object.callMethod(
        _adapterInterfaceName, 'RemoveDevice', [device._object.path]);
  }

  /// Bluetooth device address of this adapter.
  String get address =>
      _object.getStringProperty(_adapterInterfaceName, 'Address') ?? '';

  /// The Bluetooth address type.
  BlueZAddressType get addressType =>
      _bluezAddressTypeMap[
          _object.getStringProperty(_adapterInterfaceName, 'AddressType') ??
              ''] ??
      BlueZAddressType.public;

  /// The alternative name for this adapter.
  String get alias =>
      _object.getStringProperty(_adapterInterfaceName, 'Alias') ?? '';

  /// Sets the alternative name for this adapter.
  set alias(String value) =>
      _object.setProperty(_adapterInterfaceName, 'Alias', DBusString(value));

  /// Bluetooth device class.
  int get deviceClass =>
      _object.getUint32Property(_adapterInterfaceName, 'Class') ?? 0;

  /// True if this adapter is discoverable by other Bluetooth devices.
  bool get discoverable =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Discoverable') ??
      false;

  /// Sets if this adapter can be discovered by other Bluetooth devices.
  set discoverable(bool value) => _object.setProperty(
      _adapterInterfaceName, 'Discoverable', DBusBoolean(value));

  int get discoverableTimeout =>
      _object.getUint32Property(_adapterInterfaceName, 'DiscoverableTimeout') ??
      0;

  set discoverableTimeout(int value) => _object.setProperty(
      _adapterInterfaceName, 'DiscoverableTimeout', DBusUint32(value));

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
  set pairable(bool value) => _object.setProperty(
      _adapterInterfaceName, 'Pairable', DBusBoolean(value));

  /// Timeout in seconds when pairing.
  int get pairableTimeout =>
      _object.getUint32Property(_adapterInterfaceName, 'PairableTimeout') ?? 0;

  /// Sets the timeout in seconds when pairing.
  set pairableTimeout(int value) => _object.setProperty(
      _adapterInterfaceName, 'PairableTimeout', DBusUint32(value));

  /// True if this adapter is powered on.
  bool get powered =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Powered') ?? false;

  /// Sets if this adapter is powered on.
  set powered(bool value) =>
      _object.setProperty(_adapterInterfaceName, 'Powered', DBusBoolean(value));

  List<String> get roles =>
      _object.getStringArrayProperty(_adapterInterfaceName, 'Roles') ?? [];

  /// List of 128-bit UUIDs that represents the available local services.
  List<BlueZUUID> get uuids {
    var value = _object.getStringArrayProperty(_adapterInterfaceName, 'UUIDs');
    return value != null
        ? value.map((value) => BlueZUUID.fromString(value)).toList()
        : [];
  }
}

/// A GATT service running on a BlueZ device.
class BlueZGattService {
  final String _serviceInterfaceName = 'org.bluez.GattService1';

  final BlueZClient _client;
  final _BlueZObject _object;

  BlueZGattService(this._client, this._object);

  // TODO(robert-ancell): Includes

  /// True if this is a primary service.
  bool get primary =>
      _object.getBooleanProperty(_serviceInterfaceName, 'Primary') ?? false;

  /// Unique ID for this service.
  BlueZUUID get uuid => BlueZUUID.fromString(
      _object.getStringProperty(_serviceInterfaceName, 'UUID') ?? '');

  /// The Gatt characteristics provided by this service.
  List<BlueZGattCharacteristic> get characteristics =>
      _client._getGattCharacteristics(_object.path);
}

/// A characteristic of a GATT service.
class BlueZGattCharacteristic {
  final String _gattCharacteristicInterfaceName =
      'org.bluez.GattCharacteristic1';

  final BlueZClient _client;
  final _BlueZObject _object;

  BlueZGattCharacteristic(this._client, this._object);

  // TODO(robert-ancell): Includes

  /// Unique ID for this characteristic.
  BlueZUUID get uuid => BlueZUUID.fromString(
      _object.getStringProperty(_gattCharacteristicInterfaceName, 'UUID') ??
          '');

  /// Cached value of this characteristic, updated when [readValue] is called.
  List<int> get value =>
      _object.getByteArrayProperty(_gattCharacteristicInterfaceName, 'Value') ??
      [];

  /// Defines how this characteristic value can be used.
  Set<BlueZGattCharacteristicFlag> get flags {
    var flags = <BlueZGattCharacteristicFlag>{};
    var values = _object.getStringArrayProperty(
            _gattCharacteristicInterfaceName, 'Flags') ??
        [];
    for (var value in values) {
      switch (value) {
        case 'broadcast':
          flags.add(BlueZGattCharacteristicFlag.broadcast);
          break;
        case 'read':
          flags.add(BlueZGattCharacteristicFlag.read);
          break;
        case 'write-without-response':
          flags.add(BlueZGattCharacteristicFlag.writeWithoutResponse);
          break;
        case 'write':
          flags.add(BlueZGattCharacteristicFlag.write);
          break;
        case 'notify':
          flags.add(BlueZGattCharacteristicFlag.notify);
          break;
        case 'indicate':
          flags.add(BlueZGattCharacteristicFlag.indicate);
          break;
        case 'authenticated-signed-writes':
          flags.add(BlueZGattCharacteristicFlag.authenticatedSignedWrites);
          break;
        case 'extended-properties':
          flags.add(BlueZGattCharacteristicFlag.extendedProperties);
          break;
        case 'reliable-write':
          flags.add(BlueZGattCharacteristicFlag.reliableWrite);
          break;
        case 'writable-auxiliaries':
          flags.add(BlueZGattCharacteristicFlag.writableAuxiliaries);
          break;
        case 'encrypt-read':
          flags.add(BlueZGattCharacteristicFlag.encryptRead);
          break;
        case 'encrypt-write':
          flags.add(BlueZGattCharacteristicFlag.encryptWrite);
          break;
        case 'encrypt-authenticated-read':
          flags.add(BlueZGattCharacteristicFlag.encryptAuthenticatedRead);
          break;
        case 'encrypt-authenticated-write':
          flags.add(BlueZGattCharacteristicFlag.encryptAuthenticatedWrite);
          break;
        case 'secure-read':
          flags.add(BlueZGattCharacteristicFlag.secureRead);
          break;
        case 'secure-write':
          flags.add(BlueZGattCharacteristicFlag.secureWrite);
          break;
        case 'authorize':
          flags.add(BlueZGattCharacteristicFlag.authorize);
          break;
      }
    }
    return flags;
  }

  // TODO(robert-ancell): Functions that require fd manipulation - StartNotify(), StopNotify(), AcquireNotify(), NotifyAcquired, Notifying, AcquireWrite(), WriteAcquired

  /// The Gatt descriptors provided by this characteristic.
  List<BlueZGattDescriptor> get descriptors =>
      _client._getGattDescriptors(_object.path);

  /// Reads the value of the characteristic.
  Future<List<int>> readValue({int? offset}) async {
    var options = <String, DBusValue>{};
    if (offset != null) {
      options['offset'] = DBusUint16(offset);
    }
    var result = await _object.callMethod(_gattCharacteristicInterfaceName,
        'ReadValue', [DBusDict.stringVariant(options)]);
    var values = result.returnValues;
    if (values.length != 1 || values[0].signature != DBusSignature('ay')) {
      throw 'org.bluez.GattCharacteristic1.ReadValue returned invalid result: $values';
    }
    return (values[0] as DBusArray)
        .children
        .map((value) => (value as DBusByte).value)
        .toList();
  }

  /// Writes [data] to the characteristic.
  Future<void> writeValue(Iterable<int> data,
      {int? offset,
      BlueZGattCharacteristicWriteType? type,
      bool? prepareAuthorize}) async {
    var options = <String, DBusValue>{};
    if (offset != null) {
      options['offset'] = DBusUint16(offset);
    }
    if (type != null) {
      String typeName;
      switch (type) {
        case BlueZGattCharacteristicWriteType.command:
          typeName = 'command';
          break;
        case BlueZGattCharacteristicWriteType.request:
          typeName = 'request';
          break;
        case BlueZGattCharacteristicWriteType.reliable:
          typeName = 'reliable';
          break;
      }
      options['type'] = DBusString(typeName);
    }
    if (prepareAuthorize != null) {
      options['prepare-authorize'] = DBusBoolean(prepareAuthorize);
    }
    var result = await _object.callMethod(_gattCharacteristicInterfaceName,
        'WriteValue', [DBusArray.byte(data), DBusDict.stringVariant(options)]);
    var values = result.returnValues;
    if (values.isNotEmpty) {
      throw 'org.bluez.GattCharacteristic1.WriteValue returned invalid result: $values';
    }
  }
}

/// A GATT characteristic descriptor.
class BlueZGattDescriptor {
  final String _gattDescriptorInterfaceName = 'org.bluez.GattDescriptor1';

  final _BlueZObject _object;

  BlueZGattDescriptor(this._object);

  // TODO(robert-ancell): Includes

  /// Cached value of this descriptor, updated when [readValue] is called.
  List<int> get value =>
      _object.getByteArrayProperty(_gattDescriptorInterfaceName, 'Value') ?? [];

  /// Unique ID for this descriptor.
  BlueZUUID get uuid => BlueZUUID.fromString(
      _object.getStringProperty(_gattDescriptorInterfaceName, 'UUID') ?? '');

  /// Reads the value of the descriptor.
  Future<List<int>> readValue({int? offset}) async {
    var options = <String, DBusValue>{};
    if (offset != null) {
      options['offset'] = DBusUint16(offset);
    }
    var result = await _object.callMethod(_gattDescriptorInterfaceName,
        'ReadValue', [DBusDict.stringVariant(options)]);
    var values = result.returnValues;
    if (values.length != 1 || values[0].signature != DBusSignature('ay')) {
      throw 'org.bluez.GattDescriptor1.ReadValue returned invalid result: $values';
    }
    return (values[0] as DBusArray)
        .children
        .map((value) => (value as DBusByte).value)
        .toList();
  }

  /// Writes [data] to the descriptor.
  Future<void> writeValue(Iterable<int> data,
      {int? offset, bool? prepareAuthorize}) async {
    var options = <String, DBusValue>{};
    if (offset != null) {
      options['offset'] = DBusUint16(offset);
    }
    if (prepareAuthorize != null) {
      options['prepare-authorize'] = DBusBoolean(prepareAuthorize);
    }
    var result = await _object.callMethod(_gattDescriptorInterfaceName,
        'WriteValue', [DBusArray.byte(data), DBusDict.stringVariant(options)]);
    var values = result.returnValues;
    if (values.isNotEmpty) {
      throw 'org.bluez.GattDescriptor1.WriteValue returned invalid result: $values';
    }
  }
}

/// A Bluetooth device.
class BlueZDevice {
  final String _deviceInterfaceName = 'org.bluez.Device1';

  final BlueZClient _client;
  final _BlueZObject _object;

  BlueZDevice(this._client, this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChanged {
    var interface = _object.interfaces[_deviceInterfaceName];
    if (interface == null) {
      throw 'BlueZ device missing $_deviceInterfaceName interface';
    }
    return interface.propertiesChangedStreamController.stream;
  }

  /// Connect to this device.
  Future<void> connect() async {
    await _object.callMethod(_deviceInterfaceName, 'Connect', []);
  }

  /// Disconnect from this device
  Future<void> disconnect() async {
    await _object.callMethod(_deviceInterfaceName, 'Disconnect', []);
  }

  /// Connects to the service with [uuid].
  Future<void> connectProfile(BlueZUUID uuid) async {
    await _object.callMethod(
        _deviceInterfaceName, 'ConnectProfile', [DBusString(uuid.toString())]);
  }

  /// Disconnects the service with [uuid].
  Future<void> disconnectProfile(BlueZUUID uuid) async {
    await _object.callMethod(_deviceInterfaceName, 'DisconnectProfile',
        [DBusString(uuid.toString())]);
  }

  /// Pair with this device.
  Future<void> pair() async {
    await _object.callMethod(_deviceInterfaceName, 'Pair', []);
  }

  /// Cancel a pairing that is in progress.
  Future<void> cancelPairing() async {
    await _object.callMethod(_deviceInterfaceName, 'CancelPairing', []);
  }

  /// The adapter this device belongs to.
  BlueZAdapter? get adapter {
    var objectPath =
        _object.getObjectPathProperty(_deviceInterfaceName, 'Adapter');
    return objectPath != null ? _client._getAdapter(objectPath) : null;
  }

  /// MAC address of this device.
  String get address =>
      _object.getStringProperty(_deviceInterfaceName, 'Address') ?? '';

  /// The Bluetooth device address type.
  BlueZAddressType get addressType =>
      _bluezAddressTypeMap[
          _object.getStringProperty(_deviceInterfaceName, 'AddressType') ??
              ''] ??
      BlueZAddressType.public;

  /// An alternative name for this device.
  String get alias =>
      _object.getStringProperty(_deviceInterfaceName, 'Alias') ?? '';

  /// Sets the alternative name for this device.
  set alias(String value) =>
      _object.setProperty(_deviceInterfaceName, 'Alias', DBusString(value));

  /// External appearance of device, as found on GAP service.
  int get appearance =>
      _object.getUint16Property(_deviceInterfaceName, 'Appearance') ?? 0;

  /// True if connections from this device will be ignored.
  bool get blocked =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Blocked') ?? false;

  /// Sets if connections from this device will be ignored.
  set blocked(bool value) =>
      _object.setProperty(_deviceInterfaceName, 'Blocked', DBusBoolean(value));

  /// True if this device is currently connected.
  bool get connected =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Connected') ?? false;

  /// Bluetooth device class.
  int get deviceClass =>
      _object.getUint32Property(_deviceInterfaceName, 'Class') ?? 0;

  /// True if this device only supports the pre-2.1 pairing mechanism.
  bool get legacyPairing =>
      _object.getBooleanProperty(_deviceInterfaceName, 'LegacyPairing') ??
      false;

  /// Icon name for this device.
  String get icon =>
      _object.getStringProperty(_deviceInterfaceName, 'Icon') ?? '';

  /// Manufacturer specific advertisement data.
  Map<BlueZManufacturerId, List<int>> get manufacturerData {
    var value =
        _object.getCachedProperty(_deviceInterfaceName, 'ManufacturerData');
    if (value == null) {
      return {};
    }
    if (value.signature != DBusSignature('a{qv}')) {
      return {};
    }
    List<int> processValue(DBusValue value) {
      if (value.signature != DBusSignature('ay')) {
        return [];
      }
      return (value as DBusArray)
          .children
          .map((value) => (value as DBusByte).value)
          .toList();
    }

    return (value as DBusDict).children.map((key, value) => MapEntry(
        BlueZManufacturerId((key as DBusUint16).value),
        processValue((value as DBusVariant).value)));
  }

  /// Remote Device ID information in modalias format used by the kernel and udev.
  String get modalias =>
      _object.getStringProperty(_deviceInterfaceName, 'Modalias') ?? '';

  /// Name of this device.
  String get name =>
      _object.getStringProperty(_deviceInterfaceName, 'Name') ?? '';

  /// True if the device is currently paired.
  bool get paired =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Paired') ?? false;

  /// Signal strength received from the devide.
  int get rssi => _object.getInt16Property(_deviceInterfaceName, 'RSSI') ?? 0;

  /// Service advertisement data.
  Map<BlueZUUID, List<int>> get serviceData {
    var value = _object.getCachedProperty(_deviceInterfaceName, 'ServiceData');
    if (value == null) {
      return {};
    }
    if (value.signature != DBusSignature('a{sv}')) {
      return {};
    }
    List<int> processValue(DBusValue value) {
      if (value.signature != DBusSignature('ay')) {
        return [];
      }
      return (value as DBusArray)
          .children
          .map((value) => (value as DBusByte).value)
          .toList();
    }

    return (value as DBusDict).children.map((key, value) => MapEntry(
        BlueZUUID.fromString((key as DBusString).value),
        processValue((value as DBusVariant).value)));
  }

  /// True if service discovery has been resolved.
  bool get servicesResolved =>
      _object.getBooleanProperty(_deviceInterfaceName, 'ServicesResolved') ??
      false;

  /// True if the remote is seen as trusted.
  bool get trusted =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Trusted') ?? false;

  /// Sets if the remote is seen as trusted.
  set trusted(bool value) =>
      _object.setProperty(_deviceInterfaceName, 'Trusted', DBusBoolean(value));

  /// Advertised transmit power level.
  int get txPower =>
      _object.getInt16Property(_deviceInterfaceName, 'TxPower') ?? 0;

  /// UUIDs that indicate the available remote services.
  List<BlueZUUID> get uuids {
    var value = _object.getStringArrayProperty(_deviceInterfaceName, 'UUIDs');
    return value != null
        ? value.map((value) => BlueZUUID.fromString(value)).toList()
        : [];
  }

  /// True if the device can wake the host from system suspend.
  bool get wakeAllowed =>
      _object.getBooleanProperty(_deviceInterfaceName, 'WakeAllowed') ?? false;

  /// Sets if the device can wake the host from system suspend.
  set wakeAllowed(bool value) => _object.setProperty(
      _deviceInterfaceName, 'WakeAllowed', DBusBoolean(value));

  /// The Gatt services provided by this device.
  List<BlueZGattService> get gattServices =>
      _client._getGattServices(_object.path);
}

class _BlueZInterface {
  final Map<String, DBusValue> properties;
  final propertiesChangedStreamController =
      StreamController<List<String>>.broadcast();

  Stream<List<String>> get propertiesChanged =>
      propertiesChangedStreamController.stream;

  _BlueZInterface(this.properties);

  void updateProperties(Map<String, DBusValue> changedProperties) {
    properties.addAll(changedProperties);
    propertiesChangedStreamController.add(changedProperties.keys.toList());
  }
}

class _BlueZObject extends DBusRemoteObject {
  final interfaces = <String, _BlueZInterface>{};

  void updateInterfaces(
      Map<String, Map<String, DBusValue>> interfacesAndProperties) {
    interfacesAndProperties.forEach((interfaceName, properties) {
      interfaces[interfaceName] = _BlueZInterface(properties);
    });
  }

  void updateProperties(
      String interfaceName, Map<String, DBusValue> changedProperties) {
    var interface = interfaces[interfaceName];
    if (interface != null) {
      interface.updateProperties(changedProperties);
    }
  }

  /// Gets a cached property.
  DBusValue? getCachedProperty(String interfaceName, String name) {
    var interface = interfaces[interfaceName];
    if (interface == null) {
      return null;
    }
    return interface.properties[name];
  }

  /// Gets a cached boolean property, or returns null if not present or not the correct type.
  bool? getBooleanProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('b')) {
      return null;
    }
    return (value as DBusBoolean).value;
  }

  /// Gets a cached byte array property, or returns null if not present or not the correct type.
  List<int>? getByteArrayProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('ay')) {
      return null;
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusByte).value)
        .toList();
  }

  /// Gets a cached signed 16 bit integer property, or returns null if not present or not the correct type.
  int? getInt16Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('n')) {
      return null;
    }
    return (value as DBusInt16).value;
  }

  /// Gets a cached unsigned 16 bit integer property, or returns null if not present or not the correct type.
  int? getUint16Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('q')) {
      return null;
    }
    return (value as DBusUint16).value;
  }

  /// Gets a cached unsigned 32 bit integer property, or returns null if not present or not the correct type.
  int? getUint32Property(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('u')) {
      return null;
    }
    return (value as DBusUint32).value;
  }

  /// Gets a cached string property, or returns null if not present or not the correct type.
  String? getStringProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('s')) {
      return null;
    }
    return (value as DBusString).value;
  }

  /// Gets a cached string array property, or returns null if not present or not the correct type.
  List<String>? getStringArrayProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('as')) {
      return null;
    }
    return (value as DBusArray)
        .children
        .map((e) => (e as DBusString).value)
        .toList();
  }

  /// Gets a cached object path property, or returns null if not present or not the correct type.
  DBusObjectPath? getObjectPathProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('o')) {
      return null;
    }
    return (value as DBusObjectPath);
  }

  _BlueZObject(DBusClient client, DBusObjectPath path,
      Map<String, Map<String, DBusValue>> interfacesAndProperties)
      : super(client, 'org.bluez', path) {
    updateInterfaces(interfacesAndProperties);
  }
}

/// A client that connects to BlueZ.
class BlueZClient {
  /// Stream of adapters as they are added.
  Stream<BlueZAdapter> get adapterAdded => _adapterAddedStreamController.stream;

  /// Stream of adapters as they are removed.
  Stream<BlueZAdapter> get adapterRemoved =>
      _adapterRemovedStreamController.stream;

  /// Stream of devices as they are added.
  Stream<BlueZDevice> get deviceAdded => _deviceAddedStreamController.stream;

  /// Stream of devices as they are removed.
  Stream<BlueZDevice> get deviceRemoved =>
      _deviceRemovedStreamController.stream;

  /// The bus this client is connected to.
  final DBusClient _bus;
  final bool _closeBus;

  /// The root D-Bus BlueZ object.
  late final DBusRemoteObjectManager _root;

  // Objects exported on the bus.
  final _objects = <DBusObjectPath, _BlueZObject>{};

  // Subscription to object manager signals.
  StreamSubscription? _objectManagerSubscription;

  final _adapterAddedStreamController =
      StreamController<BlueZAdapter>.broadcast();
  final _adapterRemovedStreamController =
      StreamController<BlueZAdapter>.broadcast();
  final _deviceAddedStreamController =
      StreamController<BlueZDevice>.broadcast();
  final _deviceRemovedStreamController =
      StreamController<BlueZDevice>.broadcast();

  /// Creates a new BlueZ client. If [bus] is provided connect to the given D-Bus server.
  BlueZClient({DBusClient? bus})
      : _bus = bus ?? DBusClient.system(),
        _closeBus = bus == null {
    _root = DBusRemoteObjectManager(_bus, 'org.bluez', DBusObjectPath('/'));
  }

  /// Connects to the BlueZ daemon.
  /// Must be called before accessing methods and properties.
  Future<void> connect() async {
    // Already connected
    if (_objectManagerSubscription != null) {
      return;
    }

    // Subscribe to changes
    _objectManagerSubscription = _root.signals.listen((signal) {
      if (signal is DBusObjectManagerInterfacesAddedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          object.updateInterfaces(signal.interfacesAndProperties);
        } else {
          object = _BlueZObject(
              _bus, signal.changedPath, signal.interfacesAndProperties);
          _objects[signal.changedPath] = object;
          if (_isAdapter(object)) {
            _adapterAddedStreamController.add(BlueZAdapter(object));
          } else if (_isDevice(object)) {
            _deviceAddedStreamController.add(BlueZDevice(this, object));
          }
        }
      } else if (signal is DBusObjectManagerInterfacesRemovedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          if (signal.interfaces.contains('org.bluez.Adapter1')) {
            _adapterRemovedStreamController.add(BlueZAdapter(object));
          } else if (signal.interfaces.contains('org.bluez.Device1')) {
            _deviceRemovedStreamController.add(BlueZDevice(this, object));
          }
          // Note that if not all the interfaces were removed then the object still exists.
          // But in the case of BlueZ the only objects we care about only drop interfaces
          // when they are completely removed.
          // Since we don't take a copy of the existing object we don't remove the interfaces
          // as the BlueZClient consumer will want the last values when they read the object
          // from the stream.
          _objects.remove(object);
        }
      } else if (signal is DBusPropertiesChangedSignal) {
        var object = _objects[signal.path];
        if (object != null) {
          object.updateProperties(
              signal.propertiesInterface, signal.changedProperties);
        }
      }
    });

    // Find all the objects exported.
    var objects = await _root.getManagedObjects();
    objects.forEach((objectPath, interfacesAndProperties) {
      _objects[objectPath] =
          _BlueZObject(_bus, objectPath, interfacesAndProperties);
    });
  }

  /// The adapters present on this system.
  /// Use [adapterAdded] and [adapterRemoved] to detect when this list changes.
  List<BlueZAdapter> get adapters {
    var adapters = <BlueZAdapter>[];
    for (var object in _objects.values) {
      if (_isAdapter(object)) {
        adapters.add(BlueZAdapter(object));
      }
    }
    return adapters;
  }

  /// The devices on this system.
  /// Use [deviceAdded] and [deviceRemoved] to detect when this list changes.
  List<BlueZDevice> get devices {
    var devices = <BlueZDevice>[];
    for (var object in _objects.values) {
      if (_isDevice(object)) {
        devices.add(BlueZDevice(this, object));
      }
    }
    return devices;
  }

  /// Terminates all active connections. If a client remains unclosed, the Dart process may not terminate.
  Future<void> close() async {
    if (_objectManagerSubscription != null) {
      await _objectManagerSubscription?.cancel();
      _objectManagerSubscription = null;
    }
    if (_closeBus) {
      await _bus.close();
    }
  }

  BlueZAdapter? _getAdapter(DBusObjectPath objectPath) {
    var object = _objects[objectPath];
    if (object == null) {
      return null;
    }
    return BlueZAdapter(object);
  }

  bool _isAdapter(_BlueZObject object) {
    return object.interfaces.containsKey('org.bluez.Adapter1');
  }

  bool _isDevice(_BlueZObject object) {
    return object.interfaces.containsKey('org.bluez.Device1');
  }

  List<BlueZGattService> _getGattServices(DBusObjectPath parentPath) {
    var services = <BlueZGattService>[];
    for (var object in _objects.values) {
      if (object.path.isInNamespace(parentPath) && _isGattService(object)) {
        services.add(BlueZGattService(this, object));
      }
    }
    return services;
  }

  bool _isGattService(_BlueZObject object) {
    return object.interfaces.containsKey('org.bluez.GattService1');
  }

  List<BlueZGattCharacteristic> _getGattCharacteristics(
      DBusObjectPath parentPath) {
    var characteristics = <BlueZGattCharacteristic>[];
    for (var object in _objects.values) {
      if (object.path.isInNamespace(parentPath) &&
          _isGattCharacteristic(object)) {
        characteristics.add(BlueZGattCharacteristic(this, object));
      }
    }
    return characteristics;
  }

  bool _isGattCharacteristic(_BlueZObject object) {
    return object.interfaces.containsKey('org.bluez.GattCharacteristic1');
  }

  List<BlueZGattDescriptor> _getGattDescriptors(DBusObjectPath parentPath) {
    var descriptors = <BlueZGattDescriptor>[];
    for (var object in _objects.values) {
      if (object.path.isInNamespace(parentPath) && _isGattDescriptor(object)) {
        descriptors.add(BlueZGattDescriptor(object));
      }
    }
    return descriptors;
  }

  bool _isGattDescriptor(_BlueZObject object) {
    return object.interfaces.containsKey('org.bluez.GattDescriptor1');
  }
}
