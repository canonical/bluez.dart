import 'dart:async';

import 'package:dbus/dbus.dart';

/// A Bluetooth adapter.
class BlueZAdapter {
  final String _adapterInterfaceName = 'org.bluez.Adapter1';

  final _BlueZObject _object;

  BlueZAdapter(this._object);

  Stream<List<String>> get propertiesChangedStream {
    return _object.interfaces[_adapterInterfaceName]
        .propertiesChangedStreamController.stream;
  }

  // FIXME: GetDiscoveryFilters

  // FIXME: RemoveDevice

  // FIXME: SetDiscoveryFilter

  /// Start discovery of devices on this adapter.
  void startDiscovery() async {
    await _object.callMethod(_adapterInterfaceName, 'StartDiscovery', []);
  }

  /// Stop discovery of devices on this adapter.
  void stopDiscovery() async {
    await _object.callMethod(_adapterInterfaceName, 'stopDiscovery', []);
  }

  // FIXME: Class

  /// MAC address of this adapter.
  String get address =>
      _object.getStringProperty(_adapterInterfaceName, 'Address');

  String get addressType =>
      _object.getStringProperty(_adapterInterfaceName, 'AddressType');

  /// The alternative name for this adapter.
  String get alias => _object.getStringProperty(_adapterInterfaceName, 'Alias');

  /// Sets the alternative name for this adapter.
  set alias(String value) =>
      _object.setProperty(_adapterInterfaceName, 'Alias', DBusString(value));

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

  int get pairableTimeout =>
      _object.getUint32Property(_adapterInterfaceName, 'PairableTimeout');

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

  List<String> get uuids =>
      _object.getStringArrayProperty(_adapterInterfaceName, 'UUIDS');
}

/// A Bluetooth device.
class BlueZDevice {
  final String _deviceInterfaceName = 'org.bluez.Device1';

  final _BlueZObject _object;

  BlueZDevice(this._object);

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

  void connectProfile(String uuid) async {
    await _object
        .callMethod(_deviceInterfaceName, 'ConnectProfile', [DBusString(uuid)]);
  }

  void disconnectProfile(String uuid) async {
    await _object.callMethod(
        _deviceInterfaceName, 'DisconnectProfile', [DBusString(uuid)]);
  }

  /// Pair with this device.
  void pair() async {
    await _object.callMethod(_deviceInterfaceName, 'Pair', []);
  }

  /// Cancel a pairing that is in progress.
  void cancelPairing() async {
    await _object.callMethod(_deviceInterfaceName, 'CancelPairing', []);
  }

  // FIXME: Adapter

  /// MAC address of this device.
  String get address =>
      _object.getStringProperty(_deviceInterfaceName, 'Address');

  String get addressType =>
      _object.getStringProperty(_deviceInterfaceName, 'AddressType');

  /// An alternative name for this device.
  String get alias => _object.getStringProperty(_deviceInterfaceName, 'Alias');

  /// Sets the alternative name for this device.
  set alias(String value) =>
      _object.setProperty(_deviceInterfaceName, 'Alias', DBusString(value));

  // FIXME: Appearance

  bool get blocked =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Blocked');

  set blocked(bool value) =>
      _object.setProperty(_deviceInterfaceName, 'Blocked', DBusBoolean(value));

  // FIXME: Class

  /// True if this device is currently connected.
  bool get connected =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Connected');

  bool get legacyPairing =>
      _object.getBooleanProperty(_deviceInterfaceName, 'LegacyPairing');

  /// Icon name for this device.
  String get icon => _object.getStringProperty(_deviceInterfaceName, 'Icon');

  // FIXME: ManufacturerData

  String get modalias =>
      _object.getStringProperty(_deviceInterfaceName, 'Modalias');

  /// Name of this device.
  String get name => _object.getStringProperty(_deviceInterfaceName, 'Name');

  /// True if the device is currently paired.
  bool get paired => _object.getBooleanProperty(_deviceInterfaceName, 'Paired');

  /// Signal strength received from the devide.
  int get rssi => _object.getInt16Property(_deviceInterfaceName, 'RSSI');

  // FIXME: ServiceData

  bool get servicesResolved =>
      _object.getBooleanProperty(_deviceInterfaceName, 'ServicesResolved');

  bool get trusted =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Trusted');

  set trusted(bool value) =>
      _object.setProperty(_deviceInterfaceName, 'Trusted', DBusBoolean(value));

  int get txPower => _object.getInt16Property(_deviceInterfaceName, 'TxPower');

  List<String> get uuids =>
      _object.getStringArrayProperty(_deviceInterfaceName, 'UUIDS');

  bool get wakeAllowed =>
      _object.getBooleanProperty(_deviceInterfaceName, 'WakeAllowed');

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
    print('subscribe');
    var signals = _root.subscribeObjectManagerSignals();
    _objectManagerSubscription = signals.listen((signal) {
      print(signal);
      if (signal is DBusObjectManagerInterfacesAddedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          object.updateInterfaces(signal.interfacesAndProperties);
        } else {
          object = _BlueZObject(
              _systemBus, signal.changedPath, signal.interfacesAndProperties);
          _objects[signal.changedPath] = object;
          print('new');
          if (_isAdapter(object)) {
            print(' adapter');
            _adapterAddedStreamController.add(BlueZAdapter(object));
          } else if (_isDevice(object)) {
            print(' device');
            _deviceAddedStreamController.add(BlueZDevice(object));
          }
        }
      } else if (signal is DBusObjectManagerInterfacesRemovedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          object.removeInterfaces(signal.interfaces);
          if (_isAdapter(object)) {
            _adapterRemovedStreamController.add(BlueZAdapter(object));
          } else if (_isDevice(object)) {
            _deviceRemovedStreamController.add(BlueZDevice(object));
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
        devices.add(BlueZDevice(object));
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

  bool _isAdapter(_BlueZObject object) {
    return object.interfaces.containsKey('org.bluez.Adapter1');
  }

  bool _isDevice(_BlueZObject object) {
    return object.interfaces.containsKey('org.bluez.Device1');
  }
}
