enum EstimatedDistance {
  immediate,
  near,
  far,
  unknown,
}

class PhysicalProximity {
  final String beaconId;
  final EstimatedDistance distance;
  final double estimatedDistance;
  final int rssi;
  final int txPower;
  final DateTime lastDetectedAt;

  PhysicalProximity({
    required this.beaconId,
    required this.distance,
    required this.estimatedDistance,
    required this.rssi,
    required this.txPower,
    required this.lastDetectedAt,
  });
}

class LotusBeaconPhysicalHandshake extends PhysicalProximity {
  final String eventId;
  final String userIndex;
  final String rpid;

  LotusBeaconPhysicalHandshake({
    required this.eventId,
    required this.userIndex,
    required this.rpid,
    required super.beaconId,
    required super.distance,
    required super.estimatedDistance,
    required super.rssi,
    required super.txPower,
    required super.lastDetectedAt,
  });
}
