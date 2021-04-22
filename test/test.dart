import 'dart:io';

import 'package:bluez/bluez.dart';
import 'package:dbus/dbus.dart';
import 'package:test/test.dart';

class MockBlueZObject extends DBusObject {
  MockBlueZObject(DBusObjectPath path) : super(path);
}

class MockBlueZManagerObject extends MockBlueZObject {
  MockBlueZManagerObject() : super(DBusObjectPath('/org/bluez'));
}

class MockBlueZAdapterObject extends MockBlueZObject {
  final String deviceName;

  final String address;
  final String addressType;
  final String alias;
  final int class_;
  final bool discoverable;
  final int discoverableTimeout;
  final bool discovering;
  final String modalias;
  final String name;
  final bool pairable;
  final int pairableTimeout;
  final bool powered;
  final List<String> roles;
  final List<String> uuids;

  MockBlueZAdapterObject(this.deviceName,
      {this.address = '',
      this.addressType = 'public',
      this.alias = '',
      this.class_ = 0,
      this.discoverable = false,
      this.discoverableTimeout = 0,
      this.discovering = false,
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
}

class MockBlueZDeviceObject extends MockBlueZObject {
  final MockBlueZAdapterObject adapter;

  final String address;
  final String addressType;
  final String alias;
  final int appearance;
  final bool blocked;
  final int class_;
  final bool connected;
  final String icon;
  final bool legacyPairing;
  final Map<int, DBusValue> manufacturerData;
  final String modalias;
  final String name;
  final bool paired;
  final int rssi;
  final Map<String, DBusValue> serviceData;
  final bool servicesResolved;
  final bool trusted;
  final int txPower;
  final bool wakeAllowed;
  final List<String> uuids;

  MockBlueZDeviceObject(this.adapter,
      {required this.address,
      this.addressType = 'public',
      this.alias = '',
      this.appearance = 0,
      this.blocked = false,
      this.class_ = 0,
      this.connected = false,
      this.icon = '',
      this.legacyPairing = false,
      this.manufacturerData = const {},
      this.modalias = '',
      this.name = '',
      this.paired = false,
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
  final List<int> value;
  final String uuid;

  MockBlueZGattCharacteristicObject(this.service, this.id,
      {this.flags = const [],
      this.notifyAcquired = false,
      this.notifying = false,
      this.writeAcquired = false,
      required this.uuid,
      this.value = const []})
      : super(DBusObjectPath(service.path.value +
            '/char' +
            id.toRadixString(16).padLeft(4, '0')));

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
}

class MockBlueZServer extends DBusClient {
  late final DBusObject root;

  MockBlueZServer(DBusAddress clientAddress) : super(clientAddress);

  Future<void> start() async {
    await requestName('org.bluez');
    root = DBusObject(DBusObjectPath('/'), isObjectManager: true);
    await registerObject(root);

    var manager = MockBlueZManagerObject();
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
      String modalias = '',
      String name = '',
      bool pairable = false,
      int pairableTimeout = 0,
      bool powered = true,
      List<String> roles = const [],
      List<String> uuids = const []}) async {
    var adapter = MockBlueZAdapterObject(deviceName,
        address: address,
        addressType: addressType,
        alias: alias,
        class_: class_,
        discoverable: discoverable,
        discoverableTimeout: discoverableTimeout,
        discovering: discovering,
        modalias: modalias,
        name: name,
        pairable: pairable,
        pairableTimeout: pairableTimeout,
        powered: powered,
        roles: roles,
        uuids: uuids);
    await registerObject(adapter);
    return adapter;
  }

  Future<void> removeAdapter(MockBlueZAdapterObject adapter) async {
    await unregisterObject(adapter);
  }

  Future<MockBlueZDeviceObject> addDevice(MockBlueZAdapterObject adapter,
      {required String address,
      String addressType = 'public',
      String alias = '',
      int appearance = 0,
      bool blocked = false,
      int class_ = 0,
      bool connected = false,
      String icon = '',
      bool legacyPairing = false,
      Map<int, DBusValue> manufacturerData = const {},
      String modalias = '',
      String name = '',
      bool paired = false,
      int rssi = 0,
      Map<String, DBusValue> serviceData = const {},
      bool servicesResolved = false,
      bool trusted = false,
      int txPower = 0,
      bool wakeAllowed = false,
      List<String> uuids = const []}) async {
    var device = MockBlueZDeviceObject(adapter,
        address: address,
        addressType: addressType,
        alias: alias,
        appearance: appearance,
        blocked: blocked,
        class_: class_,
        connected: connected,
        icon: icon,
        legacyPairing: legacyPairing,
        manufacturerData: manufacturerData,
        modalias: modalias,
        name: name,
        paired: paired,
        rssi: rssi,
        serviceData: serviceData,
        servicesResolved: servicesResolved,
        trusted: trusted,
        txPower: txPower,
        wakeAllowed: wakeAllowed,
        uuids: uuids);
    await registerObject(device);
    return device;
  }

  Future<void> removeDevice(MockBlueZDeviceObject adapter) async {
    await unregisterObject(adapter);
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

void main() {
  test('no adapters or devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.adapters, isEmpty);
    expect(client.devices, isEmpty);

    await client.close();
  });

  test('adapters', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    await bluez.addAdapter('hci0', address: 'AD:A9:7E:F0:00:01');
    await bluez.addAdapter('hci1', address: 'AD:A9:7E:F0:00:02');
    await bluez.addAdapter('hci2', address: 'AD:A9:7E:F0:00:03');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.adapters, hasLength(3));
    expect(client.adapters[0].address, equals('AD:A9:7E:F0:00:01'));
    expect(client.adapters[1].address, equals('AD:A9:7E:F0:00:02'));
    expect(client.adapters[2].address, equals('AD:A9:7E:F0:00:03'));

    await client.close();
  });

  test('adapter added', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

    client.adapterAdded.listen(expectAsync1((adapter) {
      expect(adapter.address, equals('AD:A9:7E:F0:00:01'));
    }));

    await bluez.addAdapter('hci0', address: 'AD:A9:7E:F0:00:01');
  });

  test('adapter removed', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

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

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    await bluez.addAdapter('hci0',
        address: 'AD:A9:7E:F0:00:01',
        alias: 'Test Adapter Alias',
        class_: 777,
        name: 'Test Adapter',
        modalias: 'usb:adapter1',
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

    expect(client.adapters, hasLength(1));
    var adapter = client.adapters[0];
    expect(adapter.address, equals('AD:A9:7E:F0:00:01'));
    expect(adapter.addressType, equals(BlueZAddressType.public));
    expect(adapter.alias, equals('Test Adapter Alias'));
    expect(adapter.deviceClass, equals(777));
    expect(adapter.modalias, equals('usb:adapter1'));
    expect(adapter.name, equals('Test Adapter'));
    expect(adapter.roles, equals(['role1', 'role2']));
    expect(adapter.uuids, equals([BlueZUUID.short(1), BlueZUUID.short(2)]));

    await client.close();
  });

  test('no devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    await bluez.addAdapter('hci0');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, isEmpty);

    await client.close();
  });

