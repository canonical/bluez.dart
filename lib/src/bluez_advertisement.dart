import 'package:bluez/bluez.dart';
import 'package:dbus/dbus.dart';

/// BlueZ server object to register advertisements.
class BlueZAdvertisingManager {
  final String _advertInterfaceName = 'org.bluez.LEAdvertisingManager1';

  final BlueZClient _client;
  final BlueZObject _object;
  int _nextAdvertId;

  BlueZAdvertisingManager(this._client, this._object) : _nextAdvertId = 0;

  /// Registers an advertisement object to be sent over the LE
  /// advertising channel.
  ///
  /// InvalidArguments error indicates that the object has
  /// invalid or conflicting properties.
  ///
  /// InvalidLength error indicates that the data
  /// provided generates a data packet which is too long.
  ///
  /// The properties of this object are parsed when it is
  /// registered, and any changes are ignored.
  ///
  /// If the same object is registered twice it will result in
  /// an AlreadyExists error.
  ///
  /// If the maximum number of advertisement instances is
  /// reached it will result in NotPermitted error.
  Future<BlueZAdvertisement> registerAdvertisement({
    required BlueZAdvertisementType type,
    Map<BlueZManufacturerId, DBusValue> manufacturerData = const {},
    List<String> serviceUuids = const [],
    Map<BlueZUUID, DBusValue> serviceData = const {},
    bool includeTxPower = false,
    List<String> solicitUuids = const [],
    List<String> includes = const [],
    int appearance = 0,
    int duration = 2,
    int timeout = 0,
    String localName = '',
    Future<void> Function()? onRelease,
  }) async {
    final advert = BlueZAdvertisement(
      DBusObjectPath('/org/bluez/advertisement/advert$_nextAdvertId'),
      type: type,
      manufacturerData: manufacturerData,
      serviceUuids: serviceUuids,
      serviceData: serviceData,
      includeTxPower: includeTxPower,
      solicitUuids: solicitUuids,
      includes: includes,
      appearance: appearance,
      duration: duration,
      timeout: timeout,
      localName: localName,
      onRelease: onRelease,
    );

    _nextAdvertId += 1;

    await _client.bus.registerObject(advert);

    await _object.callMethod(_advertInterfaceName, 'RegisterAdvertisement',
        [advert.path, DBusDict.stringVariant({})],
        replySignature: DBusSignature(''));

    return advert;
  }

  /// This unregisters an advertisement that has been
  /// previously registered using [registerAdvertisement].
  Future<void> unregisterAdvertisement(BlueZAdvertisement advert) async {
    await _object.callMethod(
        _advertInterfaceName, 'UnregisterAdvertisement', [advert.path],
        replySignature: DBusSignature(''));

    await _client.bus.unregisterObject(advert);
  }
}

/// An advertisement that is being sent over Bluetooth.
class BlueZAdvertisement extends DBusObject {
  final String _advertInterfaceName = 'org.bluez.LEAdvertisement1';

  BlueZAdvertisement(DBusObjectPath path,
      {required this.manufacturerData,
      required this.type,
      this.serviceUuids = const [],
      this.serviceData = const {},
      this.includeTxPower = false,
      this.solicitUuids = const [],
      this.includes = const [],
      this.appearance = 0,
      this.duration = 2,
      this.timeout = 0,
      this.localName = '',
      this.onRelease})
      : super(path);

  final Map<BlueZManufacturerId, DBusValue> manufacturerData;
  final BlueZAdvertisementType type;
  final List<String> serviceUuids;
  final Map<BlueZUUID, DBusValue> serviceData;
  final bool includeTxPower;
  final List<String> solicitUuids;
  final List<String> includes;
  final int appearance;
  final int duration;
  final int timeout;
  final String localName;
  final Future<void> Function()? onRelease;

