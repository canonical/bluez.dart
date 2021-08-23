import 'package:bluez/bluez.dart';

void main() async {
  var client = BlueZClient();
  await client.connect();

  client.adapterAdded.listen((adapter) => onAdapterAdded(adapter));
  client.adapterRemoved.listen((adapter) => onAdapterRemoved(adapter));
  for (var adapter in client.adapters) {
    onAdapterAdded(adapter);
  }
  client.deviceAdded.listen((device) => onDeviceAdded(device));
  client.deviceRemoved.listen((device) => onDeviceRemoved(device));
  for (var device in client.devices) {
    onDeviceAdded(device);
  }
}

void onAdapterAdded(BlueZAdapter adapter) {
  print('Adapter [${adapter.address}] ${_getAdapterProperties(adapter, [
        'Alias',
        'Class',
        'Discoverable',
        'Discovering',
        'Pairable',
        'Powered',
        'UUIDs'
      ])}');
  adapter.propertiesChanged
      .listen((properties) => onAdapterPropertiesChanged(adapter, properties));
}

void onAdapterPropertiesChanged(BlueZAdapter adapter, List<String> properties) {
  print(
      'Adapter [${adapter.address}] ${_getAdapterProperties(adapter, properties)}');
}

void onAdapterRemoved(BlueZAdapter adapter) {
  print('Adapter [${adapter.address}] (removed)');
}

String _getAdapterProperties(BlueZAdapter adapter, List<String> properties) {
  return properties
      .map((property) => '$property=${_getAdapterProperty(adapter, property)}')
      .join(', ');
}

String _getAdapterProperty(BlueZAdapter adapter, String property) {
  switch (property) {
    case 'Alias':
      return adapter.alias;
    case 'Class':
      return adapter.deviceClass.toString();
    case 'Discovering':
      return adapter.discovering.toString();
    case 'Discoverable':
      return adapter.discoverable.toString();
    case 'Pairable':
      return adapter.pairable.toString();
    case 'Powered':
      return adapter.powered.toString();
    case 'UUIDs':
      return adapter.uuids.join(',');
    default:
      return '?';
  }
}

void onDeviceAdded(BlueZDevice device) {
  print('Device [${device.address}] ${_getDeviceProperties(device, [
        'Alias',
        'Connected',
        'Name',
        'RSSI'
      ])}');
  device.propertiesChanged
      .listen((properties) => onDevicePropertiesChanged(device, properties));
}

void onDevicePropertiesChanged(BlueZDevice device, List<String> properties) {
  print(
      'Device [${device.address}] ${_getDeviceProperties(device, properties)}');
}

void onDeviceRemoved(BlueZDevice device) {
  print('Device [${device.address}] (removed)');
}

String _getDeviceProperties(BlueZDevice device, List<String> properties) {
  return properties
      .map((property) => '$property=${_getDeviceProperty(device, property)}')
      .join(', ');
}

String _getDeviceProperty(BlueZDevice device, String property) {
  switch (property) {
    case 'Alias':
      return device.alias;
    case 'Connected':
      return device.connected.toString();
    case 'Name':
      return device.name;
    case 'RSSI':
      return device.rssi.toString();
    default:
      return '?';
  }
}
