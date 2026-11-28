import 'package:flutter/material.dart';

import '../models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Shown when a shift ends: the quota was reached, the driver ended it, or
/// the scheduled hours finished.
class ShiftSummaryScreen extends StatelessWidget {
  const ShiftSummaryScreen({super.key, required this.summary});

  final ShiftSummary summary;

  String get _title {
    switch (summary.reason) {
      case ShiftEndReason.quotaReached:
        return 'Quota reached';
      case ShiftEndReason.manual:
        return 'Shift ended';
      case ShiftEndReason.scheduledHours:
        return 'Shift ended';
    }
  }

  String get _subtitle {
    switch (summary.reason) {
      case ShiftEndReason.quotaReached:
        return 'You reached your daily quota. Your shift is complete.';
      case ShiftEndReason.manual:
        return 'You ended your shift.';
      case ShiftEndReason.scheduledHours:
        return 'Your scheduled shift hours are finished.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = summary.quota == 0
        ? 0
        : (summary.passengers * 100 / summary.quota).round();
    final progress = summary.quota == 0
        ? 0.0
        : (summary.passengers / summary.quota).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: pgAppBar(title: 'Shift summary'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 8),
                  Icon(
                    summary.reason == ShiftEndReason.quotaReached
                        ? Icons.check_circle
                        : Icons.flag_outlined,
                    size: 48,
                    color: PG.magenta,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: PG.plum,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitle,
                    style: const TextStyle(
                        fontSize: 15, height: 1.4, color: PG.body),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${summary.driverName} • Body No. ${summary.bodyNo} • '
                    '${summary.shift.label} shift',
                    style: const TextStyle(fontSize: 13, color: PG.muted),
                  ),
                  const SizedBox(height: 20),
                  PgPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Quota progress',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: PG.ink,
                              ),
                            ),
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: PG.magenta,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(PG.radiusSmall),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: PG.surface,
                            color: PG.magenta,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${summary.passengers} of ${summary.quota} '
                          'passengers',
                          style:
                              const TextStyle(fontSize: 12, color: PG.muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                            value: '${summary.passengers}',
                            label: 'Passengers'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Stat(
                            value: '${summary.trips}', label: 'Trips'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Stat(
                            value: durationLabel(summary.duration),
                            label: 'Shift hours'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Drivers with fewer passengers are prioritized. Your '
                    'passenger count resets when you start your next shift.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: PG.muted),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: PG.border)),
              ),
              padding: const EdgeInsets.all(16),
              child: PgButton(
                label: 'Done',
                onPressed: AppScope.of(context).dismissSummary,
              ),
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: PG.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: PG.muted)),
        ],
      ),
    );
  }
}
