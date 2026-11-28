import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';

// ------------------------------------------------------------------- logos

/// The PG monogram. Reads assets/branding/logo_monogram.png. If that file is
/// not there yet, a plain text placeholder is shown so nothing breaks.
class PgLogo extends StatelessWidget {
  const PgLogo({super.key, this.height = 28});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/logo_monogram.png',
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'PassaGo',
      errorBuilder: (context, error, stackTrace) => SizedBox(
        height: height,
        child: Center(
          child: Text(
            'PG',
            style: TextStyle(
              fontSize: height * 0.8,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              color: PG.magenta,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

/// The full logo (tricycle + "PassaGo"). Reads assets/branding/logo_wordmark.png
/// and falls back to a text placeholder when the file is missing.
class PgWordmark extends StatelessWidget {
  const PgWordmark({super.key, this.height = 48});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/logo_wordmark.png',
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'PassaGo',
      errorBuilder: (context, error, stackTrace) => SizedBox(
        height: height,
        child: Center(
          child: Text.rich(
            TextSpan(
              text: 'Passa',
              style: TextStyle(
                fontSize: height * 0.6,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: PG.plum,
              ),
              children: const [
                TextSpan(text: 'Go', style: TextStyle(color: PG.magenta)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------- app bar

/// Flat top bar: optional back arrow, monogram, title, optional actions.
AppBar pgAppBar({
  required String title,
  bool showLogo = true,
  VoidCallback? onBack,
  List<Widget>? actions,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 56,
    backgroundColor: PG.canvas,
    surfaceTintColor: Colors.transparent,
    titleSpacing: onBack == null ? 16 : 0,
    leading: onBack == null
        ? null
        : IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back, color: PG.body),
            onPressed: onBack,
          ),
    title: Row(
      children: [
        if (showLogo) ...[
          const PgLogo(height: 24),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: PG.ink,
            ),
          ),
        ),
      ],
    ),
    actions: actions,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, thickness: 1, color: PG.border),
    ),
  );
}

// ---------------------------------------------------------------- buttons

/// Large rectangular button. Plum by default, [outlined] for secondary
/// actions, or give [background] (for example magenta) for a special one.
class PgButton extends StatelessWidget {
  const PgButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.outlined = false,
    this.background = PG.plum,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool outlined;
  final Color background;
  final double height;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(PG.radius),
    );

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 22),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 20),
        ],
      ],
    );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: PG.plum,
                backgroundColor: PG.canvas,
                disabledForegroundColor: PG.muted,
                side: BorderSide(
                  color: onPressed == null ? PG.borderSoft : PG.plum,
                ),
                shape: shape,
              ),
              child: content,
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: background,
                foregroundColor: Colors.white,
                disabledBackgroundColor: PG.disabledFill,
                disabledForegroundColor: PG.muted,
                shape: shape,
                elevation: 0,
              ),
              child: content,
            ),
    );
  }
}

/// Small text-only button in magenta (Connect, Raise quota, ...).
class PgTextButton extends StatelessWidget {
  const PgTextButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: PG.magenta,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ------------------------------------------------------------- containers

/// Flat bordered container, used instead of floating cards.
class PgPanel extends StatelessWidget {
  const PgPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = PG.canvas,
    this.borderColor = PG.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(PG.radius);
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Small rectangular tag with short text ("Next", "Not on a trip", ...).
class PgTag extends StatelessWidget {
  const PgTag(
    this.text, {
    super.key,
    this.background = PG.surface,
    this.color = PG.body,
  });

  final String text;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(PG.radiusSmall),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

/// Small solid status dot.
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Small section heading in magenta, sentence case.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: PG.magenta,
      ),
    );
  }
}

/// Segmented switch such as Normal / Large. [labels] are shown in order.
class PgSegmented extends StatelessWidget {
  const PgSegmented({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PG.surface,
        borderRadius: BorderRadius.circular(PG.radius),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? PG.plum : Colors.transparent,
                    borderRadius: BorderRadius.circular(PG.radiusSmall),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: i == selected ? Colors.white : PG.body,
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

/// Rectangular filter chip (Today, This week, AM shift, ...).
class PgChip extends StatelessWidget {
  const PgChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PG.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PG.radiusSmall),
        side: BorderSide(
          color: selected ? PG.magenta : PG.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(PG.radiusSmall),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? PG.magenta : PG.body,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- dialogs

/// Two-choice dialog. The top button is the SAFE choice (returns false); the
/// outlined one below it is the action being confirmed (returns true).
/// Returns null if the dialog is dismissed.
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  Widget? detail,
  required String safeLabel,
  required String confirmLabel,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: PG.canvas,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PG.radius),
        side: const BorderSide(color: PG.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: PG.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 15, height: 1.4, color: PG.body),
            ),
            if (detail != null) ...[
              const SizedBox(height: 14),
              detail,
            ],
            const SizedBox(height: 20),
            PgButton(
              label: safeLabel,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            const SizedBox(height: 10),
            PgButton(
              label: confirmLabel,
              outlined: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        ),
      ),
    ),
  );
}

void showInfoSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

// ------------------------------------------------------------- animation

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
    duration: const Duration(milliseconds: 380),
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

// ------------------------------------------------------------- formatting

const _monthsShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "3h 12m"
String durationLabel(Duration d) => '${d.inHours}h ${d.inMinutes % 60}m';

/// "09:42 AM"
String timeLabel(DateTime t) {
  final hour12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  final suffix = t.hour < 12 ? 'AM' : 'PM';
  return '${hour12.toString().padLeft(2, '0')}:$minute $suffix';
}

/// "Today", "Yesterday" or "Nov 25"
String dayLabel(DateTime t, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return '${_monthsShort[t.month - 1]} ${t.day}';
}

/// "Good morning", "Good afternoon" or "Good evening"
String greeting(DateTime now) {
  if (now.hour < 12) return 'Good morning';
  if (now.hour < 18) return 'Good afternoon';
  return 'Good evening';
}
