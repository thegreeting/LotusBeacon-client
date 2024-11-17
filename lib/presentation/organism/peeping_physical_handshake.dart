import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/domain/physical_proximity.dart';
import 'package:lotusbeacon/usecase/bluetooth_provider.dart';
import 'package:lotusbeacon/usecase/rpid_provider.dart';

class PeepingPhysicalHandshake extends ConsumerWidget {
  const PeepingPhysicalHandshake({super.key});

  Color _getProximityColor(EstimatedDistance distance) {
    if (distance == EstimatedDistance.immediate) return Colors.red;
    if (distance == EstimatedDistance.near) return Colors.orange;
    if (distance == EstimatedDistance.far) return Colors.yellow;
    return Colors.grey;
  }

  String _formatLastDetected(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}sec ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min ago';
    } else {
      return '${difference.inHours}hour ago';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proximityAsync = ref.watch(proximityStreamProvider);
    final rpidAsync = ref.watch(rpidProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: rpidAsync.when(
            data: (rpid) => Text('My RPID: $rpid'),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => Text('Error: $error'),
          ),
        ),
        Expanded(
          child: proximityAsync.when(
            data: (proximities) {
              if (proximities.isEmpty) {
                return const Center(
                  child: Text('No devices detected'),
                );
              }
              return ListView.builder(
                itemCount: proximities.length,
                itemBuilder: (context, index) {
                  final proximity = proximities[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 64,
                            decoration: BoxDecoration(
                              color: _getProximityColor(proximity.distance),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RPID: ${proximity.rpid}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.wifi_tethering,
                                      size: 16,
                                      color: _getProximityColor(proximity.distance),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${proximity.estimatedDistance.toStringAsFixed(1)}m'),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.access_time, size: 16),
                                    const SizedBox(width: 4),
                                    Text(_formatLastDetected(proximity.lastDetectedAt)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('EventID: ${proximity.eventId}'),
                                Text('UserIndex: ${proximity.userIndex}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
            error: (error, stack) {
              if (error is RegistrationRequiredException) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.app_registration,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Registration Required',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please register to the event first\nto start scanning for nearby devices.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return Center(
                child: Text('Error: $error'),
              );
            },
          ),
        ),
      ],
    );
  }
}
