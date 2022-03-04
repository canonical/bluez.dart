import 'package:bluez/bluez.dart';

class MyAgent extends BlueZAgent {
  @override
  Future<BlueZAgentPinCodeResponse> requestPinCode(BlueZDevice device) async {
    return BlueZAgentPinCodeResponse.success('1234');
  }

  @override
  Future<BlueZAgentResponse> displayPinCode(
      BlueZDevice device, String pinCode) async {
    print('PinCode $pinCode');
    return BlueZAgentResponse.success();
  }

  @override
  Future<BlueZAgentPasskeyResponse> requestPasskey(BlueZDevice device) async {
    return BlueZAgentPasskeyResponse.success(1234);
  }

  @override
  Future<BlueZAgentResponse> displayPasskey(
      BlueZDevice device, int passkey, int entered) async {
    print('Passkey $passkey');
    return BlueZAgentResponse.success();
  }

  @override
  Future<BlueZAgentResponse> requestConfirmation(
      BlueZDevice device, int passkey) async {
    print('Confirmed with passkey $passkey');
    return BlueZAgentResponse.success();
  }
}

void main(List<String> args) async {
  if (args.length != 1) {
    print('Need device address to pair with');
    return;
  }
  var address = args[0];

  var client = BlueZClient();
  await client.connect();

  // Register agent to handle pairing requests.
  var agent = MyAgent();
  await client.registerAgent(agent);

  // Request that our agent is used.
  await client.requestDefaultAgent();

  var devices = client.devices.where((device) => device.address == address);
  if (devices.isEmpty) {
    print('Device $address not available');
    await client.close();
    return;
  }
  var device = devices.first;

  if (device.paired) {
    print('Device $address already paired');
    await client.close();
    return;
  }

  device.propertiesChanged.listen((properties) async {
    if (device.paired) {
      print('Device $address successfully paired');
      await client.close();
      return;
    }
  });
  await device.pair();
}
