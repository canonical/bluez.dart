import 'dart:io';

import 'package:bluez/bluez.dart';
import 'package:dbus/dbus.dart';

/// A characteristic of a GATT service.
class BlueZGattCharacteristic {
  final String _gattCharacteristicInterfaceName =
      'org.bluez.GattCharacteristic1';

  final BlueZClient _client;
  final BlueZObject _object;

  BlueZGattCharacteristic(this._client, this._object);

  /// Stream of property names as their values change.
  Stream<List<String>> get propertiesChanged {
    var interface = _object.interfaces[_gattCharacteristicInterfaceName];
    if (interface == null) {
      throw 'BlueZ characteristic missing $_gattCharacteristicInterfaceName interface';
    }
    return interface.propertiesChangedStreamController.stream;
  }

  // TODO(robert-ancell): Includes

  /// Unique ID for this characteristic.
  BlueZUUID get uuid => BlueZUUID.fromString(
      _object.getStringProperty(_gattCharacteristicInterfaceName, 'UUID') ??
          '');

  /// Cached value of this characteristic, updated when [readValue] is called or in a notification session triggered by [startNotify].
  List<int> get value =>
      _object.getByteArrayProperty(_gattCharacteristicInterfaceName, 'Value') ??
      [];

  /// Get mtu value of this characteristic
  int? get mtu =>
      _object.getUint16Property(_gattCharacteristicInterfaceName, 'MTU');

  /// True if if this characteristic has been acquired by any client using [acquireWrite].
  bool get writeAcquired =>
      _object.getBooleanProperty(
          _gattCharacteristicInterfaceName, 'WriteAcquired') ??
      false;

  /// True if if this characteristic has been acquired by any client using [acquireNotify].
  bool get notifyAcquired =>
      _object.getBooleanProperty(
          _gattCharacteristicInterfaceName, 'NotifyAcquired') ??
      false;

  /// True, if notifications or indications on this characteristic are currently enabled.
  bool get notifying =>
      _object.getBooleanProperty(
          _gattCharacteristicInterfaceName, 'Notifying') ??
      false;

  /// Defines how this characteristic value can be used.
  Set<BlueZGattCharacteristicFlag> get flags {
    var flags = <BlueZGattCharacteristicFlag>{};
    var values = _object.getStringArrayProperty(
            _gattCharacteristicInterfaceName, 'Flags') ??
        [];
    for (var value in values) {
      switch (value) {
        case 'broadcast':
          flags.add(BlueZGattCharacteristicFlag.broadcast);
          break;
        case 'read':
          flags.add(BlueZGattCharacteristicFlag.read);
          break;
        case 'write-without-response':
          flags.add(BlueZGattCharacteristicFlag.writeWithoutResponse);
          break;
        case 'write':
          flags.add(BlueZGattCharacteristicFlag.write);
          break;
        case 'notify':
          flags.add(BlueZGattCharacteristicFlag.notify);
          break;
        case 'indicate':
          flags.add(BlueZGattCharacteristicFlag.indicate);
          break;
        case 'authenticated-signed-writes':
          flags.add(BlueZGattCharacteristicFlag.authenticatedSignedWrites);
          break;
        case 'extended-properties':
          flags.add(BlueZGattCharacteristicFlag.extendedProperties);
          break;
        case 'reliable-write':
          flags.add(BlueZGattCharacteristicFlag.reliableWrite);
          break;
        case 'writable-auxiliaries':
          flags.add(BlueZGattCharacteristicFlag.writableAuxiliaries);
          break;
        case 'encrypt-read':
          flags.add(BlueZGattCharacteristicFlag.encryptRead);
          break;
        case 'encrypt-write':
          flags.add(BlueZGattCharacteristicFlag.encryptWrite);
          break;
        case 'encrypt-authenticated-read':
          flags.add(BlueZGattCharacteristicFlag.encryptAuthenticatedRead);
          break;
        case 'encrypt-authenticated-write':
          flags.add(BlueZGattCharacteristicFlag.encryptAuthenticatedWrite);
          break;
        case 'secure-read':
          flags.add(BlueZGattCharacteristicFlag.secureRead);
          break;
        case 'secure-write':
          flags.add(BlueZGattCharacteristicFlag.secureWrite);
          break;
        case 'authorize':
          flags.add(BlueZGattCharacteristicFlag.authorize);
          break;
      }
    }
    return flags;
  }

