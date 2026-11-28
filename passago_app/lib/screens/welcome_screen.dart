import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

/// Screen 1 of 6: Welcome.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Entrance(
                delayMs: 40,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PgWordmark(height: 56),
                ),
              ),
              const SizedBox(height: 40),
              const Entrance(
                delayMs: 120,
                child: Text(
                  'Drive with PassaGo',
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: PG.plum,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Entrance(
                delayMs: 180,
                child: Text(
                  'Join the line at the terminal, count your passengers, and '
                  'keep a record of every trip.',
                  style: TextStyle(fontSize: 16, height: 1.45, color: PG.body),
                ),
              ),
              const SizedBox(height: 28),
              const Entrance(
                delayMs: 260,
                child: _Feature(
                  icon: Icons.format_list_numbered,
                  title: 'Fair queue',
                  text: 'See who is next. Drivers with fewer passengers are '
                      'prioritized.',
                ),
              ),
              const Entrance(
                delayMs: 330,
                child: _Feature(
                  icon: Icons.schedule,
                  title: 'AM and PM shifts',
                  text: 'Choose your shift and set your own daily quota.',
                ),
              ),
              const Entrance(
                delayMs: 400,
                child: _Feature(
                  icon: Icons.receipt_long_outlined,
                  title: 'Trip logs',
                  text: 'Your trips and passenger counts are recorded '
                      'automatically.',
                ),
              ),
              const SizedBox(height: 24),
              Entrance(
                delayMs: 470,
                child: Column(
                  children: [
                    PgButton(
                      label: 'Get started',
                      onPressed: () => _openLogin(context),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'Already have a Driver ID?',
                            style: TextStyle(fontSize: 14, color: PG.body),
                          ),
                        ),
                        PgTextButton(
                          label: 'Log in',
                          onPressed: () => _openLogin(context),
                        ),
                      ],
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

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: PG.canvas,
              borderRadius: BorderRadius.circular(PG.radius),
              border: Border.all(color: PG.border),
            ),
            child: Icon(icon, size: 24, color: PG.magenta),
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
                    fontWeight: FontWeight.w500,
                    color: PG.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: PG.body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
