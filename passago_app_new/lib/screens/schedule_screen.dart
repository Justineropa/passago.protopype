import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Screen 3 of 6: Schedule Selection (AM or PM shift) and the daily quota.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const _minQuota = 1;
  static const _maxQuota = 99;

  late Shift _selected;
  int _quota = 10;

  @override
  void initState() {
    super.initState();
    // Pre-select the shift that is open right now.
    _selected = _isOpen(Shift.am) ? Shift.am : Shift.pm;
  }

  bool _isOpen(Shift shift) {
    final hour = DateTime.now().hour;
    return hour >= shift.startHour && hour < shift.endHour;
  }

  void _cancel() {
    AppScope.of(context).signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _start() {
    AppScope.of(context).startShift(_selected, _quota);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: pgAppBar(title: 'Schedule selection', onBack: _cancel),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                children: [
                  Entrance(
                    delayMs: 40,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PgTag('Shift setup'),
                        const SizedBox(height: 10),
                        Text(
                          '${greeting(DateTime.now())}, ${state.driverName}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: PG.plum,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Choose your shift and set your quota for today.',
                          style: TextStyle(
                              fontSize: 15, height: 1.4, color: PG.body),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Entrance(
                    delayMs: 100,
                    child: PgPanel(
                      padding: EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: PG.magenta),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Terminal',
                                    style: TextStyle(
                                        fontSize: 12, color: PG.muted)),
                                SizedBox(height: 2),
                                Text(
                                  MockData.terminalName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: PG.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Entrance(
                    delayMs: 150,
                    child: SectionLabel('Select your shift'),
                  ),
                  const SizedBox(height: 10),
                  Entrance(
                    delayMs: 200,
                    child: _ShiftCard(
                      shift: Shift.am,
                      open: _isOpen(Shift.am),
                      selected: _selected == Shift.am,
                      onTap: () => setState(() => _selected = Shift.am),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Entrance(
                    delayMs: 250,
                    child: _ShiftCard(
                      shift: Shift.pm,
                      open: _isOpen(Shift.pm),
                      selected: _selected == Shift.pm,
                      onTap: () => setState(() => _selected = Shift.pm),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Entrance(
                    delayMs: 300,
                    child: SectionLabel('Daily passenger quota'),
                  ),
                  const SizedBox(height: 10),
                  Entrance(
                    delayMs: 340,
                    child: _QuotaStepper(
                      value: _quota,
                      min: _minQuota,
                      max: _maxQuota,
                      onChanged: (v) => setState(() => _quota = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You can raise your quota during the shift, but not '
                    'lower it. Your shift ends when you reach it.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: PG.muted),
                  ),
                  const SizedBox(height: 18),
                  const Entrance(delayMs: 400, child: _PolicyBox()),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: PG.canvas,
                border: Border(top: BorderSide(color: PG.border)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PgButton(
                    label: 'Start ${_selected.label} shift',
                    trailingIcon: Icons.arrow_forward,
                    onPressed: _start,
                  ),
                  PgTextButton(label: 'Cancel and return to login', onPressed: _cancel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.shift,
    required this.open,
    required this.selected,
    required this.onTap,
  });

  final Shift shift;
  final bool open;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(PG.radius);
    return Material(
      color: selected ? PG.tint : PG.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? PG.magenta : PG.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? PG.magenta : PG.muted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${shift.label} shift',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: PG.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      shift.hours,
                      style: const TextStyle(fontSize: 14, color: PG.body),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PgTag(
                open ? 'Available' : 'Scheduled',
                background: open ? PG.magentaTint : PG.surface,
                color: open ? PG.magenta : PG.body,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuotaStepper extends StatelessWidget {
  const _QuotaStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget stepButton(IconData icon, String label, VoidCallback? onTap) {
      return SizedBox(
        width: 56,
        height: 56,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: PG.plum,
            side: BorderSide(color: onTap == null ? PG.borderSoft : PG.plum),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PG.radius),
            ),
          ),
          child: Icon(icon, semanticLabel: label),
        ),
      );
    }

    return PgPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          stepButton(
            Icons.remove,
            'Lower quota',
            value > min ? () => onChanged(value - 1) : null,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: PG.ink,
                    height: 1.1,
                  ),
                ),
                const Text(
                  'passengers',
                  style: TextStyle(fontSize: 13, color: PG.muted),
                ),
              ],
            ),
          ),
          stepButton(
            Icons.add,
            'Raise quota',
            value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _PolicyBox extends StatelessWidget {
  const _PolicyBox();

  @override
  Widget build(BuildContext context) {
    return const PgPanel(
      color: PG.tint,
      borderColor: PG.borderSoft,
      padding: EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 22, color: PG.magenta),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fair turn policy',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: PG.ink,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Passenger counts reset at the start of each shift. Drivers '
                  'with fewer passengers are prioritized within the same '
                  'shift.',
                  style: TextStyle(fontSize: 13, height: 1.4, color: PG.body),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
