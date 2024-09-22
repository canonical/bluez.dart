import 'package:bluez/bluez.dart';
import 'package:dbus/dbus.dart';

/// BlueZ server object to register battery providers.
class BlueZBatteryProviderManager {
  final String _batteryProviderManagerInterfaceName =
      'org.bluez.BatteryProviderManager1';

  final BlueZClient _client;
  final BlueZObject _object;
  int _nextBatteryProviderId;

  BlueZBatteryProviderManager(this._client, this._object)
      : _nextBatteryProviderId = 0;

  /// Registers a new battery provider.
  Future<BlueZBatteryProvider> registerBatteryProvider() async {
    var provider = BlueZBatteryProvider(_client,
        DBusObjectPath('/org/bluez/battery/provider$_nextBatteryProviderId'));
    _nextBatteryProviderId += 1;

    await _client.bus.registerObject(provider);

    await _object.callMethod(_batteryProviderManagerInterfaceName,
        'RegisterBatteryProvider', [provider.path],
        replySignature: DBusSignature(''));

    return provider;
  }

  /// Unregisters a battery provider previously registered with
  /// [registerBatteryProvider].
  Future<void> unregisterBatteryProvider(BlueZBatteryProvider provider) async {
    await _object.callMethod(_batteryProviderManagerInterfaceName,
        'UnregisterBatteryProvider', [provider.path],
        replySignature: DBusSignature(''));

    await _client.bus.unregisterObject(provider);
  }
}

/// Object to register batteries.
class BlueZBatteryProvider extends DBusObject {
  final BlueZClient _client;
  int _nextBatteryId = 0;

  BlueZBatteryProvider(this._client, DBusObjectPath path)
      : super(path, isObjectManager: true);

  /// Registers a new battery attached to a [device].
  /// [percentage] is the amount of charge in this battery.
  /// If provided, [source] describes where the battery information comes from.
  Future<BlueZBattery> addBattery(BlueZDevice device,
      {int percentage = 0, String source = ''}) async {
    var battery = BlueZBattery(
        DBusObjectPath('${path.value}/battery$_nextBatteryId'), device,
        percentage: percentage, source: source);
    _nextBatteryId += 1;

    await _client.bus.registerObject(battery);
    return battery;
  }

  /// Removes a [battery] previously added with [addBattery].
  Future<void> removeBattery(BlueZBattery battery) async {
    await _client.bus.unregisterObject(battery);
  }
}

/// A battery that is being reported over Bluetooth.
class BlueZBattery extends DBusObject {
  final String _batteryInterfaceName = 'org.bluez.BatteryProvider1';

  final BlueZDevice device;

  int _percentage;

  BlueZBattery(
    DBusObjectPath path,
    this.device, {
    int percentage = 0,
    this.source = '',
  })  : _percentage = percentage,
        super(path) {
    assert(percentage >= 0 && percentage <= 100);
  }

  /// The amount of charge remaining as a percentage (0-100).
  int get percentage => _percentage;

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties =>
      <String, Map<String, DBusValue>>{_batteryInterfaceName: _getProperties()};

  /// Sets the smound of charge remaintaing as a percentage (0-100).
  set percentage(int value) {
    assert(value >= 0 && value <= 100);
    _percentage = value;
    emitPropertiesChanged(_batteryInterfaceName, changedProperties: {
      'Percentage': DBusByte(value),
    });
  }

  /// Describes where the battery information comes from. (e.g. "HFP 1.7", "HID", or the profile UUID).
  /// This property is informational only and may be useful for debugging
  /// purposes.
  final String source;

  Map<String, DBusValue> _getProperties() {
    return <String, DBusValue>{
      'Percentage': DBusByte(percentage),
      'Source': DBusString(source),
      'Device': device.path
    };
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == _batteryInterfaceName) {
      return DBusMethodErrorResponse.unknownMethod();
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface != _batteryInterfaceName) {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (name) {
      case 'Percentage':
        return DBusGetPropertyResponse(DBusByte(percentage));
      case 'Source':
        return DBusGetPropertyResponse(DBusString(source));
      case 'Device':
        return DBusGetPropertyResponse(device.path);
      default:
        return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> setProperty(
      String interface, String name, DBusValue value) async {
    if (interface != _batteryInterfaceName) {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (name) {
      case 'Percentage':
      case 'Source':
      case 'Device':
        return DBusMethodErrorResponse.propertyReadOnly();
      default:
        return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    return DBusGetAllPropertiesResponse(interface == _batteryInterfaceName
        ? _getProperties()
        : <String, DBusValue>{});
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(
        _batteryInterfaceName,
        properties: [
          DBusIntrospectProperty('Percentage', DBusSignature('y'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('Source', DBusSignature('s'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('Device', DBusSignature('o'),
              access: DBusPropertyAccess.read),
        ],
      ),
    ];
  }
}
