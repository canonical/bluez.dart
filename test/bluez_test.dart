import 'dart:io';

import 'package:bluez/bluez.dart';
import 'package:dbus/dbus.dart';
import 'package:test/test.dart';

class MockBlueZObject extends DBusObject {
  MockBlueZObject(DBusObjectPath path) : super(path);
}

class MockBlueZManagerObject extends MockBlueZObject {
  final MockBlueZServer server;

  MockBlueZManagerObject(this.server) : super(DBusObjectPath('/org/bluez'));

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.bluez.AgentManager1') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'RegisterAgent':
        server.agentAddress = methodCall.sender;
        server.agentPath = methodCall.values[0] as DBusObjectPath;
        server.agentCapability = (methodCall.values[1] as DBusString).value;
        return DBusMethodSuccessResponse();
      case 'RequestDefaultAgent':
        server.agentIsDefault = true;
        return DBusMethodSuccessResponse();
      case 'UnregisterAgent':
        server.agentAddress = null;
        server.agentPath = null;
        server.agentCapability = '';
        server.agentIsDefault = false;
        return DBusMethodSuccessResponse();
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }
}

class MockBlueZAdapterObject extends MockBlueZObject {
  final MockBlueZServer server;
  final String deviceName;

  final String address;
  final String addressType;
  String alias;
  final int class_;
  bool discoverable;
  int discoverableTimeout;
  bool discovering;
  Map<String, DBusValue> discoveryFilter;
  final String modalias;
  final String name;
  bool pairable;
  int pairableTimeout;
  bool powered;
  final List<String> roles;
  final List<String> uuids;

