import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/usecase/auth_provider.dart';
import 'package:lotusbeacon/usecase/event_provider.dart';
import 'package:lotusbeacon/usecase/user_provider.dart';

class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedEvent = ref.watch(selectedEventProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final overrideEventIdController = TextEditingController(text: selectedEvent.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Current Selected Event Id: ${selectedEvent.id}'),
            Text(selectedEvent.name, style: Theme.of(context).textTheme.headlineMedium),
            Text(selectedEvent.description, style: Theme.of(context).textTheme.bodyLarge),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: overrideEventIdController,
                decoration: const InputDecoration(
                  labelText: 'Override Selected Event Id',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(overrideEeventIdIndexProvider.notifier).state = overrideEventIdController.text;
              },
              child: const Text('Set Override Event Id'),
            ),
            const Text('Changing eventId will get fresh tenant. Useful for testing.'),
            const SizedBox(height: 32),
            Text('Current User Id: $currentUserId'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final container = ProviderScope.containerOf(context);
                container.invalidate(selectedEventProvider);
                container.invalidate(currentUserProvider);
                // Show a snackbar to indicate reset
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All states have been reset')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset All States'),
            ),
          ],
        ),
      ),
    );
  }
}
