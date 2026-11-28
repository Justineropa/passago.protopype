import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// PLACEHOLDER logo. Replace the body of this widget with the real tricycle
/// emblem (for example an SVG or PNG asset) once the master logo is final.
class PgLogo extends StatelessWidget {
  const PgLogo({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PG.plum,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        'PG',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Fades and slides its child up shortly after the screen opens.
/// Skipped when the phone has animations turned off.
class Entrance extends StatefulWidget {
  const Entrance({super.key, required this.child, this.delayMs = 0});

  final Widget child;
  final int delayMs;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  Timer? _delay;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (widget.delayMs == 0) {
      _controller.forward();
    } else {
      _delay = Timer(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}

/// Large main button. Filled plum by default, outlined when [outlined].
class PgButton extends StatelessWidget {
  const PgButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final double height;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: PG.ink,
                backgroundColor: Colors.white,
                side: const BorderSide(color: PG.borderStrong),
                shape: shape,
              ),
              child: content,
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: PG.plum,
                foregroundColor: Colors.white,
                disabledBackgroundColor: PG.borderStrong,
                disabledForegroundColor: Colors.white,
                shape: shape,
                elevation: 0,
              ),
              child: content,
            ),
    );
  }
}

/// White card with a subtle border, as used across the designs.
class PgCard extends StatelessWidget {
  const PgCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: PG.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Small uppercase magenta label used above sections.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: PG.magenta,
      ),
    );
  }
}

/// Rounded gray pill with short text, for tags like "Live Terminal".
class PgPill extends StatelessWidget {
  const PgPill(this.text,
      {super.key, this.background = PG.surface, this.color = PG.body});

  final String text;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "Friday, 27 November 2026"
String longDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

/// "Friday 27 November"
String dayHeading(DateTime d) =>
    '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';

/// "3h 12m"
String durationLabel(Duration d) => '${d.inHours}h ${d.inMinutes % 60}m';