  MockBlueZAdapterObject(this.server, this.deviceName,
      {this.address = '',
      this.addressType = 'public',
      this.alias = '',
      this.class_ = 0,
      this.discoverable = false,
      this.discoverableTimeout = 0,
      this.discovering = false,
      this.discoveryFilter = const {},
      this.modalias = '',
      this.name = '',
      this.pairable = false,
      this.pairableTimeout = 0,
      this.powered = true,
      this.roles = const [],
      this.uuids = const []})
      : super(DBusObjectPath('/org/bluez/$deviceName'));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.bluez.Adapter1': {
          'Address': DBusString(address),
          'AddressType': DBusString(addressType),
          'Alias': DBusString(alias),
          'Class': DBusUint32(class_),
          'Discoverable': DBusBoolean(discoverable),
          'DiscoverableTimeout': DBusUint32(discoverableTimeout),
          'Discovering': DBusBoolean(discovering),
          'Modalias': DBusString(modalias),
          'Name': DBusString(name),
          'Pairable': DBusBoolean(pairable),
          'PairableTimeout': DBusUint32(pairableTimeout),
          'Powered': DBusBoolean(powered),
          'Roles': DBusArray.string(roles),
          'UUIDs': DBusArray.string(uuids)
        }
      };

  @override
  Future<DBusMethodResponse> setProperty(
      String interface, String name, DBusValue value) async {
    if (interface != 'org.bluez.Adapter1') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    if (name == 'Alias') {
      alias = (value as DBusString).value;
    } else if (name == 'Discoverable') {
      discoverable = (value as DBusBoolean).value;
    } else if (name == 'DiscoverableTimeout') {
      discoverableTimeout = (value as DBusUint32).value;
    } else if (name == 'Pairable') {
      pairable = (value as DBusBoolean).value;
    } else if (name == 'PairableTimeout') {
      pairableTimeout = (value as DBusUint32).value;
    } else if (name == 'Powered') {
      powered = (value as DBusBoolean).value;
    } else {
      return DBusMethodErrorResponse.propertyReadOnly();
    }
    return DBusMethodSuccessResponse();
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.bluez.Adapter1') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'GetDiscoveryFilters':
        return DBusMethodSuccessResponse(
            [DBusArray.string(discoveryFilter.keys)]);
      case 'RemoveDevice':
        var path = methodCall.values[0] as DBusObjectPath;
        var devices = server.devices.where((device) => device.path == path);
        if (devices.isEmpty) {
          return DBusMethodErrorResponse('org.bluez.Error.DoesNotExist');
        }
        await server.removeDevice(devices.first);
        return DBusMethodSuccessResponse();
      case 'SetDiscoveryFilter':
        var properties = (methodCall.values[0] as DBusDict).children.map((key,
                value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
        discoveryFilter.addAll(properties);
        return DBusMethodSuccessResponse();
      case 'StartDiscovery':
        discovering = true;
        return DBusMethodSuccessResponse();
      case 'StopDiscovery':
        discovering = false;
        return DBusMethodSuccessResponse();
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }

  void changeProperties(
      {bool? discoverable,
      bool? discovering,
      bool? pairable,
      bool? powered}) async {
    var changedProperties = <String, DBusValue>{};
    if (discoverable != null) {
      this.discoverable = discoverable;
      changedProperties['Discoverable'] = DBusBoolean(discoverable);
    }
    if (discovering != null) {
      this.discovering = discovering;
      changedProperties['Discovering'] = DBusBoolean(discovering);
    }
    if (pairable != null) {
      this.pairable = pairable;
      changedProperties['Pairable'] = DBusBoolean(pairable);
    }
    if (powered != null) {
      this.powered = powered;
      changedProperties['Powered'] = DBusBoolean(powered);
    }
    await emitPropertiesChanged('org.bluez.Adapter1',
        changedProperties: changedProperties);
  }
}

enum MockBlueZDeviceAuthType {
  none,
  confirm,
  confirmPinCode,
  confirmPasskey,
  requestPinCode,
  requestPasskey
}

class MockBlueZDeviceObject extends MockBlueZObject {
  final MockBlueZAdapterObject adapter;
  MockBlueZServer get server => adapter.server;

  final String address;
  final String addressType;
  String alias;
  final int appearance;
  final MockBlueZDeviceAuthType authType;
  bool blocked;
  final int class_;
  bool connected;
  final String icon;
  final bool legacyPairing;
  final Map<int, DBusValue> manufacturerData;
  final String modalias;
  final String name;
  bool paired;
  final int? passkey;
  final String? pinCode;
  int rssi;
  final Map<String, DBusValue> serviceData;
  final bool servicesResolved;
  bool trusted;
  final int txPower;
  bool wakeAllowed;
  final List<String> uuids;

  MockBlueZDeviceObject(this.adapter,
      {required this.address,
      this.addressType = 'public',
      this.alias = '',
      this.appearance = 0,
      this.authType = MockBlueZDeviceAuthType.none,
      this.blocked = false,
      this.class_ = 0,
      this.connected = false,
      this.icon = '',
      this.legacyPairing = false,
      this.manufacturerData = const {},
      this.modalias = '',
      this.name = '',
      this.paired = false,
      this.passkey,
      this.pinCode,
      this.rssi = 0,
      this.serviceData = const {},
      this.servicesResolved = false,
      this.trusted = false,
      this.txPower = 0,
      this.wakeAllowed = false,
      this.uuids = const []})
      : super(DBusObjectPath(
            adapter.path.value + '/dev_' + address.replaceAll(':', '_')));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.bluez.Device1': {
          'Adapter': adapter.path,
          'Address': DBusString(address),
          'AddressType': DBusString(addressType),
          'Alias': DBusString(alias),
          'Appearance': DBusUint16(appearance),
          'Blocked': DBusBoolean(blocked),
          'Class': DBusUint32(class_),
          'Connected': DBusBoolean(connected),
          'Icon': DBusString(icon),
          'LegacyPairing': DBusBoolean(legacyPairing),
          'ManufacturerData': DBusDict(
              DBusSignature('q'),
              DBusSignature('v'),
              manufacturerData.map(
                  (id, value) => MapEntry(DBusUint16(id), DBusVariant(value)))),
          'Modalias': DBusString(modalias),
          'Name': DBusString(name),
          'Paired': DBusBoolean(paired),
          'RSSI': DBusInt16(rssi),
          'ServiceData': DBusDict.stringVariant(serviceData),
          'ServicesResolved': DBusBoolean(servicesResolved),
          'Trusted': DBusBoolean(trusted),
          'TxPower': DBusInt16(txPower),
          'WakeAllowed': DBusBoolean(wakeAllowed),
          'UUIDs': DBusArray.string(uuids)
        }
      };

  @override
  Future<DBusMethodResponse> setProperty(
      String interface, String name, DBusValue value) async {
    if (interface != 'org.bluez.Device1') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    if (name == 'Alias') {
      alias = (value as DBusString).value;
    } else if (name == 'Blocked') {
      blocked = (value as DBusBoolean).value;
    } else if (name == 'Trusted') {
      trusted = (value as DBusBoolean).value;
    } else if (name == 'WakeAllowed') {
      wakeAllowed = (value as DBusBoolean).value;
    } else {
      return DBusMethodErrorResponse.propertyReadOnly();
    }
    return DBusMethodSuccessResponse();
  }

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.bluez.Device1') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'CancelPairing':
        return DBusMethodSuccessResponse();
      case 'Connect':
        await changeProperties(connected: true);
        return DBusMethodSuccessResponse();
      case 'Disconnect':
        await changeProperties(connected: false);
        return DBusMethodSuccessResponse();
      case 'Pair':
        switch (authType) {
          case MockBlueZDeviceAuthType.none:
            await changeProperties(paired: true);
            return DBusMethodSuccessResponse();
          case MockBlueZDeviceAuthType.confirm:
            if (server.agentAddress == null) {
              return DBusMethodErrorResponse(
                  'org.bluez.Error.AuthenticationFailed');
            }

            try {
              await client!.callMethod(
                  destination: server.agentAddress,
                  path: server.agentPath!,
                  interface: 'org.bluez.Agent1',
                  name: 'RequestAuthorization',
                  values: [path],
                  replySignature: DBusSignature(''));
            } on DBusMethodResponseException {
              return DBusMethodErrorResponse(
                  'org.bluez.Error.AuthenticationRejected');
            }
            await changeProperties(paired: true);
            return DBusMethodSuccessResponse();
          case MockBlueZDeviceAuthType.confirmPinCode:
            if (server.agentAddress == null) {
              return DBusMethodErrorResponse(
                  'org.bluez.Error.AuthenticationFailed');
            }

            try {
              await client!.callMethod(
                  destination: server.agentAddress,
                  path: server.agentPath!,
                  interface: 'org.bluez.Agent1',
                  name: 'DisplayPinCode',
                  values: [path, DBusString(pinCode!)],
                  replySignature: DBusSignature(''));
            } on DBusMethodResponseException {
              return DBusMethodErrorResponse(
                  'org.bluez.Error.AuthenticationRejected');
            }
            await changeProperties(paired: true);
            return DBusMethodSuccessResponse();
          case MockBlueZDeviceAuthType.confirmPasskey:
            if (server.agentAddress == null) {
              return DBusMethodErrorResponse(
                  'org.bluez.Error.AuthenticationFailed');
            }

            try {
              await client!.callMethod(
                  destination: server.agentAddress,
                  path: server.agentPath!,
                  interface: 'org.bluez.Agent1',
                  name: 'RequestConfirmation',
                  values: [path, DBusUint32(passkey!)],
                  replySignature: DBusSignature(''));
            } on DBusMethodResponseException {
              return DBusMethodErrorResponse(
                  'org.bluez.Error.AuthenticationRejected');
            }
            await changeProperties(paired: true);
            return DBusMethodSuccessResponse();
          case MockBlueZDeviceAuthType.requestPinCode:
            if (server.agentAddress == null) {
              return DBusMethodErrorResponse(
                  'org.bluez.Error.AuthenticationFailed');
            }

            DBusMethodSuccessResponse result;
            try {
              result = await client!.callMethod(
                  destination: server.agentAddress,
                  path: server.agentPath!,
                  interface: 'org.bluez.Agent1',
                  name: 'RequestPinCode',
                  values: [path],
                  replySignature: DBusSignature('s'));
            } on DBusMethodResponseException {
              return DBusMethodErrorResponse(
                  'org.bluez.Error.AuthenticationRejected');
            }

            var pinCode = (result.values[0] as DBusString).value;
            if (pinCode == this.pinCode) {
              await changeProperties(paired: true);
            }
            return DBusMethodSuccessResponse();
          case MockBlueZDeviceAuthType.requestPasskey:
            if (server.agentAddress == null) {
              return DBusMethodErrorResponse(
                  'org.bluez.Error.AuthenticationFailed');
            }

            DBusMethodSuccessResponse result;
            try {
              result = await client!.callMethod(
                  destination: server.agentAddress,
                  path: server.agentPath!,
                  interface: 'org.bluez.Agent1',
                  name: 'RequestPasskey',
                  values: [path],
                  replySignature: DBusSignature('u'));
            } on DBusMethodResponseException {
              return DBusMethodErrorResponse(
                  'org.bluez.Error.AuthenticationRejected');
            }
            var passkey = (result.values[0] as DBusUint32).value;
            if (passkey == this.passkey) {
              await changeProperties(paired: true);
            }
            return DBusMethodSuccessResponse();
        }
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }

  Future<void> changeProperties(
      {bool? connected, bool? paired, int? rssi}) async {
    var changedProperties = <String, DBusValue>{};
    if (connected != null) {
      this.connected = connected;
      changedProperties['Connected'] = DBusBoolean(connected);
    }
    if (paired != null) {
      this.paired = paired;
      changedProperties['Paired'] = DBusBoolean(paired);
    }
    if (rssi != null) {
      this.rssi = rssi;
      changedProperties['RSSI'] = DBusInt16(rssi);
    }
    await emitPropertiesChanged('org.bluez.Device1',
        changedProperties: changedProperties);
  }
}

