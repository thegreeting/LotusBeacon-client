import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/usecase/bluetooth_provider.dart';
import 'package:lotusbeacon/usecase/rpid_provider.dart';

class PeepingPhysicalHandshake extends ConsumerWidget {
  const PeepingPhysicalHandshake({super.key});

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
                  return ListTile(
                    title: Text('RPID: ${proximity.rpid}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EventID: ${proximity.eventId}'),
                        Text('UserIndex: ${proximity.userIndex}'),
                        Text('Distance: ${proximity.distance}'),
                        Text('RSSI: ${proximity.rssi}'),
                        Text('Last detected: ${proximity.lastDetectedAt}'),
                      ],
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
