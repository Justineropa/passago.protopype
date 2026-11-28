import 'package:material_ui/material_ui.dart';

import '../data/mock_data.dart';
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

  bool _inPeriod(TripRecord t) => switch (_period) {
        _Period.today => t.daysAgo == 0,
        _Period.week => t.daysAgo < 7,
        _Period.month => t.daysAgo < 31,
      };

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    final trips = state.allTrips
        .where(_inPeriod)
        .where((t) => _shift == null || t.shift == _shift)
        .toList();
    final completed = trips.where((t) => !t.cancelled).toList();

    final fares = completed.fold<int>(0, (sum, t) => sum + t.fare);
    final passengers = completed.fold<int>(0, (sum, t) => sum + t.passengers);

    // Group trips by how many days ago they happened.
    final days = trips.map((t) => t.daysAgo).toSet().toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Recorded passenger counts and trip history',
          style: TextStyle(fontSize: 13, color: PG.muted),
        ),
        const SizedBox(height: 12),
        _ChipRow<_Period>(
          options: const [
            (_Period.today, 'Today'),
            (_Period.week, 'This week'),
            (_Period.month, 'This month'),
          ],
          selected: _period,
          onSelected: (v) => setState(() => _period = v),
        ),
        const SizedBox(height: 8),
        _ChipRow<Shift?>(
          options: const [
            (null, 'All shifts'),
            (Shift.am, 'AM shift'),
            (Shift.pm, 'PM shift'),
          ],
          selected: _shift,
          onSelected: (v) => setState(() => _shift = v),
        ),
        const SizedBox(height: 16),
        PgCard(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _Stat(value: '₱$fares', label: 'Gross fares'),
                const VerticalDivider(width: 1, color: PG.hairline),
                _Stat(value: '$passengers pax', label: 'Passengers'),
                const VerticalDivider(width: 1, color: PG.hairline),
                _Stat(value: '${completed.length}', label: 'Completed trips'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
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
          for (final daysAgo in days) ...[
            _DayHeader(
              daysAgo: daysAgo,
              trips: trips.where((t) => t.daysAgo == daysAgo).toList(),
            ),
            for (final trip in trips.where((t) => t.daysAgo == daysAgo))
              _TripTile(trip: trip),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _ChipRow<T> extends StatelessWidget {
  const _ChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(option.$2),
            selected: option.$1 == selected,
            onSelected: (_) => onSelected(option.$1),
            showCheckmark: false,
            selectedColor: PG.plum,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: option.$1 == selected ? PG.plum : PG.borderStrong,
            ),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: option.$1 == selected ? Colors.white : PG.body,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: PG.muted)),
          ],
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.daysAgo, required this.trips});

  final int daysAgo;
  final List<TripRecord> trips;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    final heading =
        daysAgo == 0 ? 'Today, ${dayHeading(date)}' : dayHeading(date);
    final fares = trips.fold<int>(0, (sum, t) => sum + t.fare);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(heading,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700)),
          ),
          Text('${trips.length} logged • ₱$fares',
              style: const TextStyle(fontSize: 12, color: PG.muted)),
        ],
      ),
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({required this.trip});

  final TripRecord trip;

  @override
  Widget build(BuildContext context) {
    final cancelled = trip.cancelled;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PG.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.time} • ${trip.shift.label}',
                  style: const TextStyle(fontSize: 12, color: PG.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Terminal → ${trip.destination}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  cancelled
                      ? 'Cancelled by passenger'
                      : '${trip.passengers} pax • ${trip.distanceKm} km • '
                          'Turn #${trip.turnNo}',
                  style: const TextStyle(fontSize: 12, color: PG.secondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₱${trip.fare}.00',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: cancelled ? PG.muted : PG.ink,
                ),
              ),
              const SizedBox(height: 4),
              PgPill(
                cancelled ? 'VOID' : 'PAID',
                background: cancelled ? PG.surface : PG.magentaTint,
                color: cancelled ? PG.muted : PG.magenta,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
