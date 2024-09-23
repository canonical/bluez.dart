import 'dart:async';
import 'dart:io';

import 'package:bluez/bluez.dart';
import 'package:dbus/dbus.dart';

part 'bluez_device.dart';
part 'bluez_object.dart';
part 'bluez_adapter.dart';
part 'bluez_advertisement.dart';
part 'bluez_agent.dart';
part 'bluez_battery.dart';
part 'bluez_characteristic.dart';
part 'bluez_exception.dart';
part 'bluez_gatt_descriptor.dart';
part 'bluez_gatt_service.dart';
part 'bluez_manufacturer_id.dart';
part 'bluez_agent_object.dart';

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

  /// Registered agent.
  _BlueZAgentObject? _agent;

  /// Creates a new BlueZ client. If [bus] is provided connect to the given D-Bus server.
  BlueZClient({DBusClient? bus})
      : _bus = bus ?? DBusClient.system(),
        _closeBus = bus == null {
    _root = DBusRemoteObjectManager(_bus,
        name: 'org.bluez', path: DBusObjectPath('/'));
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
            _adapterAddedStreamController.add(BlueZAdapter(this, object));
          } else if (_isDevice(object)) {
            _deviceAddedStreamController.add(BlueZDevice(this, object));
          }
        }
      } else if (signal is DBusObjectManagerInterfacesRemovedSignal) {
        var object = _objects[signal.changedPath];
        if (object != null) {
          // If all the interface are removed, then this object has been removed.
          // Keep the previous values around for the client to use.
          if (object.wouldRemoveAllInterfaces(signal.interfaces)) {
            _objects.remove(signal.changedPath);
          } else {
            object.removeInterfaces(signal.interfaces);
          }

          if (signal.interfaces.contains('org.bluez.Adapter1')) {
            _adapterRemovedStreamController.add(BlueZAdapter(this, object));
          } else if (signal.interfaces.contains('org.bluez.Device1')) {
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
          _BlueZObject(_bus, objectPath, interfacesAndProperties);
    });

    // Report initial adapters and devices.
    for (var object in _objects.values) {
      if (_isAdapter(object)) {
        _adapterAddedStreamController.add(BlueZAdapter(this, object));
      } else if (_isDevice(object)) {
        _deviceAddedStreamController.add(BlueZDevice(this, object));
      }
    }
  }

  /// The adapters present on this system.
  /// Use [adapterAdded] and [adapterRemoved] to detect when this list changes.
  List<BlueZAdapter> get adapters {
    var adapters = <BlueZAdapter>[];
    for (var object in _objects.values) {
      if (_isAdapter(object)) {
        adapters.add(BlueZAdapter(this, object));
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

  /// Registers an agent handler.
  /// A D-Bus object will be registered on [path], which the user must choose to not collide with any other path on the D-Bus client that was passed in the [BlueZClient] constructor.
  Future<void> registerAgent(BlueZAgent agent,
      {DBusObjectPath? path,
      var capability = BlueZAgentCapability.keyboardDisplay}) async {
    if (_agent != null) {
      throw 'Agent already registered';
    }

    var object = _objects[DBusObjectPath('/org/bluez')];
    if (object == null) {
      throw 'Missing /org/bluez object required for agent registration';
    }

    _agent = _BlueZAgentObject(
        this, agent, path ?? DBusObjectPath('/org/bluez/Agent'));
    await _bus.registerObject(_agent!);

    var capabilityString = {
          BlueZAgentCapability.displayOnly: 'DisplayOnly',
          BlueZAgentCapability.displayYesNo: 'DisplayYesNo',
          BlueZAgentCapability.keyboardOnly: 'KeyboardOnly',
          BlueZAgentCapability.noInputNoOutput: 'NoInputNoOutput',
          BlueZAgentCapability.keyboardDisplay: 'KeyboardDisplay',
        }[capability] ??
        '';

    await object.callMethod('org.bluez.AgentManager1', 'RegisterAgent',
        [_agent!.path, DBusString(capabilityString)],
        replySignature: DBusSignature(''));
  }

  /// Unregisters the agent handler previouly registered with [registerAgent].
  Future<void> unregisterAgent() async {
    if (_agent == null) {
      throw 'No agent registered';
    }

    var object = _objects[DBusObjectPath('/org/bluez')];
    if (object == null) {
      throw 'Missing /org/bluez object required for agent unregistration';
    }

    await object.callMethod(
        'org.bluez.AgentManager1', 'UnregisterAgent', [_agent!.path],
        replySignature: DBusSignature(''));
    _agent = null;
  }

  /// Requests that the agent set with [registerAgent] is the system default agent.
  Future<void> requestDefaultAgent() async {
    var object = _objects[DBusObjectPath('/org/bluez')];
    if (object == null) {
      throw 'Missing /org/bluez object required for agent unregistration';
    }

    await object.callMethod(
        'org.bluez.AgentManager1', 'RequestDefaultAgent', [_agent!.path],
        replySignature: DBusSignature(''));
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
    return BlueZAdapter(this, object);
  }

  bool _isAdapter(_BlueZObject object) {
    return object.interfaces.containsKey('org.bluez.Adapter1');
  }

  BlueZDevice? _getDevice(DBusObjectPath objectPath) {
    var object = _objects[objectPath];
    if (object == null) {
      return null;
    }
    return BlueZDevice(this, object);
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
