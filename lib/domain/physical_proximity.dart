enum EstimatedDistance {
  immediate,
  near,
  far,
  unknown,
}

class PhysicalProximity {
  final String beaconId;
  final String rpid;
  final EstimatedDistance distance;
  final double estimatedDistance;
  final int rssi;
  final DateTime lastDetectedAt;

  PhysicalProximity({
    required this.beaconId,
    required this.rpid,
    required this.distance,
    required this.estimatedDistance,
    required this.rssi,
    required this.lastDetectedAt,
  });
}
