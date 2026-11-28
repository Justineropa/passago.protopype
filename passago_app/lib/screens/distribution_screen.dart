import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../logic/queue_logic.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Screen 5 of 6: Passenger Distribution.
///
/// Shows the terminal line in ARRIVAL order. Among the first three drivers,
/// the one with the fewest passengers is marked "Next". The app only shows
/// this. It cannot control who gets a passenger, especially passengers who
/// hail a tricycle on the road.
class DistributionScreen extends StatelessWidget {
  const DistributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final line = state.line;
    final next = state.nextInLine;
    final position = state.myPosition;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                MockData.terminalName,
                style: TextStyle(fontSize: 14, color: PG.muted),
              ),
            ),
            PgTag('Live queue'),
          ],
        ),
        const SizedBox(height: 12),
        PgPanel(
          color: PG.tint,
          borderColor: PG.borderSoft,
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 22, color: PG.magenta),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How the next driver is chosen',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: PG.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The line stays in arrival order. Only who goes next '
                      'changes. Among the first $queueWindow drivers, the one '
                      'with the fewest passengers goes next.',
                      style: const TextStyle(
                          fontSize: 13, height: 1.4, color: PG.body),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          position == null
              ? 'You are not in the queue. Join from the Dashboard.'
              : 'Your position: #$position of ${line.length}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: PG.ink,
          ),
        ),
        const SizedBox(height: 16),
        const SectionLabel('Terminal line'),
        const SizedBox(height: 10),
        if (line.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('The line is empty.',
                  style: TextStyle(color: PG.muted)),
            ),
          )
        else
          for (var i = 0; i < line.length; i++)
            _DriverRow(
              rank: i + 1,
              entry: line[i],
              isNext: next != null && next.id == line[i].id,
              eligible: i < queueWindow,
            ),
      ],
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({
    required this.rank,
    required this.entry,
    required this.isNext,
    required this.eligible,
  });

  final int rank;
  final QueueEntry entry;
  final bool isNext;
  final bool eligible;

  @override
  Widget build(BuildContext context) {
    final String tagText;
    if (isNext) {
      tagText = 'Next';
    } else if (eligible) {
      tagText = 'Eligible';
    } else {
      tagText = 'Waiting';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: entry.isMe ? PG.tint : PG.canvas,
        borderRadius: BorderRadius.circular(PG.radius),
        border: Border.all(
          color: entry.isMe ? PG.plum : PG.border,
          width: entry.isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: PG.muted,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.isMe ? '${entry.name} (You)' : entry.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: PG.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Body ${entry.bodyNo} • ${entry.passengers} passengers',
                  style: const TextStyle(fontSize: 12, color: PG.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PgTag(
            tagText,
            background: isNext ? PG.magentaTint : PG.surface,
            color: isNext ? PG.magenta : PG.body,
          ),
        ],
      ),
    );
  }
}