  test('devices', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter, address: 'DE:71:CE:00:00:01');
    await bluez.addDevice(adapter, address: 'DE:71:CE:00:00:02');
    await bluez.addDevice(adapter, address: 'DE:71:CE:00:00:03');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(3));
    expect(client.devices[0].address, equals('DE:71:CE:00:00:01'));
    expect(client.devices[1].address, equals('DE:71:CE:00:00:02'));
    expect(client.devices[2].address, equals('DE:71:CE:00:00:03'));

    await client.close();
  });

  test('device added', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

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

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

    var adapter = await bluez.addAdapter('hci0');
    var device = await bluez.addDevice(adapter, address: 'DE:71:CE:00:00:01');

    client.deviceRemoved.listen(expectAsync1((device) {
      expect(device.address, equals('DE:71:CE:00:00:01'));
    }));

    await bluez.removeDevice(device);
  });

  test('device properties', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01',
        alias: 'Test Device Alias',
        class_: 999,
        modalias: 'usb:device1',
        name: 'Test Device',
        rssi: 123,
        txPower: 456,
        uuids: [
          '00000001-0000-1000-8000-00805f9b34fb',
          '00000002-0000-1000-8000-00805f9b34fb'
        ]);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];
    expect(device.address, equals('DE:71:CE:00:00:01'));
    expect(device.addressType, equals(BlueZAddressType.public));
    expect(device.alias, equals('Test Device Alias'));
    expect(device.deviceClass, equals(999));
    expect(device.modalias, equals('usb:device1'));
    expect(device.name, equals('Test Device'));
    expect(device.rssi, equals(123));
    expect(device.txPower, equals(456));
    expect(device.uuids, equals([BlueZUUID.short(1), BlueZUUID.short(2)]));

    await client.close();
  });

  test('no gatt services', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    var adapter = await bluez.addAdapter('hci0');
    await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01', servicesResolved: true);

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

    expect(client.devices, hasLength(1));
    var device = client.devices[0];

    expect(device.gattServices, isEmpty);
  });

  test('gatt services', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
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

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
    var adapter = await bluez.addAdapter('hci0');
    var d = await bluez.addDevice(adapter,
        address: 'DE:71:CE:00:00:01', servicesResolved: true);
    var s = await bluez.addService(d, 1,
        uuid: '00000001-0000-1000-8000-00805f9b34fb');
    await bluez.addCharacteristic(s, 1,
        uuid: '0000000a-0000-1000-8000-00805f9b34fb');
    await bluez.addCharacteristic(s, 2,
        uuid: '0000000b-0000-1000-8000-00805f9b34fb');
    await bluez.addCharacteristic(s, 3,
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
  });

  test('gatt descriptors', () async {
    var server = DBusServer();
    var clientAddress =
        await server.listenAddress(DBusAddress.unix(dir: Directory.systemTemp));

    var bluez = MockBlueZServer(clientAddress);
    await bluez.start();
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
    await bluez.addDescriptor(c, 3,
        value: [0xde, 0xad, 0xbe, 0xef],
        uuid: '0000000c-0000-1000-8000-00805f9b34fb');

    var client = BlueZClient(bus: DBusClient(clientAddress));
    await client.connect();

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
  });
}
