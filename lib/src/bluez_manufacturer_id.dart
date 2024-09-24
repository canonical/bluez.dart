/// Bluetooth manufacturer Id.
class BlueZManufacturerId {
  final int id;

  const BlueZManufacturerId(this.id);

  @override
  String toString() => "BlueZManufacturerId('$id')";

  @override
  bool operator ==(other) => other is BlueZManufacturerId && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
