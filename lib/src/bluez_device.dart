import 'package:bluez/src/bluez_adapter.dart';
import 'package:bluez/src/bluez_client.dart';
import 'package:bluez/src/bluez_enums.dart';
import 'package:bluez/src/bluez_gatt_service.dart';
import 'package:bluez/src/bluez_manufacturer_id.dart';
import 'package:bluez/src/bluez_object.dart';
import 'package:bluez/src/bluez_uuid.dart';
import 'package:dbus/dbus.dart';

/// A Bluetooth device.
class BlueZDevice {
  final String _deviceInterfaceName = 'org.bluez.Device1';

  final BlueZClient _client;
  final BlueZObject _object;
  late DBusObjectPath path = _object.path;

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
    await _object.callMethod(_deviceInterfaceName, 'Connect', [],
        replySignature: DBusSignature(''));
  }

  /// Disconnect from this device
  Future<void> disconnect() async {
    await _object.callMethod(_deviceInterfaceName, 'Disconnect', [],
        replySignature: DBusSignature(''));
  }

  /// Connects to the service with [uuid].
  Future<void> connectProfile(BlueZUUID uuid) async {
    await _object.callMethod(
        _deviceInterfaceName, 'ConnectProfile', [DBusString(uuid.toString())],
        replySignature: DBusSignature(''));
  }

  /// Disconnects the service with [uuid].
  Future<void> disconnectProfile(BlueZUUID uuid) async {
    await _object.callMethod(_deviceInterfaceName, 'DisconnectProfile',
        [DBusString(uuid.toString())],
        replySignature: DBusSignature(''));
  }

  /// Pair with this device.
  Future<void> pair() async {
    await _object.callMethod(_deviceInterfaceName, 'Pair', [],
        replySignature: DBusSignature(''));
  }

  /// Cancel a pairing that is in progress.
  Future<void> cancelPairing() async {
    await _object.callMethod(_deviceInterfaceName, 'CancelPairing', [],
        replySignature: DBusSignature(''));
  }

  /// The adapter this device belongs to.
  BlueZAdapter get adapter {
    var objectPath =
        _object.getObjectPathProperty(_deviceInterfaceName, 'Adapter')!;
    return _client.getAdapter(objectPath)!;
  }

  /// MAC address of this device.
  String get address =>
      _object.getStringProperty(_deviceInterfaceName, 'Address') ?? '';

  /// The Bluetooth device address type.
  BlueZAddressType get addressType =>
      _object.getAddressType(_deviceInterfaceName, 'AddressType') ??
      BlueZAddressType.public;

  /// An alternative name for this device.
  String get alias =>
      _object.getStringProperty(_deviceInterfaceName, 'Alias') ?? '';

  /// Sets the alternative name for this device.
  Future<void> setAlias(String value) async {
    await _object.setProperty(_deviceInterfaceName, 'Alias', DBusString(value));
  }

  /// External appearance of device, as found on GAP service.
  /// Appearance values are defined in the [Bluetooth specification](https://www.bluetooth.com/specifications/assigned-numbers/).
  int get appearance =>
      _object.getUint16Property(_deviceInterfaceName, 'Appearance') ?? 0;

  /// True if connections from this device will be ignored.
  bool get blocked =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Blocked') ?? false;

  /// Sets if connections from this device will be ignored.
  Future<void> setBlocked(bool value) async {
    await _object.setProperty(
        _deviceInterfaceName, 'Blocked', DBusBoolean(value));
  }

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
        _object.getCachedProperty(_deviceInterfaceName, 'ManufacturerData') ??
            DBusDict(DBusSignature('q'), DBusSignature('v'), {});
    if (value.signature != DBusSignature('a{qv}')) {
      return {};
    }
    List<int> processValue(DBusValue value) {
      if (value.signature != DBusSignature('ay')) {
        return [];
      }
      return value.asByteArray().toList();
    }

    return value.asDict().map((key, value) => MapEntry(
        BlueZManufacturerId(key.asUint16()), processValue(value.asVariant())));
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
    var value =
        _object.getCachedProperty(_deviceInterfaceName, 'ServiceData') ??
            DBusDict.stringVariant({});
    if (value.signature != DBusSignature('a{sv}')) {
      return {};
    }
    List<int> processValue(DBusValue value) {
      if (value.signature != DBusSignature('ay')) {
        return [];
      }
      return value.asByteArray().toList();
    }

    return value.asDict().map((key, value) => MapEntry(
        BlueZUUID.fromString(key.asString()), processValue(value.asVariant())));
  }

  /// True if service discovery has been resolved.
  bool get servicesResolved =>
      _object.getBooleanProperty(_deviceInterfaceName, 'ServicesResolved') ??
      false;

  /// True if the remote is seen as trusted.
  bool get trusted =>
      _object.getBooleanProperty(_deviceInterfaceName, 'Trusted') ?? false;

  /// Sets if the remote is seen as trusted.
  Future<void> setTrusted(bool value) async {
    await _object.setProperty(
        _deviceInterfaceName, 'Trusted', DBusBoolean(value));
  }

  /// Advertised transmit power level.
  int get txPower =>
      _object.getInt16Property(_deviceInterfaceName, 'TxPower') ?? 0;

  /// UUIDs that indicate the available remote services.
  List<BlueZUUID> get uuids =>
      (_object.getStringArrayProperty(_deviceInterfaceName, 'UUIDs') ?? [])
          .map((value) => BlueZUUID.fromString(value))
          .toList();

  /// True if the device can wake the host from system suspend.
  bool get wakeAllowed =>
      _object.getBooleanProperty(_deviceInterfaceName, 'WakeAllowed') ?? false;

  /// Sets if the device can wake the host from system suspend.
  Future<void> setWakeAllowed(bool value) async {
    await _object.setProperty(
        _deviceInterfaceName, 'WakeAllowed', DBusBoolean(value));
  }

  /// The Gatt services provided by this device.
  List<BlueZGattService> get gattServices =>
      _client.getGattServices(_object.path);
}
