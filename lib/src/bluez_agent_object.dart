part of 'bluez_client.dart';

class _BlueZAgentObject extends DBusObject {
  final BlueZClient bluezClient;
  final BlueZAgent agent;

  _BlueZAgentObject(this.bluezClient, this.agent, DBusObjectPath path)
      : super(path);

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface != 'org.bluez.Agent1') {
      return DBusMethodErrorResponse.unknownInterface();
    }

    if (methodCall.name == 'Release') {
      if (methodCall.signature != DBusSignature('')) {
        return DBusMethodErrorResponse.invalidArgs();
      }
      await agent.release();
      return DBusMethodSuccessResponse();
    } else if (methodCall.name == 'RequestPinCode') {
      if (methodCall.signature != DBusSignature('o')) {
        return DBusMethodErrorResponse.invalidArgs();
      }
      return (await agent.requestPinCode(
              bluezClient._getDevice(methodCall.values[0].asObjectPath())!))
          .response;
    } else if (methodCall.name == 'DisplayPinCode') {
      if (methodCall.signature != DBusSignature('os')) {
        return DBusMethodErrorResponse.invalidArgs();
      }
      return (await agent.displayPinCode(
              bluezClient._getDevice(methodCall.values[0].asObjectPath())!,
              methodCall.values[1].asString()))
          .response;
    } else if (methodCall.name == 'RequestPasskey') {
      if (methodCall.signature != DBusSignature('o')) {
        return DBusMethodErrorResponse.invalidArgs();
      }
      return (await agent.requestPasskey(
              bluezClient._getDevice(methodCall.values[0].asObjectPath())!))
          .response;
    } else if (methodCall.name == 'DisplayPasskey') {
      if (methodCall.signature != DBusSignature('ouq')) {
        return DBusMethodErrorResponse.invalidArgs();
      }
      await agent.displayPasskey(
          bluezClient._getDevice(methodCall.values[0].asObjectPath())!,
          methodCall.values[1].asUint32(),
          methodCall.values[2].asUint16());
      return DBusMethodSuccessResponse();
    } else if (methodCall.name == 'RequestConfirmation') {
      if (methodCall.signature != DBusSignature('ou')) {
        return DBusMethodErrorResponse.invalidArgs();
      }
      return (await agent.requestConfirmation(
              bluezClient._getDevice(methodCall.values[0].asObjectPath())!,
              methodCall.values[1].asUint32()))
          .response;
    } else if (methodCall.name == 'RequestAuthorization') {
      if (methodCall.signature != DBusSignature('o')) {
        return DBusMethodErrorResponse.invalidArgs();
      }
      return (await agent.requestAuthorization(
              bluezClient._getDevice(methodCall.values[0].asObjectPath())!))
          .response;
    } else if (methodCall.name == 'AuthorizeService') {
      if (methodCall.signature != DBusSignature('os')) {
        return DBusMethodErrorResponse.invalidArgs();
      }
      return (await agent.authorizeService(
              bluezClient._getDevice(methodCall.values[0].asObjectPath())!,
              BlueZUUID.fromString(methodCall.values[1].asString())))
          .response;
    } else if (methodCall.name == 'Cancel') {
      if (methodCall.signature != DBusSignature('')) {
        return DBusMethodErrorResponse.invalidArgs();
      }
      await agent.cancel();
      return DBusMethodSuccessResponse();
    } else {
      return DBusMethodErrorResponse.unknownMethod();
    }
  }
}
