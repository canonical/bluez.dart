import 'dart:async';

import 'package:bluez/bluez.dart';
import 'package:dbus/dbus.dart';

class BlueZObject extends DBusRemoteObject {
  final interfaces = <String, _BlueZInterface>{};

  void updateInterfaces(
      Map<String, Map<String, DBusValue>> interfacesAndProperties) {
    interfacesAndProperties.forEach((interfaceName, properties) {
      interfaces[interfaceName] = _BlueZInterface(properties);
    });
  }

  /// Returns true if removing [interfaceNames] would remove all interfaces on this object.
  bool wouldRemoveAllInterfaces(List<String> interfaceNames) {
    for (var interface in interfaces.keys) {
      if (!interfaceNames.contains(interface)) {
        return false;
      }
    }
    return true;
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
    return value.asBoolean();
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

    return value.asByteArray().toList();
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
    return value.asInt16();
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
    return value.asUint16();
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
    return value.asUint32();
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
    return value.asString();
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
    return value.asStringArray().toList();
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
    return value.asObjectPath();
  }

  @override
  Future<DBusMethodSuccessResponse> callMethod(
      String? interface, String name, Iterable<DBusValue> values,
      {DBusSignature? replySignature,
      bool noReplyExpected = false,
      bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    try {
      return await super.callMethod(interface, name, values,
          replySignature: replySignature,
          noReplyExpected: noReplyExpected,
          noAutoStart: noAutoStart,
          allowInteractiveAuthorization: allowInteractiveAuthorization);
    } on DBusMethodResponseException catch (e) {
      switch (e.response.errorName) {
        case 'org.bluez.Error.InvalidArguments':
          throw BlueZInvalidArgumentsException(e.response);
        case 'org.bluez.Error.InProgress':
          throw BlueZInProgressException(e.response);
        case 'org.bluez.Error.AlreadyExists':
          throw BlueZAlreadyExistsException(e.response);
        case 'org.bluez.Error.NotSupported':
          throw BlueZNotSupportedException(e.response);
        case 'org.bluez.Error.NotConnected':
          throw BlueZNotConnectedException(e.response);
        case 'org.bluez.Error.AlreadyConnected':
          throw BlueZAlreadyConnectedException(e.response);
        case 'org.bluez.Error.NotAvailable':
          throw BlueZNotAvailableException(e.response);
        case 'org.bluez.Error.DoesNotExist':
          throw BlueZDoesNotExistException(e.response);
        case 'org.bluez.Error.NotAuthorized':
          throw BlueZNotAuthorizedException(e.response);
        case 'org.bluez.Error.NotPermitted':
          throw BlueZNotPermittedException(e.response);
        case 'org.bluez.Error.NoSuchAdapter':
          throw BlueZNoSuchAdapterException(e.response);
        case 'org.bluez.Error.AgentNotAvailable':
          throw BlueZAgentNotAvailableException(e.response);
        case 'org.bluez.Error.NotReady':
          throw BlueZNotReadyException(e.response);
        case 'org.bluez.Error.Failed':
          throw BlueZFailedException(e.response);
        case 'org.bluez.Error.AuthenticationCanceled':
          throw BlueZAuthenticationCanceledException(e.response);
        case 'org.bluez.Error.AuthenticationFailed':
          throw BlueZAuthenticationFailedException(e.response);
        case 'org.bluez.Error.AuthenticationRejected':
          throw BlueZAuthenticationRejectedException(e.response);
        case 'org.bluez.Error.AuthenticationTimeout':
          throw BlueZAuthenticationTimeoutException(e.response);
        default:
          rethrow;
      }
    }
  }

  BlueZObject(DBusClient client, DBusObjectPath path,
      Map<String, Map<String, DBusValue>> interfacesAndProperties)
      : super(client, name: 'org.bluez', path: path) {
    updateInterfaces(interfacesAndProperties);
  }
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
