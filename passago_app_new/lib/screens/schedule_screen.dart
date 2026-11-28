import 'package:material_ui/material_ui.dart';

import '../data/mock_data.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'main_shell.dart';

/// Screen 3 of 6: Schedule Selection (AM or PM shift).
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Shift _selected;

  @override
  void initState() {
    super.initState();
    // Pre-select the shift that is open right now.
    final hour = DateTime.now().hour;
    _selected = (hour >= 5 && hour < 13) ? Shift.am : Shift.pm;
  }

  /// "Open now" while the shift hours are running, otherwise "Upcoming"/"Closed".
  String _statusFor(Shift shift) {
    final hour = DateTime.now().hour;
    final start = shift == Shift.am ? 5 : 13;
    final end = shift == Shift.am ? 13 : 21;
    if (hour >= start && hour < end) return 'Open now';
    return hour < start ? 'Upcoming' : 'Closed';
  }

  void _start() {
    final state = AppScope.of(context);
    state.startShift(_selected);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Schedule selection',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: PG.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  children: [
                    Entrance(
                      delayMs: 50,
                      child: Text(
                        longDate(DateTime.now()),
                        style: const TextStyle(fontSize: 13, color: PG.muted),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Entrance(
                      delayMs: 100,
                      child: Text(
                        'Select shift',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: PG.plum,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Entrance(
                      delayMs: 150,
                      child: Text(
                        'Choose your driving schedule for today to join the '
                        'terminal queue.',
                        style: TextStyle(
                            fontSize: 15, height: 1.4, color: PG.body),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Entrance(
                      delayMs: 200,
                      child: PgCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.storefront_outlined,
                                color: PG.magenta),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Terminal base',
                                    style: TextStyle(
                                        fontSize: 12, color: PG.muted),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    MockData.routeName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Changing the terminal is not available in this prototype yet.'),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                  foregroundColor: PG.magenta),
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Entrance(
                      delayMs: 250,
                      child: SectionLabel('Available schedules'),
                    ),
                    const SizedBox(height: 10),
                    Entrance(
                      delayMs: 300,
                      child: _ShiftCard(
                        title: 'AM shift (${Shift.am.hours})',
                        status: _statusFor(Shift.am),
                        drivers: '${MockData.driversPerShift[Shift.am]} active drivers',
                        selected: _selected == Shift.am,
                        onTap: () => setState(() => _selected = Shift.am),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Entrance(
                      delayMs: 360,
                      child: _ShiftCard(
                        title: 'PM shift (${Shift.pm.hours})',
                        status: _statusFor(Shift.pm),
                        drivers: '${MockData.driversPerShift[Shift.pm]} drivers ready',
                        selected: _selected == Shift.pm,
                        onTap: () => setState(() => _selected = Shift.pm),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Entrance(
                      delayMs: 420,
                      child: _PolicyBox(),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PgButton(
                      label: 'Start ${_selected.label} shift',
                      onPressed: _start,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You may adjust your shift up to 30 minutes before departure.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: PG.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.title,
    required this.status,
    required this.drivers,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String status;
  final String drivers;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? PG.tint : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? PG.plum : PG.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? PG.plum : PG.muted,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.group_outlined,
                              size: 16, color: PG.muted),
                          const SizedBox(width: 4),
                          Text(
                            drivers,
                            style: const TextStyle(
                                fontSize: 13, color: PG.secondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PgPill(
                  status,
                  background:
                      status == 'Open now' ? PG.magentaTint : PG.surface,
                  color: status == 'Open now' ? PG.magenta : PG.body,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicyBox extends StatelessWidget {
  const _PolicyBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PG.tint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PG.hairline),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.balance, size: 22, color: PG.magenta),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fair turn policy',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Passenger counts reset at shift start. Drivers with fewer '
                  'passengers are prioritized in the queue within the same '
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