class MockBlueZGattServiceObject extends MockBlueZObject {
  final MockBlueZDeviceObject device;

  final int id;
  final List<MockBlueZGattServiceObject> includes;
  final bool primary;
  final String uuid;

  MockBlueZGattServiceObject(this.device, this.id,
      {this.includes = const [], this.primary = true, required this.uuid})
      : super(DBusObjectPath(device.path.value +
            '/service' +
            id.toRadixString(16).padLeft(4, '0')));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.bluez.GattService1': {
          'Device': device.path,
          'Includes':
              DBusArray.objectPath(includes.map((service) => service.path)),
          'Primary': DBusBoolean(primary),
          'UUID': DBusString(uuid)
        }
      };
}

class MockBlueZGattCharacteristicObject extends MockBlueZObject {
  final MockBlueZGattServiceObject service;

  final int id;
  final List<String> flags;
  final bool notifyAcquired;
  final bool notifying;
  final bool writeAcquired;
  final value = <int>[];
  final String uuid;

  MockBlueZGattCharacteristicObject(this.service, this.id,
      {this.flags = const [],
      this.notifyAcquired = false,
      this.notifying = false,
      this.writeAcquired = false,
      required this.uuid,
      List<int> value = const []})
      : super(DBusObjectPath(service.path.value +
            '/char' +
            id.toRadixString(16).padLeft(4, '0'))) {
    this.value.addAll(value);
  }

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.bluez.GattCharacteristic1': {
          'Flags': DBusArray.string(flags),
          'NotifyAcquired': DBusBoolean(notifyAcquired),
          'Notifying': DBusBoolean(notifying),
          'WriteAcquired': DBusBoolean(writeAcquired),
          'Service': service.path,
          'UUID': DBusString(uuid),
          'Value': DBusArray.byte(value)
        }
      };

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.bluez.GattCharacteristic1') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'ReadValue':
        var options = (methodCall.values[0] as DBusDict).children.map((key,
                value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
        var offset = (options['offset'] as DBusUint16?)?.value ?? 0;
        return DBusMethodSuccessResponse([DBusArray.byte(value.skip(offset))]);
      case 'WriteValue':
        var data = (methodCall.values[0] as DBusArray)
            .children
            .map((value) => (value as DBusByte).value);
        var options = (methodCall.values[1] as DBusDict).children.map((key,
                value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
        var offset = (options['offset'] as DBusUint16?)?.value ?? 0;
        value.removeRange(offset, offset + data.length);
        value.insertAll(offset, data);
        return DBusMethodSuccessResponse();
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }
}

class MockBlueZGattDescriptorObject extends MockBlueZObject {
  final MockBlueZGattCharacteristicObject characteristic;

  final int id;
  final List<int> value;
  final String uuid;

  MockBlueZGattDescriptorObject(this.characteristic, this.id,
      {required this.uuid, this.value = const []})
      : super(DBusObjectPath(characteristic.path.value +
            '/desc' +
            id.toRadixString(16).padLeft(4, '0')));

  @override
  Map<String, Map<String, DBusValue>> get interfacesAndProperties => {
        'org.bluez.GattDescriptor1': {
          'Characteristic': characteristic.path,
          'UUID': DBusString(uuid),
          'Value': DBusArray.byte(value)
        }
      };

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.bluez.GattDescriptor1') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    switch (methodCall.name) {
      case 'ReadValue':
        var options = (methodCall.values[0] as DBusDict).children.map((key,
                value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
        var offset = (options['offset'] as DBusUint16?)?.value ?? 0;
        return DBusMethodSuccessResponse([DBusArray.byte(value.skip(offset))]);
      case 'WriteValue':
        var data = (methodCall.values[0] as DBusArray)
            .children
            .map((value) => (value as DBusByte).value);
        var options = (methodCall.values[1] as DBusDict).children.map((key,
                value) =>
            MapEntry((key as DBusString).value, (value as DBusVariant).value));
        var offset = (options['offset'] as DBusUint16?)?.value ?? 0;
        value.removeRange(offset, offset + data.length);
        value.insertAll(offset, data);
        return DBusMethodSuccessResponse();
      default:
        return DBusMethodErrorResponse.unknownMethod();
    }
  }
}

class MockBlueZServer extends DBusClient {
  late final DBusObject root;

  String? agentAddress;
  DBusObjectPath? agentPath;
  String agentCapability = '';
  bool agentIsDefault = false;

  final adapters = <MockBlueZAdapterObject>[];
  final devices = <MockBlueZDeviceObject>[];

  MockBlueZServer(DBusAddress clientAddress) : super(clientAddress);

  Future<void> start() async {
    await requestName('org.bluez');
    root = DBusObject(DBusObjectPath('/'), isObjectManager: true);
    await registerObject(root);

    var manager = MockBlueZManagerObject(this);
    await registerObject(manager);
  }

  Future<MockBlueZAdapterObject> addAdapter(String deviceName,
      {String address = '',
      String addressType = 'public',
      String alias = '',
      int class_ = 0,
      bool discoverable = false,
      int discoverableTimeout = 0,
      bool discovering = false,
      Map<String, DBusValue> discoveryFilter = const {},
      String modalias = '',
      String name = '',
      bool pairable = false,
      int pairableTimeout = 0,
      bool powered = true,
      List<String> roles = const [],
      List<String> uuids = const []}) async {
    var adapter = MockBlueZAdapterObject(this, deviceName,
        address: address,
        addressType: addressType,
        alias: alias,
        class_: class_,
        discoverable: discoverable,
        discoverableTimeout: discoverableTimeout,
        discovering: discovering,
        discoveryFilter: discoveryFilter,
        modalias: modalias,
        name: name,
        pairable: pairable,
        pairableTimeout: pairableTimeout,
        powered: powered,
        roles: roles,
        uuids: uuids);
    adapters.add(adapter);
    await registerObject(adapter);
    return adapter;
  }

  Future<void> removeAdapter(MockBlueZAdapterObject adapter) async {
    adapters.remove(adapter);
    await unregisterObject(adapter);
  }

  Future<MockBlueZDeviceObject> addDevice(MockBlueZAdapterObject adapter,
      {required String address,
      String addressType = 'public',
      String alias = '',
      int appearance = 0,
      MockBlueZDeviceAuthType authType = MockBlueZDeviceAuthType.none,
      bool blocked = false,
      int class_ = 0,
      bool connected = false,
      String icon = '',
      bool legacyPairing = false,
      Map<int, DBusValue> manufacturerData = const {},
      String modalias = '',
      String name = '',
      bool paired = false,
      int? passkey,
      String? pinCode,
      int rssi = 0,
      Map<String, DBusValue> serviceData = const {},
      bool servicesResolved = false,
      bool trusted = false,
      int txPower = 0,
      List<String> uuids = const [],
      bool wakeAllowed = false}) async {
    var device = MockBlueZDeviceObject(adapter,
        address: address,
        addressType: addressType,
        alias: alias,
        appearance: appearance,
        authType: authType,
        blocked: blocked,
        class_: class_,
        connected: connected,
        icon: icon,
        legacyPairing: legacyPairing,
        manufacturerData: manufacturerData,
        modalias: modalias,
        name: name,
        paired: paired,
        passkey: passkey,
        pinCode: pinCode,
        rssi: rssi,
        serviceData: serviceData,
        servicesResolved: servicesResolved,
        trusted: trusted,
        txPower: txPower,
        wakeAllowed: wakeAllowed,
        uuids: uuids);
    devices.add(device);
    await registerObject(device);
    return device;
  }

  Future<void> removeDevice(MockBlueZDeviceObject device) async {
    devices.remove(device);
    await unregisterObject(device);
  }

  Future<MockBlueZGattServiceObject> addService(
      MockBlueZDeviceObject device, int id,
      {List<MockBlueZGattServiceObject> includes = const [],
      bool primary = true,
      required String uuid}) async {
    var service = MockBlueZGattServiceObject(device, id,
        includes: includes, primary: primary, uuid: uuid);
    await registerObject(service);
    return service;
  }

  Future<MockBlueZGattCharacteristicObject> addCharacteristic(
      MockBlueZGattServiceObject service, int id,
      {List<String> flags = const [],
      bool notifyAcquired = false,
      bool notifying = false,
      bool writeAcquired = false,
      List<int> value = const [],
      required String uuid}) async {
    var characteristic = MockBlueZGattCharacteristicObject(service, id,
        flags: flags,
        notifyAcquired: notifyAcquired,
        notifying: notifying,
        writeAcquired: writeAcquired,
        value: value,
        uuid: uuid);
    await registerObject(characteristic);
    return characteristic;
  }

  Future<MockBlueZGattDescriptorObject> addDescriptor(
      MockBlueZGattCharacteristicObject service, int id,
      {List<int> value = const [], required String uuid}) async {
    var characteristic =
        MockBlueZGattDescriptorObject(service, id, value: value, uuid: uuid);
    await registerObject(characteristic);
    return characteristic;
  }
}

class TestAgent extends BlueZAgent {
  final String? pinCode;
  final int? passkey;
  String? lastPinCode;
  var pinCodeRequested = false;
  int? lastPasskey;
  var passkeyRequested = false;
  var authRequested = false;

  TestAgent({this.pinCode, this.passkey});

  @override
  Future<BlueZAgentPinCodeResponse> requestPinCode(BlueZDevice device) async {
    pinCodeRequested = true;
    if (pinCode != null) {
      return BlueZAgentPinCodeResponse.success(pinCode!);
    } else {
      return BlueZAgentPinCodeResponse.rejected();
    }
  }

  @override
  Future<BlueZAgentResponse> displayPinCode(
      BlueZDevice device, String pinCode) async {
    lastPinCode = pinCode;
    return BlueZAgentResponse.success();
  }

  @override
  Future<BlueZAgentPasskeyResponse> requestPasskey(BlueZDevice device) async {
    passkeyRequested = true;
    if (passkey != null) {
      return BlueZAgentPasskeyResponse.success(passkey!);
    } else {
      return BlueZAgentPasskeyResponse.rejected();
    }
  }

  @override
  Future<BlueZAgentResponse> requestConfirmation(
      BlueZDevice device, int passkey) async {
    lastPasskey = passkey;
    return BlueZAgentResponse.success();
  }

  @override
  Future<BlueZAgentResponse> requestAuthorization(BlueZDevice device) async {
    authRequested = true;
    return BlueZAgentResponse.success();
  }
}

class TestEmptyAgent extends BlueZAgent {}

void main() {
  test('uuid', () async {
    // Too short.
    expect(() => BlueZUUID([]), throwsFormatException);
    expect(() => BlueZUUID([1, 2, 3]), throwsFormatException);

    // Invalid strings.
    expect(() => BlueZUUID.fromString(''), throwsFormatException);
    expect(() => BlueZUUID.fromString('000004d200001000800000805f9b34fb'),
        throwsFormatException);
    expect(
        () => BlueZUUID.fromString('0000-04d2-0000-1000-8000-0080-5f9b-34fb'),
        throwsFormatException);
    expect(() => BlueZUUID.fromString('4d2-0-1000-8000-805f9b34fb'),
        throwsFormatException);
    expect(() => BlueZUUID.fromString('xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'),
        throwsFormatException);

    // Different constructors.
    expect(
        BlueZUUID(
            [0, 0, 4, 210, 0, 0, 16, 0, 128, 0, 0, 128, 95, 155, 52, 251]),
        equals(BlueZUUID.fromString('000004d2-0000-1000-8000-00805f9b34fb')));
    expect(BlueZUUID.fromString('000004d2-0000-1000-8000-00805f9b34fb'),
        equals(BlueZUUID.fromString('000004d2-0000-1000-8000-00805f9b34fb')));
    expect(BlueZUUID.short(1234),
        equals(BlueZUUID.fromString('000004d2-0000-1000-8000-00805f9b34fb')));

    // Can determine which UUIDs are in short form.
    expect(BlueZUUID.fromString('000004d2-0000-1000-8000-00805f9b34fb').isShort,
        isTrue);
    expect(BlueZUUID.fromString('e95d0753-251d-470a-a062-fa1922dfa9a8').isShort,
        isFalse);

    // Can read raw value.
    expect(BlueZUUID.fromString('000004d2-0000-1000-8000-00805f9b34fb').value,
        equals([0, 0, 4, 210, 0, 0, 16, 0, 128, 0, 0, 128, 95, 155, 52, 251]));
  });

  test('no adapters or devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.adapters, isEmpty);
    expect(client.devices, isEmpty);
  });

  test('adapters', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    await bluez.addAdapter('hci0', address: 'AD:A9:7E:F0:00:01');
    await bluez.addAdapter('hci1', address: 'AD:A9:7E:F0:00:02');
    await bluez.addAdapter('hci2', address: 'AD:A9:7E:F0:00:03');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.adapters, hasLength(3));
    expect(client.adapters[0].address, equals('AD:A9:7E:F0:00:01'));
    expect(client.adapters[1].address, equals('AD:A9:7E:F0:00:02'));
    expect(client.adapters[2].address, equals('AD:A9:7E:F0:00:03'));
  });

  test('adapter added', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    client.adapterAdded.listen(expectAsync1((adapter) {
      expect(adapter.address, equals('AD:A9:7E:F0:00:01'));
    }));

    await bluez.addAdapter('hci0', address: 'AD:A9:7E:F0:00:01');
  });

  test('adapter removed', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    var adapter = await bluez.addAdapter('hci0', address: 'AD:A9:7E:F0:00:01');

    client.adapterRemoved.listen(expectAsync1((adapter) {
      expect(adapter.address, equals('AD:A9:7E:F0:00:01'));
    }));

    await bluez.removeAdapter(adapter);
  });

  test('adapter properties', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    await bluez.addAdapter('hci0',
        address: 'AD:A9:7E:F0:00:01',
        addressType: 'public',
        alias: 'Test Adapter Alias',
        class_: 777,
        discoverable: true,
        discoverableTimeout: 60,
        discovering: true,
        modalias: 'usb:adapter1',
        name: 'Test Adapter',
        pairable: true,
        pairableTimeout: 120,
        powered: true,
        roles: [
          'role1',
          'role2'
        ],
        uuids: [
          '00000001-0000-1000-8000-00805f9b34fb',
          '00000002-0000-1000-8000-00805f9b34fb'
        ]);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.adapters, hasLength(1));
    var adapter = client.adapters[0];
    expect(adapter.address, equals('AD:A9:7E:F0:00:01'));
    expect(adapter.addressType, equals(BlueZAddressType.public));
    expect(adapter.alias, equals('Test Adapter Alias'));
    expect(adapter.deviceClass, equals(777));
    expect(adapter.discoverable, isTrue);
    expect(adapter.discoverableTimeout, equals(60));
    expect(adapter.discovering, isTrue);
    expect(adapter.modalias, equals('usb:adapter1'));
    expect(adapter.name, equals('Test Adapter'));
    expect(adapter.pairable, isTrue);
    expect(adapter.pairableTimeout, equals(120));
    expect(adapter.powered, isTrue);
    expect(adapter.roles, equals(['role1', 'role2']));
    expect(adapter.uuids, equals([BlueZUUID.short(1), BlueZUUID.short(2)]));
  });

  test('adapter set properties', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var a = await bluez.addAdapter('hci0',
        alias: 'Original Alias',
        discoverable: false,
        discoverableTimeout: 0,
        pairable: false,
        pairableTimeout: 0,
        powered: false);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.adapters, hasLength(1));
    var adapter = client.adapters[0];

    expect(a.alias, equals('Original Alias'));
    await adapter.setAlias('New Alias');
    expect(a.alias, equals('New Alias'));

    expect(a.discoverable, isFalse);
    expect(a.discoverableTimeout, equals(0));
    await adapter.setDiscoverable(true);
    await adapter.setDiscoverableTimeout(60);
    expect(a.discoverable, isTrue);
    expect(a.discoverableTimeout, equals(60));

    expect(a.pairable, isFalse);
    expect(a.pairableTimeout, equals(0));
    await adapter.setPairable(true);
    await adapter.setPairableTimeout(60);
    expect(a.pairable, isTrue);
    expect(a.pairableTimeout, equals(60));

    expect(a.powered, isFalse);
    await adapter.setPowered(true);
    expect(a.powered, isTrue);
  });

  test('adapter properties changed', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var a = await bluez.addAdapter('hci0', powered: false, discovering: false);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.adapters, hasLength(1));
    var adapter = client.adapters[0];
    adapter.propertiesChanged.listen(expectAsync1((properties) {
      expect(properties, equals(['Discovering', 'Powered']));
      expect(adapter.discovering, isTrue);
      expect(adapter.powered, isTrue);
    }));

    a.changeProperties(powered: true, discovering: true);
  });

  test('adapter discover', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    addTearDown(() async => await server.close());
    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var a = await bluez.addAdapter('hci0', discoveryFilter: {
      'UUIDs': DBusArray.string([]),
      'RSSI': DBusInt16(-50),
      'Pathloss': DBusUint16(0),
      'Transport': DBusString('auto'),
      'DuplicateData': DBusBoolean(true),
      'Discoverable': DBusBoolean(false),
      'Pattern': DBusString('')
    });

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.adapters, hasLength(1));
    var adapter = client.adapters[0];

    expect(
        await adapter.getDiscoveryFilters(),
        equals([
          'UUIDs',
          'RSSI',
          'Pathloss',
          'Transport',
          'DuplicateData',
          'Discoverable',
          'Pattern'
        ]));

    await adapter.setDiscoveryFilter(
        uuids: [
          '00000001-0000-1000-8000-00805f9b34fb',
          '00000002-0000-1000-8000-00805f9b34fb'
        ],
        rssi: -99,
        pathloss: 42,
        transport: 'le',
        duplicateData: false,
        discoverable: true,
        pattern: 'foo');
    expect(
        a.discoveryFilter,
        equals({
          'UUIDs': DBusArray(DBusSignature('s'), [
            DBusString('00000001-0000-1000-8000-00805f9b34fb'),
            DBusString('00000002-0000-1000-8000-00805f9b34fb')
          ]),
          'RSSI': DBusInt16(-99),
          'Pathloss': DBusUint16(42),
          'Transport': DBusString('le'),
          'DuplicateData': DBusBoolean(false),
          'Discoverable': DBusBoolean(true),
          'Pattern': DBusString('foo')
        }));

    expect(a.discovering, isFalse);
    await adapter.startDiscovery();
    expect(a.discovering, isTrue);
    await adapter.stopDiscovery();
    expect(a.discovering, isFalse);
  });

  test('no devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    await bluez.addAdapter('hci0');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, isEmpty);
  });

  test('devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter(
      'hci0',
    );
    await bluez.addDevice(adapter, address: 'DE:71:CE:00:00:01');
    await bluez.addDevice(adapter, address: 'DE:71:CE:00:00:02');
    await bluez.addDevice(adapter, address: 'DE:71:CE:00:00:03');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, hasLength(3));
    expect(client.devices[0].address, equals('DE:71:CE:00:00:01'));
    expect(client.devices[1].address, equals('DE:71:CE:00:00:02'));
    expect(client.devices[2].address, equals('DE:71:CE:00:00:03'));
  });

  test('device added', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    var adapter = await bluez.addAdapter('hci0');

    client.deviceAdded.listen(expectAsync1((device) {
      expect(device.address, equals('DE:71:CE:00:00:01'));
    }));

    await bluez.addDevice(adapter, address: 'DE:71:CE:00:00:01');
  });

  test('device removed', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

    var adapter = await bluez.addAdapter('hci0');
    var device = await bluez.addDevice(adapter, address: 'DE:71:CE:00:00:01');

    client.deviceRemoved.listen(expectAsync1((device) {
      expect(device.address, equals('DE:71:CE:00:00:01'));
    }));

    await bluez.removeDevice(device);
  });

  test('remove device', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());

    var a = await bluez.addAdapter('hci0');
    await bluez.addDevice(a, address: 'DE:71:CE:00:00:01');
    await bluez.addDevice(a, address: 'DE:71:CE:00:00:02');
    await bluez.addDevice(a, address: 'DE:71:CE:00:00:03');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(bluez.devices, hasLength(3));
    var adapter = client.adapters[0];
    await adapter.removeDevice(client.devices[1]);
    expect(bluez.devices, hasLength(2));
    expect(bluez.devices[0].address, equals('DE:71:CE:00:00:01'));
    expect(bluez.devices[1].address, equals('DE:71:CE:00:00:03'));
  });

  test('device properties', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0', address: 'AD:A9:7E:F0:00:01');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01',
        addressType: 'public',
        alias: 'Test Device Alias',
        appearance: 0x03C1,
        blocked: true,
        class_: 999,
        connected: true,
        icon: 'keyboard',
        legacyPairing: true,
        manufacturerData: {
          0: DBusArray.byte([1, 2, 3]),
          1: DBusArray.byte([4, 5, 6])
        },
        modalias: 'usb:device1',
        name: 'Test Device',
        paired: true,
        rssi: 123,
        serviceData: {
          '00000001-0000-1000-8000-00805f9b34fb': DBusArray.byte([1, 2, 3]),
          '00000002-0000-1000-8000-00805f9b34fb': DBusArray.byte([4, 5, 6])
        },
        servicesResolved: true,
        trusted: true,
        txPower: 456,
        uuids: [
          '00000001-0000-1000-8000-00805f9b34fb',
          '00000002-0000-1000-8000-00805f9b34fb'
        ],
        wakeAllowed: true);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.adapter.address, equals('AD:A9:7E:F0:00:01'));
    expect(device.address, equals('DE:71:CE:00:00:01'));
    expect(device.addressType, equals(BlueZAddressType.public));
    expect(device.alias, equals('Test Device Alias'));
    expect(device.appearance, equals(0x03C1));
    expect(device.blocked, isTrue);
    expect(device.connected, isTrue);
    expect(device.deviceClass, equals(999));
    expect(device.icon, equals('keyboard'));
    expect(device.legacyPairing, isTrue);
    expect(
        device.manufacturerData,
        equals({
          BlueZManufacturerId(0): [1, 2, 3],
          BlueZManufacturerId(1): [4, 5, 6]
        }));
    expect(device.modalias, equals('usb:device1'));
    expect(device.name, equals('Test Device'));
    expect(device.paired, isTrue);
    expect(device.rssi, equals(123));
    expect(
        device.serviceData,
        equals({
          BlueZUUID.fromString('00000001-0000-1000-8000-00805f9b34fb'): [
            1,
            2,
            3
          ],
          BlueZUUID.fromString('00000002-0000-1000-8000-00805f9b34fb'): [
            4,
            5,
            6
          ]
        }));
    expect(device.servicesResolved, isTrue);
    expect(device.trusted, isTrue);
    expect(device.txPower, equals(456));
    expect(device.uuids, equals([BlueZUUID.short(1), BlueZUUID.short(2)]));
    expect(device.wakeAllowed, isTrue);
  });

  test('device set properties', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    var d = await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01',
        alias: 'Original Alias',
        blocked: false,
        trusted: false,
        wakeAllowed: false);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, hasLength(1));
    var device = client.devices[0];

    expect(d.alias, equals('Original Alias'));
    await device.setAlias('New Alias');
    expect(d.alias, equals('New Alias'));

    expect(d.blocked, isFalse);
    await device.setBlocked(true);
    expect(d.blocked, isTrue);

    expect(d.trusted, isFalse);
    await device.setTrusted(true);
    expect(d.trusted, isTrue);

    expect(d.wakeAllowed, isFalse);
    await device.setWakeAllowed(true);
    expect(d.wakeAllowed, isTrue);
  });

  test('device connect', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var a = await bluez.addAdapter('hci0');
    await bluez.addDevice(a, address: 'DE:71:CE:00:00:01', connected: false);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.connected, isFalse);
    await device.connect();
    expect(device.connected, isTrue);
  });

  test('device disconnect', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var a = await bluez.addAdapter('hci0');
    await bluez.addDevice(a, address: 'DE:71:CE:00:00:01', connected: true);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.connected, isTrue);
    await device.disconnect();
    expect(device.connected, isFalse);
  });

  test('device properties changed', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var a = await bluez.addAdapter('hci0');
    var d = await bluez.addDevice(a,
        address: 'DE:71:CE:00:00:01', connected: false, rssi: 123);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    device.propertiesChanged.listen(expectAsync1((properties) {
      expect(properties, equals(['Connected', 'RSSI']));
      expect(device.connected, isTrue);
      expect(device.rssi, equals(124));
    }));

    await d.changeProperties(connected: true, rssi: 124);
  });

  test('no gatt services', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01', servicesResolved: true);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, hasLength(1));
    var device = client.devices[0];

    expect(device.gattServices, isEmpty);
  });

  test('gatt services', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    var d = await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01', servicesResolved: true);
    await bluez.addService(d, 1, uuid: '00000001-0000-1000-8000-00805f9b34fb');
    await bluez.addService(d, 2,
        primary: true, uuid: '00000002-0000-1000-8000-00805f9b34fb');
    await bluez.addService(d, 3,
        primary: false, uuid: '00000003-0000-1000-8000-00805f9b34fb');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, hasLength(1));
    var device = client.devices[0];

    expect(device.gattServices, hasLength(3));
    expect(device.gattServices[0].uuid, equals(BlueZUUID.short(1)));
    expect(device.gattServices[1].uuid, equals(BlueZUUID.short(2)));
    expect(device.gattServices[1].primary, isTrue);
    expect(device.gattServices[2].uuid, equals(BlueZUUID.short(3)));
    expect(device.gattServices[2].primary, isFalse);
    expect(device.gattServices[2].characteristics, isEmpty);
  });

  test('gatt characteristics', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    var d = await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01', servicesResolved: true);
    var s = await bluez.addService(d, 1,
        uuid: '00000001-0000-1000-8000-00805f9b34fb');
    await bluez.addCharacteristic(s, 1,
        uuid: '0000000a-0000-1000-8000-00805f9b34fb');
    await bluez.addCharacteristic(s, 2,
        uuid: '0000000b-0000-1000-8000-00805f9b34fb');
    var c = await bluez.addCharacteristic(s, 3,
        flags: [
          'broadcast',
          'read',
          'write-without-response',
          'write',
          'notify',
          'indicate',
          'authenticated-signed-writes',
          'extended-properties',
          'reliable-write',
          'writable-auxiliaries',
          'encrypt-read',
          'encrypt-write',
          'encrypt-authenticated-read',
          'encrypt-authenticated-write',
          'secure-read',
          'secure-write',
          'authorize'
        ],
        value: [0xde, 0xad, 0xbe, 0xef],
        uuid: '0000000c-0000-1000-8000-00805f9b34fb');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.gattServices, hasLength(1));
    var service = device.gattServices[0];
    expect(service.characteristics, hasLength(3));
    expect(service.characteristics[0].uuid, equals(BlueZUUID.short(0xa)));
    expect(service.characteristics[1].uuid, equals(BlueZUUID.short(0xb)));
    expect(service.characteristics[2].uuid, equals(BlueZUUID.short(0xc)));
    expect(
        service.characteristics[2].flags,
        equals({
          BlueZGattCharacteristicFlag.broadcast,
          BlueZGattCharacteristicFlag.read,
          BlueZGattCharacteristicFlag.writeWithoutResponse,
          BlueZGattCharacteristicFlag.write,
          BlueZGattCharacteristicFlag.notify,
          BlueZGattCharacteristicFlag.indicate,
          BlueZGattCharacteristicFlag.authenticatedSignedWrites,
          BlueZGattCharacteristicFlag.extendedProperties,
          BlueZGattCharacteristicFlag.reliableWrite,
          BlueZGattCharacteristicFlag.writableAuxiliaries,
          BlueZGattCharacteristicFlag.encryptRead,
          BlueZGattCharacteristicFlag.encryptWrite,
          BlueZGattCharacteristicFlag.encryptAuthenticatedRead,
          BlueZGattCharacteristicFlag.encryptAuthenticatedWrite,
          BlueZGattCharacteristicFlag.secureRead,
          BlueZGattCharacteristicFlag.secureWrite,
          BlueZGattCharacteristicFlag.authorize
        }));
    expect(service.characteristics[2].value, equals([0xde, 0xad, 0xbe, 0xef]));
    expect(service.characteristics[2].descriptors, isEmpty);

    var data = await service.characteristics[2].readValue();
    expect(data, equals([0xde, 0xad, 0xbe, 0xef]));
    data = await service.characteristics[2].readValue(offset: 2);
    expect(data, equals([0xbe, 0xef]));

    await service.characteristics[2].writeValue([0xaa]);
    expect(c.value, equals([0xaa, 0xad, 0xbe, 0xef]));
    await service.characteristics[2].writeValue([0xbb, 0xcc], offset: 1);
    expect(c.value, equals([0xaa, 0xbb, 0xcc, 0xef]));
  });

  test('gatt descriptors', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    var d = await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01', servicesResolved: true);
    var s = await bluez.addService(d, 1,
        uuid: '00000001-0000-1000-8000-00805f9b34fb');
    var c = await bluez.addCharacteristic(s, 1,
        uuid: '00000002-0000-1000-8000-00805f9b34fb');
    await bluez.addDescriptor(c, 1,
        uuid: '0000000a-0000-1000-8000-00805f9b34fb');
    await bluez.addDescriptor(c, 2,
        uuid: '0000000b-0000-1000-8000-00805f9b34fb');
    var descriptor = await bluez.addDescriptor(c, 3,
        value: [0xde, 0xad, 0xbe, 0xef],
        uuid: '0000000c-0000-1000-8000-00805f9b34fb');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.gattServices, hasLength(1));
    var service = device.gattServices[0];
    expect(service.characteristics, hasLength(1));
    var characteristic = service.characteristics[0];
    expect(characteristic.descriptors, hasLength(3));
    expect(characteristic.descriptors[0].uuid, equals(BlueZUUID.short(0xa)));
    expect(characteristic.descriptors[1].uuid, equals(BlueZUUID.short(0xb)));
    expect(characteristic.descriptors[2].uuid, equals(BlueZUUID.short(0xc)));
    expect(
        characteristic.descriptors[2].value, equals([0xde, 0xad, 0xbe, 0xef]));

    var data = await characteristic.descriptors[2].readValue();
    expect(data, equals([0xde, 0xad, 0xbe, 0xef]));
    data = await characteristic.descriptors[2].readValue(offset: 2);
    expect(data, equals([0xbe, 0xef]));

    await characteristic.descriptors[2].writeValue([0xaa]);
    expect(descriptor.value, equals([0xaa, 0xad, 0xbe, 0xef]));
    await characteristic.descriptors[2].writeValue([0xbb, 0xcc], offset: 1);
    expect(descriptor.value, equals([0xaa, 0xbb, 0xcc, 0xef]));
  });

  test('pair - no auth', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01', authType: MockBlueZDeviceAuthType.none);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    expect(client.devices, hasLength(1));
    var device = client.devices[0];

    expect(device.paired, isFalse);
    await device.pair();
    expect(device.paired, isTrue);
  });

  test('pair - auth confirm', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01',
        authType: MockBlueZDeviceAuthType.confirm);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    var agent = TestAgent();
    await client.registerAgent(agent);

    expect(client.devices, hasLength(1));
    var device = client.devices[0];

    expect(device.paired, isFalse);
    await device.pair();
    expect(device.paired, isTrue);
    expect(agent.authRequested, isTrue);
  });

  test('pair - auth confirm pin code', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01',
        authType: MockBlueZDeviceAuthType.confirmPinCode,
        pinCode: 'abc123');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    var agent = TestAgent();
    await client.registerAgent(agent);

    expect(client.devices, hasLength(1));
    var device = client.devices[0];

    expect(device.paired, isFalse);
    await device.pair();
    expect(device.paired, isTrue);
    expect(agent.lastPinCode, equals('abc123'));
  });

  test('pair - auth request pin code', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01',
        authType: MockBlueZDeviceAuthType.requestPinCode,
        pinCode: 'abc123');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    var agent = TestAgent(pinCode: 'abc123');
    await client.registerAgent(agent);

    expect(client.devices, hasLength(1));
    var device = client.devices[0];

    expect(device.paired, isFalse);
    await device.pair();
    expect(device.paired, isTrue);
    expect(agent.pinCodeRequested, isTrue);
  });

  test('pair - auth confirm passkey', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01',
        authType: MockBlueZDeviceAuthType.confirmPasskey,
        passkey: 123456);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    var agent = TestAgent();
    await client.registerAgent(agent);

    expect(client.devices, hasLength(1));
    var device = client.devices[0];

    expect(device.paired, isFalse);
    await device.pair();
    expect(device.paired, isTrue);
    expect(agent.lastPasskey, equals(123456));
  });

  test('pair - auth request passkey', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01',
        authType: MockBlueZDeviceAuthType.requestPasskey,
        passkey: 123456);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    var agent = TestAgent(passkey: 123456);
    await client.registerAgent(agent);

    expect(client.devices, hasLength(1));
    var device = client.devices[0];

    expect(device.paired, isFalse);
    await device.pair();
    expect(device.paired, isTrue);
    expect(agent.passkeyRequested, isTrue);
  });

  test('pair - default agent', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01',
        authType: MockBlueZDeviceAuthType.confirm);
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:02',
        authType: MockBlueZDeviceAuthType.confirmPinCode,
        pinCode: 'abc123');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:03',
        authType: MockBlueZDeviceAuthType.requestPinCode,
        pinCode: 'abc123');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:04',
        authType: MockBlueZDeviceAuthType.confirmPasskey,
        passkey: 123456);
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:05',
        authType: MockBlueZDeviceAuthType.requestPasskey,
        passkey: 123456);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    var agent = TestEmptyAgent();
    await client.registerAgent(agent);

    // Test all pairing that requires interaction fails without an agent that doesn't implement the required methods.
    expect(() => client.devices[0].pair(), throwsException);
    expect(() => client.devices[1].pair(), throwsException);
    expect(() => client.devices[2].pair(), throwsException);
    expect(() => client.devices[3].pair(), throwsException);
    expect(() => client.devices[4].pair(), throwsException);
  });

  test('pair - no agent', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01',
        authType: MockBlueZDeviceAuthType.confirm);
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:02',
        authType: MockBlueZDeviceAuthType.confirmPinCode,
        pinCode: 'abc123');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:03',
        authType: MockBlueZDeviceAuthType.requestPinCode,
        pinCode: 'abc123');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:04',
        authType: MockBlueZDeviceAuthType.confirmPasskey,
        passkey: 123456);
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:05',
        authType: MockBlueZDeviceAuthType.requestPasskey,
        passkey: 123456);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    // Test all pairing that requires interaction fails without an agent.
    expect(() => client.devices[0].pair(), throwsException);
    expect(() => client.devices[1].pair(), throwsException);
    expect(() => client.devices[2].pair(), throwsException);
    expect(() => client.devices[3].pair(), throwsException);
    expect(() => client.devices[4].pair(), throwsException);
  });

  test('pair - default agent', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    var agent = TestAgent();
    await client.registerAgent(agent);
    expect(bluez.agentIsDefault, isFalse);
    await client.requestDefaultAgent();
    expect(bluez.agentIsDefault, isTrue);
  });

  test('pair - agent path', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    var agent = TestAgent();
    await client.registerAgent(agent, path: DBusObjectPath('/com/example/TestAgent'));
    expect(bluez.agentPath, equals(DBusObjectPath('/com/example/TestAgent')));
  });

  test('pair - unregister agent', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));
    addTearDown(() async => await server.close());

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    addTearDown(() async => await bluez.close());

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();
    addTearDown(() async => await client.close());

    var agent = TestAgent();
    expect(bluez.agentAddress, isNull);
    await client.registerAgent(agent);
    expect(bluez.agentAddress, isNotNull);
    await client.unregisterAgent();
    expect(bluez.agentAddress, isNull);
  });
}