  Map<String, DBusValue> _getProperties() {
    return <String, DBusValue>{
      'ManufacturerData': DBusDict(
          DBusSignature('q'),
          DBusSignature('v'),
          manufacturerData.map(
              (id, value) => MapEntry(DBusUint16(id.id), DBusVariant(value)))),
      'Type': DBusString(type.name),
      'ServiceUUIDs': DBusArray.string(serviceUuids),
      'ServiceData': DBusDict.stringVariant(
          serviceData.map((uuid, value) => MapEntry(uuid.toString(), value))),
      'IncludeTxPower': DBusBoolean(includeTxPower),
      'SolicitUUIDs': DBusArray.string(solicitUuids),
      'Includes': DBusArray.string(includes),
      'Appearance': DBusUint16(appearance),
      'Duration': DBusUint16(duration),
      'Timeout': DBusUint16(timeout),
      'LocalName': DBusString(localName)
    };
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == _advertInterfaceName) {
      if (methodCall.name == 'Release') {
        if (methodCall.values.isNotEmpty) {
          return DBusMethodErrorResponse.invalidArgs();
        }
        await onRelease?.call();
        return DBusMethodSuccessResponse();
      } else {
        return DBusMethodErrorResponse.unknownMethod();
      }
    } else {
      return DBusMethodErrorResponse.unknownInterface();
    }
  }

  @override
  Future<DBusMethodResponse> getProperty(String interface, String name) async {
    if (interface != _advertInterfaceName) {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (name) {
      case 'ManufacturerData':
        return DBusGetPropertyResponse(DBusDict(
            DBusSignature('q'),
            DBusSignature('v'),
            manufacturerData.map((id, value) =>
                MapEntry(DBusUint16(id.id), DBusVariant(value)))));
      case 'Type':
        return DBusGetPropertyResponse(DBusString(type.name));
      case 'ServiceUUIDs':
        return DBusGetPropertyResponse(DBusArray.string(serviceUuids));
      case 'ServiceData':
        return DBusGetPropertyResponse(DBusDict.stringVariant(serviceData
            .map((uuid, value) => MapEntry(uuid.toString(), value))));
      case 'IncludeTxPower':
        return DBusGetPropertyResponse(DBusBoolean(includeTxPower));
      case 'SolicitUUIDs':
        return DBusGetPropertyResponse(DBusArray.string(solicitUuids));
      case 'Includes':
        return DBusGetPropertyResponse(DBusArray.string(includes));
      case 'Appearance':
        return DBusGetPropertyResponse(DBusUint16(appearance));
      case 'Duration':
        return DBusGetPropertyResponse(DBusUint16(duration));
      case 'Timeout':
        return DBusGetPropertyResponse(DBusUint16(timeout));
      case 'LocalName':
        return DBusGetPropertyResponse(DBusString(localName));
      default:
        return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  Future<DBusMethodResponse> getAllProperties(String interface) async {
    return DBusGetAllPropertiesResponse(interface == _advertInterfaceName
        ? _getProperties()
        : <String, DBusValue>{});
  }

  @override
  Future<DBusMethodResponse> setProperty(
      String interface, String name, DBusValue value) async {
    if (interface != _advertInterfaceName) {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (name) {
      case 'Type':
      case 'ServiceUUIDs':
      case 'ServiceData':
      case 'IncludeTxPower':
      case 'ManufacturerData':
      case 'SolicitUUIDs':
      case 'Includes':
      case 'Appearance':
      case 'Duration':
      case 'Timeout':
      case 'LocalName':
        return DBusMethodErrorResponse.propertyReadOnly();
      default:
        return DBusMethodErrorResponse.unknownProperty();
    }
  }

  @override
  List<DBusIntrospectInterface> introspect() {
    return [
      DBusIntrospectInterface(
        _advertInterfaceName,
        methods: [
          DBusIntrospectMethod('Release'),
        ],
        properties: [
          DBusIntrospectProperty('Type', DBusSignature('s'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('ServiceUUIDs', DBusSignature('as'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('ServiceData', DBusSignature('a{sv}'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('IncludeTxPower', DBusSignature('b'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('ManufacturerData', DBusSignature('a{qv}'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('SolicitUUIDs', DBusSignature('as'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('Includes', DBusSignature('as'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('Appearance', DBusSignature('q'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('Duration', DBusSignature('q'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('Timeout', DBusSignature('q'),
              access: DBusPropertyAccess.read),
          DBusIntrospectProperty('LocalName', DBusSignature('s'),
              access: DBusPropertyAccess.read),
        ],
      ),
    ];
  }
}
