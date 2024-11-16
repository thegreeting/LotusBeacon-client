import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../usecase/bluetooth_provider.dart';

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
    // just load the facade to start sensor services
    ref.read(bleServiceFacadeProvider);
  }

  @override
  void dispose() {
    final service = ref.read(bleServiceProvider);
    service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your "Trustless" Interactions at ETHGlobal'),
        leading: IconButton(
          icon: const Icon(Icons.bug_report),
          onPressed: () {
            Navigator.of(context).pushNamed('/debug');
          },
        ),
      ),
      body: Container(),
    );
  }
}
