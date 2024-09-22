import 'package:bluez/bluez.dart';
import 'package:dbus/dbus.dart';

/// A GATT characteristic descriptor.
class BlueZGattDescriptor {
  final String _gattDescriptorInterfaceName = 'org.bluez.GattDescriptor1';

  final BlueZObject _object;

  BlueZGattDescriptor(this._object);

  // TODO(robert-ancell): Includes

  /// Cached value of this descriptor, updated when [readValue] is called.
  List<int> get value =>
      _object.getByteArrayProperty(_gattDescriptorInterfaceName, 'Value') ?? [];

  /// Unique ID for this descriptor.
  BlueZUUID get uuid => BlueZUUID.fromString(
      _object.getStringProperty(_gattDescriptorInterfaceName, 'UUID') ?? '');

  /// Reads the value of the descriptor.
  Future<List<int>> readValue({int? offset}) async {
    var options = <String, DBusValue>{};
    if (offset != null) {
      options['offset'] = DBusUint16(offset);
    }
    var result = await _object.callMethod(_gattDescriptorInterfaceName,
        'ReadValue', [DBusDict.stringVariant(options)],
        replySignature: DBusSignature('ay'));
    return result.returnValues[0].asByteArray().toList();
  }

  /// Writes [data] to the descriptor.
  Future<void> writeValue(Iterable<int> data,
      {int? offset, bool? prepareAuthorize}) async {
    var options = <String, DBusValue>{};
    if (offset != null) {
      options['offset'] = DBusUint16(offset);
    }
    if (prepareAuthorize != null) {
      options['prepare-authorize'] = DBusBoolean(prepareAuthorize);
    }
    await _object.callMethod(_gattDescriptorInterfaceName, 'WriteValue',
        [DBusArray.byte(data), DBusDict.stringVariant(options)],
        replySignature: DBusSignature(''));
  }
}
