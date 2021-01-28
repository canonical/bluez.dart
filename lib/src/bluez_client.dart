import 'dart:async';

import 'package:dbus/dbus.dart';

/// Types of Bluetooth address.
enum BlueZAddressType { public, random }

/// UUID used to describe services.
class BlueZUUID {
  final String id;

  const BlueZUUID(this.id);

  @override
  String toString() => "BlueZUUID('${id}')";
}

/// Bluetooth manufacturer Id.
class BlueZManufacturerId {
  final int id;

  const BlueZManufacturerId(this.id);

  @override
  String toString() => "BlueZManufacturerId('${id}')";
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
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[_adapterInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  // FIXME: GetDiscoveryFilters

  // FIXME: SetDiscoveryFilter

  /// Start discovery of devices on this adapter.
  void startDiscovery() async {
    await _object.callMethod(_adapterInterfaceName, 'StartDiscovery', []);
  }

  /// Stop discovery of devices on this adapter.
  void stopDiscovery() async {
    await _object.callMethod(_adapterInterfaceName, 'stopDiscovery', []);
  }

  /// Removes settings for [device] from this adapter.
  void removeDevice(BlueZDevice device) async {
    await _object.callMethod(
        _adapterInterfaceName, 'RemoveDevice', [device._object.path]);
  }

  /// Bluetooth device address of this adapter.
  String get address =>
      _object.getStringProperty(_adapterInterfaceName, 'Address');

  /// The Bluetooth address type.
  BlueZAddressType get addressType => _bluezAddressTypeMap[
      _object.getStringProperty(_adapterInterfaceName, 'AddressType')];

  /// The alternative name for this adapter.
  String get alias => _object.getStringProperty(_adapterInterfaceName, 'Alias');

  /// Sets the alternative name for this adapter.
  set alias(String value) =>
      _object.setProperty(_adapterInterfaceName, 'Alias', DBusString(value));

  /// Bluetooth device class.
  int get deviceClass =>
      _object.getUint32Property(_adapterInterfaceName, 'Class');

  /// True if this adapter is discoverable by other Bluetooth devices.
  bool get discoverable =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Discoverable');

  /// Sets if this adapter can be discovered by other Bluetooth devices.
  set discoverable(bool value) => _object.setProperty(
      _adapterInterfaceName, 'Discoverable', DBusBoolean(value));

  int get discoverableTimeout =>
      _object.getUint32Property(_adapterInterfaceName, 'DiscoverableTimeout');

  set discoverableTimeout(int value) => _object.setProperty(
      _adapterInterfaceName, 'DiscoverableTimeout', DBusUint32(value));

  /// True if currently discovering devices.
  bool get discovering =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Discovering');

  /// Local Device ID information in modalias format used by the kernel and udev.
  String get modalias =>
      _object.getStringProperty(_adapterInterfaceName, 'Modalias');

  /// Name of this adapter.
  String get name => _object.getStringProperty(_adapterInterfaceName, 'Name');

  /// True if other Bluetooth devices can pair with this adapter.
  bool get pairable =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Pairable');

  /// Sets if other Bluetooth devices can pair with this adapter.
  set pairable(bool value) => _object.setProperty(
      _adapterInterfaceName, 'Pairable', DBusBoolean(value));

  /// Timeout in seconds when pairing.
  int get pairableTimeout =>
      _object.getUint32Property(_adapterInterfaceName, 'PairableTimeout');

  /// Sets the timeout in seconds when pairing.
  set pairableTimeout(int value) => _object.setProperty(
      _adapterInterfaceName, 'PairableTimeout', DBusUint32(value));

  /// True if this adapter is powered on.
  bool get powered =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Powered');

  /// Sets if this adapter is powered on.
  set powered(bool value) =>
      _object.setProperty(_adapterInterfaceName, 'Powered', DBusBoolean(value));

  List<String> get roles =>
      _object.getStringArrayProperty(_adapterInterfaceName, 'Roles');

  /// List of 128-bit UUIDs that represents the available local services.
  List<BlueZUUID> get uuids => _object
      .getStringArrayProperty(_adapterInterfaceName, 'UUIDS')
      .map((value) => BlueZUUID(value));
}

/// A Bluetooth device.
class BlueZDevice {
  final String _deviceInterfaceName = 'org.bluez.Device1';

  final BlueZClient _client;
  final _BlueZObject _object;

