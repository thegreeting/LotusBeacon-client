import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lotusbeacon/usecase/event_provider.dart';
import 'package:lotusbeacon/usecase/me_and_participants_provider.dart';

class ParticipantsListView extends ConsumerWidget {
  const ParticipantsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(selectedEventProvider);
    final mutualParticipantsAsync = ref.watch(mutualGreetingParticipantsOnEventProvider(event.id));
    final otherButNearbyParticipants = ref.watch(noneGreetingButNearByParticipantsOnEventProvider(event.id));
    final otherParticipants = ref.watch(noneGreetingParticipantsOnEventProvider(event.id));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 150,
            child: mutualParticipantsAsync.when(
              data: (participants) {
                if (participants.isEmpty) {
                  return const Center(
                    child: Text('No mutual participants'),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(participant.user.displayName),
                          Text(participant.user.bio),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          ),
        ),
        otherButNearbyParticipants.when(
          data: (participants) {
            if (participants.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Text('No participants'),
                ),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final participant = participants[index];
                  return ListTile(
                    title: Text(participant.user.displayName),
                    subtitle: Text(participant.user.bio),
                  );
                },
                childCount: participants.length,
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          error: (error, stack) => SliverToBoxAdapter(
            child: Center(
              child: Text(
                'Error: $error',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