  /// The Gatt descriptors provided by this characteristic.
  List<BlueZGattDescriptor> get descriptors =>
      _client.getGattDescriptors(_object.path);

  /// Reads the value of the characteristic.
  Future<List<int>> readValue({int? offset}) async {
    var options = <String, DBusValue>{};
    if (offset != null) {
      options['offset'] = DBusUint16(offset);
    }
    var result = await _object.callMethod(_gattCharacteristicInterfaceName,
        'ReadValue', [DBusDict.stringVariant(options)],
        replySignature: DBusSignature('ay'));
    return result.returnValues[0].asByteArray().toList();
  }

  /// Writes [data] to the characteristic.
  Future<void> writeValue(Iterable<int> data,
      {int? offset,
      BlueZGattCharacteristicWriteType? type,
      bool? prepareAuthorize}) async {
    var options = <String, DBusValue>{};
    if (offset != null) {
      options['offset'] = DBusUint16(offset);
    }
    if (type != null) {
      String typeName;
      switch (type) {
        case BlueZGattCharacteristicWriteType.command:
          typeName = 'command';
          break;
        case BlueZGattCharacteristicWriteType.request:
          typeName = 'request';
          break;
        case BlueZGattCharacteristicWriteType.reliable:
          typeName = 'reliable';
          break;
      }
      options['type'] = DBusString(typeName);
    }
    if (prepareAuthorize != null) {
      options['prepare-authorize'] = DBusBoolean(prepareAuthorize);
    }
    await _object.callMethod(_gattCharacteristicInterfaceName, 'WriteValue',
        [DBusArray.byte(data), DBusDict.stringVariant(options)],
        replySignature: DBusSignature(''));
  }

  /// Acquire a [RawSocket] for writing to this characterisitic.
  /// Usage of [writeValue] will be locked causing it to return NotPermitted error.
  /// To release the lock close the returned file.
  Future<BlueZGattAcquireWriteResult> acquireWrite() async {
    var options = <String, DBusValue>{};
    var result = await _object.callMethod(_gattCharacteristicInterfaceName,
        'AcquireWrite', [DBusDict.stringVariant(options)],
        replySignature: DBusSignature('hq'));
    var handle = result.values[0].asUnixFd();
    var mtu = result.values[1].asUint16();
    return BlueZGattAcquireWriteResult(handle.toRawSocket(), mtu);
  }

  /// Acquire a [RawSocket] for receiving notifications from this characterisitic.
  /// To release the lock close the returned socket.
  Future<BlueZGattAcquireNotifyResult> acquireNotify() async {
    var options = <String, DBusValue>{};
    var result = await _object.callMethod(_gattCharacteristicInterfaceName,
        'AcquireNotify', [DBusDict.stringVariant(options)],
        replySignature: DBusSignature('hq'));
    var handle = result.values[0].asUnixFd();
    var mtu = result.values[1].asUint16();
    return BlueZGattAcquireNotifyResult(handle.toRawSocket(), mtu);
  }

  /// Starts a notification session from this characteristic if it supports value notifications or indications.
  Future<void> startNotify() async {
    await _object.callMethod(
        _gattCharacteristicInterfaceName, 'StartNotify', [],
        replySignature: DBusSignature(''));
  }

  /// Cancel any previous [startNotify] transaction.
  /// Note that notifications from a characteristic are shared between sessions thus calling stopNotify will release a single session.
  Future<void> stopNotify() async {
    await _object.callMethod(_gattCharacteristicInterfaceName, 'StopNotify', [],
        replySignature: DBusSignature(''));
  }
}

/// Result of a [BlueZGattCharacteristic.acquireWrite] call.
class BlueZGattAcquireWriteResult {
  /// Socket to allow writes to the GATT characteristic.
  final RawSocket socket;

  /// The maximum number of bytes allowed in each write to [socket].
  final int mtu;

  const BlueZGattAcquireWriteResult(this.socket, this.mtu);
}

/// Result of a [BlueZGattCharacteristic.acquireNotify] call.
class BlueZGattAcquireNotifyResult {
  /// Socket that streams values from the device.
  final RawSocket socket;

  /// The maximum number of bytes allowed in each read from [socket].
  final int mtu;

  const BlueZGattAcquireNotifyResult(this.socket, this.mtu);
}
