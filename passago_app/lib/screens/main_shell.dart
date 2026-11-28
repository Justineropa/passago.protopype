import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart';
import 'distribution_screen.dart';
import 'settings_screen.dart';
import 'trips_screen.dart';

/// Holds the three screens that share the bottom navigation:
/// Driver Dashboard (4), Passenger Distribution (5) and Trip Records (6).
/// Settings opens from the gear icon in the top bar.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _titles = [
    'Driver Dashboard',
    'Passenger Distribution',
    'Trip Records',
  ];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: pgAppBar(
        title: _titles[state.tabIndex],
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, color: PG.body),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      // IndexedStack keeps each tab alive, so scroll positions are kept.
      body: IndexedStack(
        index: state.tabIndex,
        children: const [
          DashboardScreen(),
          DistributionScreen(),
          TripsScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: PG.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: state.tabIndex,
          onTap: state.setTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: PG.canvas,
          elevation: 0,
          selectedItemColor: PG.magenta,
          unselectedItemColor: PG.muted,
          selectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.format_list_numbered),
              label: 'Distribution',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Trips',
            ),
          ],
        ),
      ),
    );
  }
}
