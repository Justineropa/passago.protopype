import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'common.dart';

/// Bottom sheet for raising the quota during a shift. It can only go up.
Future<void> showRaiseQuotaSheet(BuildContext context, AppState state) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _RaiseQuotaSheet(
      current: state.quota,
      onSave: (value) {
        state.raiseQuota(value);
        Navigator.of(sheetContext).pop();
      },
      onCancel: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

class _RaiseQuotaSheet extends StatefulWidget {
  const _RaiseQuotaSheet({
    required this.current,
    required this.onSave,
    required this.onCancel,
  });

  final int current;
  final ValueChanged<int> onSave;
  final VoidCallback onCancel;

  @override
  State<_RaiseQuotaSheet> createState() => _RaiseQuotaSheetState();
}

class _RaiseQuotaSheetState extends State<_RaiseQuotaSheet> {
  static const _max = 99;
  late int _value = widget.current;

  Widget _stepButton(IconData icon, String label, VoidCallback? onTap) {
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

  @override
  Widget build(BuildContext context) {
    final changed = _value > widget.current;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Raise daily quota',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: PG.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'You can raise your quota during the shift, but not lower it.',
            style: TextStyle(fontSize: 14, height: 1.4, color: PG.body),
          ),
          const SizedBox(height: 16),
          Text(
            'Current quota: ${widget.current} passengers',
            style: const TextStyle(fontSize: 14, color: PG.muted),
          ),
          const SizedBox(height: 10),
          PgPanel(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _stepButton(
                  Icons.remove,
                  'Lower new quota',
                  _value > widget.current ? () => setState(() => _value--) : null,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_value',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: PG.ink,
                      ),
                    ),
                  ),
                ),
                _stepButton(
                  Icons.add,
                  'Raise new quota',
                  _value < _max ? () => setState(() => _value++) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'New quota: $_value passengers',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: PG.ink,
            ),
          ),
          const SizedBox(height: 18),
          PgButton(
            label: 'Save new quota',
            onPressed: changed ? () => widget.onSave(_value) : null,
          ),
          const SizedBox(height: 10),
          PgButton(
            label: 'Cancel',
            outlined: true,
            onPressed: widget.onCancel,
          ),
        ],
      ),
    );
  }
}
