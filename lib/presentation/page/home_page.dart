import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/presentation/organism/peeping_physical_handshake.dart';
import 'package:lotusbeacon/presentation/page/setting_page.dart';
import 'package:lotusbeacon/usecase/rpid_provider.dart';

import '../../usecase/bluetooth_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index == 0) {
      _startBleServices();
    } else {
      _stopBleServices();
    }
  }

  Future<void> _startBleServices() async {
    ref.read(bleServiceFacadeProvider);
  }

  void _stopBleServices() {
    ref.invalidate(bleServiceFacadeProvider);
    ref.invalidate(rpidProvider);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Participants'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PeepingPhysicalHandshake(),
          //const ParticipantsListView(), // Replace with actual greetings data
          SettingPage(), // Placeholder for Settings content
        ],
      ),
    );
  }
}
