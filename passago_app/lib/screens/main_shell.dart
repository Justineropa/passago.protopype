import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart';
import 'distribution_screen.dart';
import 'trips_screen.dart';

/// Holds the three screens that share the bottom navigation:
/// Driver Dashboard (4), Passenger Distribution (5) and Trip Records (6).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = [
    'Driver Dashboard',
    'Passenger Distribution',
    'Trip Records',
  ];

  void goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        shape: const Border(bottom: BorderSide(color: PG.border)),
        title: Row(
          children: [
            const PgLogo(size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _titles[_index],
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      // IndexedStack keeps each screen alive, so the trip offer countdown
      // and scroll positions are not lost when switching tabs.
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(onOpenQueue: () => goTo(1), onOpenTrips: () => goTo(2)),
          const DistributionScreen(),
          const TripsScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: PG.border)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: goTo,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.hub_outlined),
              selectedIcon: Icon(Icons.hub),
              label: 'Distribution',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Trips',
            ),
          ],
        ),
      ),
    );
  }
}
