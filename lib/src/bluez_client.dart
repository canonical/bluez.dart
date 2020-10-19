import 'dart:async';

import 'package:dbus/dbus.dart';

class BlueZAdapter {
  final String _adapterInterfaceName = 'org.bluez.Adapter1';

  final _BlueZObject _object;

  BlueZAdapter(this._object);

  // FIXME: GetDiscoveryFilters

  // FIXME: RemoveDevice

  // FIXME: SetDiscoveryFilter

  void startDiscovery() async {
    await _object.callMethod(_adapterInterfaceName, 'StartDiscovery', []);
  }

  void stopDiscovery() async {
    await _object.callMethod(_adapterInterfaceName, 'stopDiscovery', []);
  }

  // FIXME: Class

  String get address =>
      _object.getStringProperty(_adapterInterfaceName, 'Address');

  String get addressType =>
      _object.getStringProperty(_adapterInterfaceName, 'AddressType');

  String get alias => _object.getStringProperty(_adapterInterfaceName, 'Alias');

  bool get discoverable =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Discoverable');

  int get discoverableTimeout =>
      _object.getUint32Property(_adapterInterfaceName, 'DiscoverableTimeout');

  bool get discovering =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Discovering');

  String get modalias =>
      _object.getStringProperty(_adapterInterfaceName, 'Modalias');

  String get name => _object.getStringProperty(_adapterInterfaceName, 'Name');

  int get pairableTimeout =>
      _object.getUint32Property(_adapterInterfaceName, 'PairableTimeout');

  bool get pairing =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Pairing');

  bool get powered =>
      _object.getBooleanProperty(_adapterInterfaceName, 'Powered');

  List<String> get roles =>
      _object.getStringArrayProperty(_adapterInterfaceName, 'Roles');

  List<String> get uuids =>
      _object.getStringArrayProperty(_adapterInterfaceName, 'UUIDS');
}

class BlueZDevice {
  final String _deviceInterfaceName = 'org.bluez.Device1';

  final _BlueZObject _object;

  BlueZDevice(this._object);

  void connect() async {
    await _object.callMethod(_deviceInterfaceName, 'Connect', []);
  }

  void connectProfile(String uuid) async {
    await _object
        .callMethod(_deviceInterfaceName, 'ConnectProfile', [DBusString(uuid)]);
  }

  void disconnect() async {
    await _object.callMethod(_deviceInterfaceName, 'Disconnect', []);
  }

  void disconnectProfile(String uuid) async {
    await _object.callMethod(
        _deviceInterfaceName, 'DisconnectProfile', [DBusString(uuid)]);
  }

  void pair() async {
    await _object.callMethod(_deviceInterfaceName, 'Pair', []);
  }

  void cancelPairing() async {
    await _object.callMethod(_deviceInterfaceName, 'CancelPairing', []);
  }

  // FIXME: Adapter

  // FIXME: Appearance

  String get addressType =>
      _object.getStringProperty(_deviceInterfaceName, 'AddressType');

  String get alias => _object.getStringProperty(_deviceInterfaceName, 'Alias');

  bool get blocked =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Blocked');

  // FIXME: Class

  bool get connected =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Connected');

  bool get legacyPairing =>
      _object.getBooleanProperty(_deviceInterfaceName, 'LegacyPairing');

  String get icon => _object.getStringProperty(_deviceInterfaceName, 'Icon');

  // FIXME: ManufacturerData

  String get modalias =>
      _object.getStringProperty(_deviceInterfaceName, 'Modalias');

  String get name => _object.getStringProperty(_deviceInterfaceName, 'Name');

  bool get paired => _object.getBooleanProperty(_deviceInterfaceName, 'Paired');

  int get rssi => _object.getInt16Property(_deviceInterfaceName, 'RSSI');

  // FIXME: ServiceData

  bool get servicesResolved =>
      _object.getBooleanProperty(_deviceInterfaceName, 'ServicesResolved');

  bool get trusted =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Trusted');

  int get txPower => _object.getInt16Property(_deviceInterfaceName, 'TxPower');

  List<String> get uuids =>
      _object.getStringArrayProperty(_deviceInterfaceName, 'UUIDS');

  bool get wakeAllowed =>
      _object.getBooleanProperty(_deviceInterfaceName, 'WakeAllowed');
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
  /// The bus this client is connected to.
  final DBusClient systemBus;

  /// The root D-Bus BlueZ object.
  DBusRemoteObject _root;

  // Objects exported on the bus.
  final _objects = <DBusObjectPath, _BlueZObject>{};

  // Subscription to object manager signals.
  StreamSubscription _objectManagerSubscription;

  /// Creates a new BlueZ client connected to the system D-Bus.
  BlueZClient(this.systemBus);

  /// Connects to the BlueZ daemon.
  /// Must be called before accessing methods and properties.
  void connect() async {
    // Already connected
    if (_root != null) {
      return;
    }

    _root = DBusRemoteObject(systemBus, 'org.bluez', DBusObjectPath('/'));

    // Subscribe to changes
    var signals = _root.subscribeObjectManagerSignals();
    _objectManagerSubscription = signals.listen((signal) {
      if (signal is DBusObjectManagerInterfacesAddedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          object.updateInterfaces(signal.interfacesAndProperties);
        } else {
          _objects[signal.changedPath] = _BlueZObject(
              systemBus, signal.changedPath, signal.interfacesAndProperties);
        }
      } else if (signal is DBusObjectManagerInterfacesRemovedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          object.removeInterfaces(signal.interfaces);
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
          _BlueZObject(systemBus, objectPath, interfacesAndProperties);
    });
  }

  List<BlueZAdapter> get adapters {
    var adapters = <BlueZAdapter>[];
    for (var object in _objects.values) {
      if (object.interfaces.containsKey('org.bluez.Adapter1')) {
        adapters.add(BlueZAdapter(object));
      }
    }
    return adapters;
  }

  List<BlueZDevice> get devices {
    var devices = <BlueZDevice>[];
    for (var object in _objects.values) {
      if (object.interfaces.containsKey('org.bluez.Device1')) {
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
}
