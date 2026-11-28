import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../data/mock_data.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

enum _QueueFilter { available, onTrip, all }

/// Screen 5 of 6: Passenger Distribution.
///
/// The queue is sorted by passengers served, fewest first, within the
/// driver's own shift. This prioritizes eligible, available drivers who have
/// received fewer passengers. It does not guarantee equal counts: passengers
/// who hail a tricycle on the road are outside the app's control.
class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  _QueueFilter _filter = _QueueFilter.available;

  static const _offerWindow = Duration(seconds: 90);
  Timer? _ticker;
  DateTime _offerShownAt = DateTime.now();
  TripOffer? _lastSeenOffer;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration _remaining(TripOffer offer) {
    // Restart the countdown when a different offer appears.
    if (!identical(offer, _lastSeenOffer)) {
      _lastSeenOffer = offer;
      _offerShownAt = DateTime.now();
    }
    final left = _offerWindow - DateTime.now().difference(_offerShownAt);
    return left.isNegative ? Duration.zero : left;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final offer = state.offer;

    final queue = state.queue;
    final availableCount =
        queue.where((d) => d.status == DriverStatus.available).length;
    final onTripCount =
        queue.where((d) => d.status == DriverStatus.onTrip).length;

    final shown = switch (_filter) {
      _QueueFilter.available =>
        queue.where((d) => d.status == DriverStatus.available).toList(),
      _QueueFilter.onTrip =>
        queue.where((d) => d.status == DriverStatus.onTrip).toList(),
      _QueueFilter.all => queue,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${MockData.terminalName} • ${state.shift.label} live queue',
          style: const TextStyle(fontSize: 13, color: PG.muted),
        ),
        const SizedBox(height: 12),
        if (offer != null) ...[
          _OfferCard(
            offer: offer,
            remaining: _remaining(offer),
            nextDriver: state.nextDriverAfterMe,
            onAccept: () {
              state.acceptOffer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Trip accepted. Your status is now On trip.')),
              );
            },
            onDecline: state.declineOffer,
          ),
          const SizedBox(height: 20),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            SectionLabel('TODA dispatch queue'),
            PgPill('Fewest passengers first'),
          ],
        ),
        const SizedBox(height: 10),
        _FilterTabs(
          value: _filter,
          availableCount: availableCount,
          onTripCount: onTripCount,
          allCount: queue.length,
          onChanged: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: 10),
        if (shown.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('No drivers in this list.',
                  style: TextStyle(color: PG.muted)),
            ),
          )
        else
          for (var i = 0; i < shown.length; i++)
            _DriverRow(
              rank: i + 1,
              driver: shown[i],
              isMe: shown[i].bodyNo == state.driverBodyNo,
              isNext: _filter == _QueueFilter.available && i == 0,
            ),
        const SizedBox(height: 20),
        const SectionLabel('Terminal demand'),
        const SizedBox(height: 10),
        for (final area in MockData.demand) _DemandRow(area: area),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.remaining,
    required this.nextDriver,
    required this.onAccept,
    required this.onDecline,
  });

  final TripOffer offer;
  final Duration remaining;
  final QueueDriver? nextDriver;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  String get _countdown {
    final m = remaining.inMinutes.toString().padLeft(2, '0');
    final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final expired = remaining == Duration.zero;

    Widget fact(String label, String value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: PG.muted)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        );

    return PgCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alt_route, size: 18, color: PG.magenta),
              const SizedBox(width: 6),
              const Expanded(child: SectionLabel('New assignment')),
              Icon(Icons.timer_outlined,
                  size: 16, color: expired ? PG.muted : PG.magenta),
              const SizedBox(width: 4),
              Text(
                expired ? 'Expired' : _countdown,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: expired ? PG.muted : PG.magenta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(offer.destination,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              fact('Passengers', '${offer.passengers}'),
              fact('Bay', offer.bay),
              fact('Distance', '${offer.distanceKm} km'),
              fact('Est. fare', '₱${offer.fare}.00'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            nextDriver == null
                ? 'If declined or expired, this trip is offered to the next driver.'
                : 'If declined or expired, this trip passes automatically to '
                    '${nextDriver!.name} (#${nextDriver!.bodyNo}).',
            style: const TextStyle(
                fontSize: 12, height: 1.4, color: PG.secondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PgButton(
                  label: 'Decline',
                  outlined: true,
                  height: 48,
                  onPressed: expired ? null : onDecline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: PgButton(
                  label: 'Accept trip',
                  icon: Icons.check_circle_outline,
                  height: 48,
                  onPressed: expired ? null : onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.value,
    required this.availableCount,
    required this.onTripCount,
    required this.allCount,
    required this.onChanged,
  });

  final _QueueFilter value;
  final int availableCount;
  final int onTripCount;
  final int allCount;
  final ValueChanged<_QueueFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      (_QueueFilter.available, 'Available ($availableCount)'),
      (_QueueFilter.onTrip, 'On trip ($onTripCount)'),
      (_QueueFilter.all, 'All ($allCount)'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PG.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(item.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.$1 == value ? PG.plum : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    item.$2,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: item.$1 == value ? Colors.white : PG.secondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({
    required this.rank,
    required this.driver,
    required this.isMe,
    required this.isNext,
  });

  final int rank;
  final QueueDriver driver;
  final bool isMe;
  final bool isNext;

  String get _statusText {
    switch (driver.status) {
      case DriverStatus.available:
        return isNext ? 'Next in line' : 'Wait ~${driver.waitMinutes}m';
      case DriverStatus.onTrip:
        return 'On trip';
      case DriverStatus.onBreak:
        return 'On break';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? PG.tint : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? PG.plum : PG.border,
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${rank.toString().padLeft(2, '0')}',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: PG.muted),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? '${driver.name} (YOU)' : driver.name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Body ${driver.bodyNo} • ${driver.passengers} pax served today',
                  style: const TextStyle(fontSize: 12, color: PG.secondary),
                ),
              ],
            ),
          ),
          PgPill(
            _statusText,
            background: isNext ? PG.magentaTint : PG.surface,
            color: isNext ? PG.magenta : PG.body,
          ),
        ],
      ),
    );
  }
}

class _DemandRow extends StatelessWidget {
  const _DemandRow({required this.area});

  final DemandArea area;

  @override
  Widget build(BuildContext context) {
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
          const Icon(Icons.location_on_outlined, color: PG.magenta),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(area.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('${area.bays} • ~${area.waitMinutes} min wait',
                    style: const TextStyle(fontSize: 12, color: PG.secondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${area.waiting} waiting',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(area.level,
                  style: const TextStyle(fontSize: 12, color: PG.muted)),
            ],
          ),
        ],
      ),
    );
  }
}
