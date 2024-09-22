import 'package:bluez/bluez.dart';
import 'package:dbus/dbus.dart';

class BlueZAgentResponse {
  final DBusMethodResponse response;

  BlueZAgentResponse(this.response);

  factory BlueZAgentResponse.success() =>
      BlueZAgentResponse(DBusMethodSuccessResponse());

  factory BlueZAgentResponse.rejected() =>
      BlueZAgentResponse(DBusMethodErrorResponse('org.bluez.Error.Rejected'));

  factory BlueZAgentResponse.canceled() =>
      BlueZAgentResponse(DBusMethodErrorResponse('org.bluez.Error.Canceled'));
}

class BlueZAgentPinCodeResponse {
  final DBusMethodResponse response;

  BlueZAgentPinCodeResponse(this.response);

  factory BlueZAgentPinCodeResponse.success(String pinCode) =>
      BlueZAgentPinCodeResponse(
          DBusMethodSuccessResponse([DBusString(pinCode)]));

  factory BlueZAgentPinCodeResponse.rejected() => BlueZAgentPinCodeResponse(
      DBusMethodErrorResponse('org.bluez.Error.Rejected'));

  factory BlueZAgentPinCodeResponse.canceled() => BlueZAgentPinCodeResponse(
      DBusMethodErrorResponse('org.bluez.Error.Canceled'));
}

class BlueZAgentPasskeyResponse {
  final DBusMethodResponse response;

  BlueZAgentPasskeyResponse(this.response);

  factory BlueZAgentPasskeyResponse.success(int passkey) =>
      BlueZAgentPasskeyResponse(
          DBusMethodSuccessResponse([DBusUint32(passkey)]));

  factory BlueZAgentPasskeyResponse.rejected() => BlueZAgentPasskeyResponse(
      DBusMethodErrorResponse('org.bluez.Error.Rejected'));

  factory BlueZAgentPasskeyResponse.canceled() => BlueZAgentPasskeyResponse(
      DBusMethodErrorResponse('org.bluez.Error.Canceled'));
}

/// Agent object for a client to register.
abstract class BlueZAgent {
  /// Called when this agent is unregistered.
  Future<void> release() async {}

  /// Called when a PIN code is required for authentication with [device].
  /// Return [BlueZAgentPinCodeResponse.success] with the requested PIN code.
  Future<BlueZAgentPinCodeResponse> requestPinCode(BlueZDevice device) async {
    return BlueZAgentPinCodeResponse.rejected();
  }

  /// Called when [pinCode] is required to be displayed when authenticating with [device].
  /// Return [BlueZAgentResponse.success] is this PIN is confirmed as correct, and [BlueZAgentResponse.rejected] if it is not.
  Future<BlueZAgentResponse> displayPinCode(
      BlueZDevice device, String pinCode) async {
    return BlueZAgentResponse.rejected();
  }

  /// Called when a passkey is required for authentication with [device].
  /// Return [BlueZAgentPasskeyResponse.success] with the requested passkey.
  Future<BlueZAgentPasskeyResponse> requestPasskey(BlueZDevice device) async {
    return BlueZAgentPasskeyResponse.rejected();
  }

  /// Called when [passkey] is required to be displayed when authenticating with [device].
  Future<void> displayPasskey(
      BlueZDevice device, int passkey, int entered) async {}

  /// Called when a passkey is required to be confirmed when authenticating with [device].
  /// Return [BlueZAgentResponse.success] is this passkey is confirmed as correct, and [BlueZAgentResponse.rejected] if it is not.
  Future<BlueZAgentResponse> requestConfirmation(
      BlueZDevice device, int passkey) async {
    return BlueZAgentResponse.rejected();
  }

  /// Called when confirmation is required when authenticating with [device].
  /// Return [BlueZAgentResponse.success] is this authentication should occur, and [BlueZAgentResponse.rejected] if it should not.
  Future<BlueZAgentResponse> requestAuthorization(BlueZDevice device) async {
    return BlueZAgentResponse.rejected();
  }

  /// Called when confirmation is required when accessing the service [uuid] on [device].
  /// Return [BlueZAgentResponse.success] is this authorization should occur, and [BlueZAgentResponse.rejected] if it should not.
  Future<BlueZAgentResponse> authorizeService(
      BlueZDevice device, BlueZUUID uuid) async {
    return BlueZAgentResponse.rejected();
  }

  /// Called when a request is canceled due to lack of response from the agent.
  Future<void> cancel() async {}
}
