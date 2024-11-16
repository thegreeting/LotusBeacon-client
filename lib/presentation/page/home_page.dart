import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../usecase/bluetooth_provider.dart';
import '../../usecase/rpid_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    _startBleServices();
  }

  Future<void> _startBleServices() async {
    final service = ref.read(bleServiceProvider);
    final rpid = ref.read(rpidProvider);

    await service.startCycle(rpid);
  }

  @override
  void dispose() {
    final service = ref.read(bleServiceProvider);
    service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final proximityAsync = ref.watch(proximityStreamProvider);
    final rpidAsync = ref.watch(rollingRpidProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Proximity'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: rpidAsync.when(
              data: (rpid) => Text('My RPID: $rpid'),
              loading: () => const Text('Generating RPID...'),
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
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
