import 'dart:async';

import 'package:dbus/dbus.dart';

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

  /// Terminates all active connections. If a client remains unclosed, the Dart process may not terminate.
  void close() {
    if (_objectManagerSubscription != null) {
      _objectManagerSubscription.cancel();
      _objectManagerSubscription = null;
    }
  }
}
