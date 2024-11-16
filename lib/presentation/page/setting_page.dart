import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/usecase/auth_provider.dart';
import 'package:lotusbeacon/usecase/event_provider.dart';
import 'package:lotusbeacon/usecase/participants_provider.dart';
import 'package:lotusbeacon/usecase/user_provider.dart';

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(selectedEventProvider);
    final authStateAsync = ref.watch(authStateProvider);
    final currentEventUserIndex = ref.watch(currenEventUserIndexProvider);
    final hasSoftParticipatedOnEvent = ref.watch(hasSoftParticipatedOnEventProvider(event.id));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wallet Connect Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    authStateAsync.when(
                      data: (authState) => authState.userId != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Connected: ${authState.userId}'),
                                const SizedBox(height: 8),
                                Text('Event User Index: $currentEventUserIndex'),
                                ElevatedButton(
                                  onPressed: () => ref.read(authProvider.notifier).signOut(),
                                  child: const Text('Disconnect'),
                                ),
                              ],
                            )
                          : ElevatedButton(
                              onPressed: () => ref.read(authProvider.notifier).signInIfNeeded(),
                              child: const Text('Connect Wallet'),
                            ),
                      loading: () => const CircularProgressIndicator.adaptive(),
                      error: (error, _) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Event Registration (only shown when wallet is connected)
            authStateAsync.when(
              data: (authState) {
                final userId = authState.userId;
                if (userId == null) {
                  return const SizedBox.shrink();
                }
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Registration',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: hasSoftParticipatedOnEvent
                              ? null
                              : () async {
                                  await participateUserOnEventOrHardRegisterIfNeeded(
                                    eventId: event.id,
                                    userId: userId,
                                  );
                                },
                          child: Text(hasSoftParticipatedOnEvent ? 'Registered' : 'Register to Event'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, _) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
