/// Types of Bluetooth address.
enum BlueZAddressType { public, random }

/// Types of writes to a GATT characteristic.
enum BlueZGattCharacteristicWriteType { command, request, reliable }

/// Defines how a GATT characteristic value can be used.
enum BlueZGattCharacteristicFlag {
  broadcast,
  read,
  writeWithoutResponse,
  write,
  notify,
  indicate,
  authenticatedSignedWrites,
  extendedProperties,
  reliableWrite,
  writableAuxiliaries,
  encryptRead,
  encryptWrite,
  encryptAuthenticatedRead,
  encryptAuthenticatedWrite,
  secureRead,
  secureWrite,
  authorize,
}

/// The capability of an agent registered with [BlueZClient.registerAgent].
/// * [displayOnly] - can only display information from the device.
/// * [displayYesNo] - able to display information from the device and respond with yes/no answers.
/// * [keyboardOnly] - only able to respond with pin code / passcode information.
/// * [noInputNoOutput] - not able to display information or provide information to devices.
/// * [keyboardDisplay] - able to display information from the device and respond with ping code / passcode information.
enum BlueZAgentCapability {
  displayOnly,
  displayYesNo,
  keyboardOnly,
  noInputNoOutput,
  keyboardDisplay,
}

/// Type of advertisement.
enum BlueZAdvertisementType {
  broadcast,
  peripheral,
}