  BlueZDevice(this._client, this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[_deviceInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  /// Connect to this device.
  void connect() async {
    await _object.callMethod(_deviceInterfaceName, 'Connect', []);
  }

  /// Disconnect from this device
  void disconnect() async {
    await _object.callMethod(_deviceInterfaceName, 'Disconnect', []);
  }

  /// Connects to the service with [uuid].
  void connectProfile(BlueZUUID uuid) async {
    await _object.callMethod(
        _deviceInterfaceName, 'ConnectProfile', [DBusString(uuid.id)]);
  }

  /// Disconnects the service with [uuid].
  void disconnectProfile(BlueZUUID uuid) async {
    await _object.callMethod(
        _deviceInterfaceName, 'DisconnectProfile', [DBusString(uuid.id)]);
  }

  /// Pair with this device.
  void pair() async {
    await _object.callMethod(_deviceInterfaceName, 'Pair', []);
  }

  /// Cancel a pairing that is in progress.
  void cancelPairing() async {
    await _object.callMethod(_deviceInterfaceName, 'CancelPairing', []);
  }

  /// The adapter this device belongs to.
  BlueZAdapter get adapter {
    var objectPath =
        _object.getObjectPathProperty(_deviceInterfaceName, 'Adapter');
    return _client._getAdapter(objectPath);
  }

  /// MAC address of this device.
  String get address =>
      _object.getStringProperty(_deviceInterfaceName, 'Address');

  /// The Bluetooth device address type.
  BlueZAddressType get addressType => _bluezAddressTypeMap[
      _object.getStringProperty(_deviceInterfaceName, 'AddressType')];

  /// An alternative name for this device.
  String get alias => _object.getStringProperty(_deviceInterfaceName, 'Alias');

  /// Sets the alternative name for this device.
  set alias(String value) =>
      _object.setProperty(_deviceInterfaceName, 'Alias', DBusString(value));

  /// External appearance of device, as found on GAP service.
  int get appearance =>
      _object.getUint16Property(_deviceInterfaceName, 'Appearance');

  /// True if connections from this device will be ignored.
  bool get blocked =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Blocked');

  /// Sets if connections from this device will be ignored.
  set blocked(bool value) =>
      _object.setProperty(_deviceInterfaceName, 'Blocked', DBusBoolean(value));

  /// True if this device is currently connected.
  bool get connected =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Connected');

  /// Bluetooth device class.
  int get deviceClass =>
      _object.getUint32Property(_deviceInterfaceName, 'Class');

  /// True if this device only supports the pre-2.1 pairing mechanism.
  bool get legacyPairing =>
      _object.getBooleanProperty(_deviceInterfaceName, 'LegacyPairing');

  /// Icon name for this device.
  String get icon => _object.getStringProperty(_deviceInterfaceName, 'Icon');

  /// Manufacturer specific advertisement data.
  Map<BlueZManufacturerId, List<int>> get manufacturerData {
    var value =
        _object.getCachedProperty(_deviceInterfaceName, 'ManufacturerData');
    if (value == null) {
      return {};
    }
    if (value.signature != DBusSignature('a{sv}')) {
      return {};
    }
    List<int> processValue(DBusVariant value) {
      if (value.value.signature != DBusSignature('ay')) {
        return [];
      }
      return (value.value as DBusArray)
          .children
          .map((value) => (value as DBusByte).value)
          .toList();
    }

    return (value as DBusDict).children.map((key, value) => MapEntry(
        BlueZManufacturerId((key as DBusUint16).value),
        processValue(value as DBusVariant)));
  }

  /// Remote Device ID information in modalias format used by the kernel and udev.
  String get modalias =>
      _object.getStringProperty(_deviceInterfaceName, 'Modalias');

  /// Name of this device.
  String get name => _object.getStringProperty(_deviceInterfaceName, 'Name');

  /// True if the device is currently paired.
  bool get paired => _object.getBooleanProperty(_deviceInterfaceName, 'Paired');

  /// Signal strength received from the devide.
  int get rssi => _object.getInt16Property(_deviceInterfaceName, 'RSSI');

  /// Service advertisement data.
  Map<String, List<int>> get serviceData {
    var value = _object.getCachedProperty(_deviceInterfaceName, 'ServiceData');
    if (value == null) {
      return {};
    }
    if (value.signature != DBusSignature('a{sv}')) {
      return {};
    }
    List<int> processValue(DBusVariant value) {
      if (value.value.signature != DBusSignature('ay')) {
        return [];
      }
      return (value.value as DBusArray)
          .children
          .map((value) => (value as DBusByte).value)
          .toList();
    }

    return (value as DBusDict).children.map((key, value) => MapEntry(
        (key as DBusString).value, processValue(value as DBusVariant)));
  }

  /// True if service discovery has been resolved.
  bool get servicesResolved =>
      _object.getBooleanProperty(_deviceInterfaceName, 'ServicesResolved');

  /// True if the remote is seen as trusted.
  bool get trusted =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Trusted');

  /// Sets if the remote is seen as trusted.
  set trusted(bool value) =>
      _object.setProperty(_deviceInterfaceName, 'Trusted', DBusBoolean(value));

  /// Advertised transmit power level.
  int get txPower => _object.getInt16Property(_deviceInterfaceName, 'TxPower');

  /// UUIDs that indicate the available remote services.
  List<BlueZUUID> get uuids => _object
      .getStringArrayProperty(_deviceInterfaceName, 'UUIDS')
      .map((value) => BlueZUUID(value));

  /// True if the device can wake the host from system suspend.
  bool get wakeAllowed =>
      _object.getBooleanProperty(_deviceInterfaceName, 'WakeAllowed');

  /// Sets if the device can wake the host from system suspend.
  set wakeAllowed(bool value) => _object.setProperty(
      _deviceInterfaceName, 'WakeAllowed', DBusBoolean(value));
}

class _BlueZInterface {
  final Map<String, DBusValue> properties;
  final propertiesChangedStreamController =
      StreamController<List<String>>.broadcast();

  Stream<List<String>> get propertiesChangedStream =>
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

  void removeInterfaces(List<String> interfaceNames) {
    for (var interfaceName in interfaceNames) {
      interfaces.remove(interfaceName);
    }
  }

  void updateProperties(
      String interfaceName, Map<String, DBusValue> changedProperties) {
    var interface = interfaces[interfaceName];
    if (interface != null) {
      interface.updateProperties(changedProperties);
    }
  }

  /// Gets a cached property.
  DBusValue getCachedProperty(String interfaceName, String name) {
    var interface = interfaces[interfaceName];
    if (interface == null) {
      return null;
    }
    return interface.properties[name];
  }

  /// Gets a cached boolean property, or returns null if not present or not the correct type.
  bool getBooleanProperty(String interface, String name) {
    var value = getCachedProperty(interface, name);
    if (value == null) {
      return null;
    }
    if (value.signature != DBusSignature('b')) {
      return null;
    }
    return (value as DBusBoolean).value;
  }

  /// Gets a cached signed 16 bit integer property, or returns null if not present or not the correct type.
  int getInt16Property(String interface, String name) {
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
  int getUint16Property(String interface, String name) {
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
  int getUint32Property(String interface, String name) {
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
  String getStringProperty(String interface, String name) {
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
  List<String> getStringArrayProperty(String interface, String name) {
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
  DBusObjectPath getObjectPathProperty(String interface, String name) {
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
  Stream<BlueZAdapter> get adapterAddedStream =>
      _adapterAddedStreamController.stream;

  /// Stream of adapters as they are removed.
  Stream<BlueZAdapter> get adapterRemovedStream =>
      _adapterRemovedStreamController.stream;

  /// Stream of devices as they are added.
  Stream<BlueZDevice> get deviceAddedStream =>
      _deviceAddedStreamController.stream;

  /// Stream of devices as they are removed.
  Stream<BlueZDevice> get deviceRemovedStream =>
      _deviceRemovedStreamController.stream;

  /// The bus this client is connected to.
  final DBusClient _systemBus;

  /// The root D-Bus BlueZ object.
  DBusRemoteObject _root;

  // Objects exported on the bus.
  final _objects = <DBusObjectPath, _BlueZObject>{};

  // Subscription to object manager signals.
  StreamSubscription _objectManagerSubscription;

  final _adapterAddedStreamController =
      StreamController<BlueZAdapter>.broadcast();
  final _adapterRemovedStreamController =
      StreamController<BlueZAdapter>.broadcast();
  final _deviceAddedStreamController =
      StreamController<BlueZDevice>.broadcast();
  final _deviceRemovedStreamController =
      StreamController<BlueZDevice>.broadcast();

  /// Creates a new BlueZ client connected to the system D-Bus.
  BlueZClient(this._systemBus);

  /// Connects to the BlueZ daemon.
  /// Must be called before accessing methods and properties.
  void connect() async {
    // Already connected
    if (_root != null) {
      return;
    }

    _root = DBusRemoteObject(_systemBus, 'org.bluez', DBusObjectPath('/'));

    // Subscribe to changes
    var signals = _root.subscribeObjectManagerSignals();
    _objectManagerSubscription = signals.listen((signal) {
      if (signal is DBusObjectManagerInterfacesAddedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          object.updateInterfaces(signal.interfacesAndProperties);
        } else {
          object = _BlueZObject(
              _systemBus, signal.changedPath, signal.interfacesAndProperties);
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
          object.removeInterfaces(signal.interfaces);
          if (_isAdapter(object)) {
            _adapterRemovedStreamController.add(BlueZAdapter(object));
          } else if (_isDevice(object)) {
            _deviceRemovedStreamController.add(BlueZDevice(this, object));
          }
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
          _BlueZObject(_systemBus, objectPath, interfacesAndProperties);
    });
  }

  /// The adapters present on this system.
  /// Use [adapterAddedStream] and [adapterRemovedStream] to detect when this list changes.
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
  /// Use [deviceAddedStream] and [deviceRemovedStream] to detect when this list changes.
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
  void close() {
    if (_objectManagerSubscription != null) {
      _objectManagerSubscription.cancel();
      _objectManagerSubscription = null;
    }
  }

  BlueZAdapter _getAdapter(DBusObjectPath objectPath) {
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
}
