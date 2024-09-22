import 'package:bluez/bluez.dart';

/// A GATT service running on a BlueZ device.
class BlueZGattService {
  final String _serviceInterfaceName = 'org.bluez.GattService1';

  final BlueZClient _client;
  final BlueZObject _object;

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
      _client.getGattCharacteristics(_object.path);
}
