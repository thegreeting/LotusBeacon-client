import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/application/fixture/user_fixture.dart';
import 'package:lotusbeacon/domain/physical_proximity.dart';
import 'package:lotusbeacon/usecase/bluetooth_provider.dart';
import 'package:lotusbeacon/usecase/rpid_provider.dart';

class PeepingPhysicalHandshake extends ConsumerStatefulWidget {
  const PeepingPhysicalHandshake({super.key});

  @override
  ConsumerState<PeepingPhysicalHandshake> createState() => _PeepingPhysicalHandshakeState();
}

class _PeepingPhysicalHandshakeState extends ConsumerState<PeepingPhysicalHandshake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

  Widget _buildScanningIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final scale = 0.5 + (0.5 * (_controller.value + index / 3) % 1);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 150 - (index * 40),
                        height: 150 - (index * 40),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.6 - (index * 0.1) * (2 - scale)),
                          border: Border.all(color: Colors.blue.withOpacity(0.5)),
                        ),
                      ),
                    );
                  },
                );
              }).reversed,
              RotationTransition(
                turns: _controller,
                child: const Icon(
                  Icons.bluetooth_searching,
                  size: 48,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Scanning for nearby devices...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Make sure Bluetooth is enabled\nand you are close to other devices',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProximityIndicator(EstimatedDistance distance) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.5 + (0.5 * _controller.value);
        return Container(
          width: 8,
          height: 64,
          decoration: BoxDecoration(
            color: _getProximityColor(distance).withOpacity(opacity),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: _getProximityColor(distance).withOpacity(0.3),
                blurRadius: 4 + (4 * _controller.value),
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  final fixtureUser = UserFixture.findUserByEventUserIndex(int.parse(proximity.userIndex));
                  return AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: 1.0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: 1.0,
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              _buildProximityIndicator(proximity.distance),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fixtureUser.userId,
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
                                    // Text('EventID: ${proximity.eventId}'),
                                    Text('EventUserIndex: ${proximity.userIndex}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => _buildScanningIndicator(),
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
