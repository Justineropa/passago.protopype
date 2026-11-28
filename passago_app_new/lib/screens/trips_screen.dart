import 'package:flutter/material.dart';

import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

enum _Period { today, week, month }

/// Screen 6 of 6: Trip Records.
class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  _Period _period = _Period.today;
  Shift? _shift; // null = all shifts

  bool _inPeriod(TripRecord trip, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(
      trip.startedAt.year,
      trip.startedAt.month,
      trip.startedAt.day,
    );
    final daysAgo = today.difference(day).inDays;
    switch (_period) {
      case _Period.today:
        return daysAgo == 0;
      case _Period.week:
        return daysAgo < 7;
      case _Period.month:
        return daysAgo < 31;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final now = DateTime.now();

    final trips = state.trips
        .where((t) => _inPeriod(t, now))
        .where((t) => _shift == null || t.shift == _shift)
        .toList();
    final passengers = trips.fold<int>(0, (sum, t) => sum + t.passengers);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recorded passenger counts and trip history',
          style: TextStyle(fontSize: 13, color: PG.muted),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PgChip(
              label: 'Today',
              selected: _period == _Period.today,
              onTap: () => setState(() => _period = _Period.today),
            ),
            PgChip(
              label: 'This week',
              selected: _period == _Period.week,
              onTap: () => setState(() => _period = _Period.week),
            ),
            PgChip(
              label: 'This month',
              selected: _period == _Period.month,
              onTap: () => setState(() => _period = _Period.month),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PgChip(
              label: 'All shifts',
              selected: _shift == null,
              onTap: () => setState(() => _shift = null),
            ),
            PgChip(
              label: 'AM shift',
              selected: _shift == Shift.am,
              onTap: () => setState(() => _shift = Shift.am),
            ),
            PgChip(
              label: 'PM shift',
              selected: _shift == Shift.pm,
              onTap: () => setState(() => _shift = Shift.pm),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Stat(value: '${trips.length}', label: 'Completed trips'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stat(value: '$passengers', label: 'Passengers'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionLabel('Trips'),
        const SizedBox(height: 10),
        if (trips.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No trips recorded for this selection.',
                style: TextStyle(color: PG.muted),
              ),
            ),
          )
        else
          for (final trip in trips) _TripTile(trip: trip, now: now),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return PgPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: PG.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 13, color: PG.muted)),
        ],
      ),
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip, required this.now});

  final TripRecord trip;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final fromTerminal = trip.origin == TripOrigin.terminal;
    final plural = trip.passengers == 1 ? 'passenger' : 'passengers';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PG.canvas,
        borderRadius: BorderRadius.circular(PG.radius),
        border: Border.all(color: PG.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dayLabel(trip.startedAt, now)}, '
                  '${timeLabel(trip.startedAt)} • ${trip.shift.label}',
                  style: const TextStyle(fontSize: 12, color: PG.muted),
                ),
                const SizedBox(height: 3),
                Text(
                  '${trip.passengers} $plural • ${trip.minutes} min',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: PG.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PgTag(
            fromTerminal ? 'Started at terminal' : 'Started on street',
            background: fromTerminal ? PG.magentaTint : PG.surface,
            color: fromTerminal ? PG.magenta : PG.body,
          ),
        ],
      ),
    );
  }
}
