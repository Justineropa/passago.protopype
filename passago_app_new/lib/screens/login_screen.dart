import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'shift_gate.dart';

/// Screen 2 of 6: Driver Login.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pinController = TextEditingController();
  bool _showPin = false;
  bool _remember = true;

  @override
  void initState() {
    super.initState();
    _idController.addListener(_refresh);
    _pinController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _idController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // Prototype rule: any ID of 3 or more characters and any 6-digit PIN works.
  // Real authentication replaces this later.
  bool get _canLogIn =>
      _idController.text.trim().length >= 3 && _pinController.text.length == 6;

  void _logIn() {
    AppScope.of(context).signIn();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ShiftGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: pgAppBar(
        title: 'Driver login',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Entrance(
                delayMs: 40,
                child: Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: PG.plum,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Entrance(
                delayMs: 90,
                child: Text(
                  'Enter your Driver ID and 6-digit PIN to start your shift.',
                  style: TextStyle(fontSize: 15, height: 1.45, color: PG.body),
                ),
              ),
              const SizedBox(height: 28),
              Entrance(delayMs: 140, child: _label('Driver ID')),
              const SizedBox(height: 6),
              Entrance(
                delayMs: 160,
                child: TextField(
                  controller: _idController,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(hint: 'Enter your Driver ID'),
                ),
              ),
              const SizedBox(height: 18),
              Entrance(delayMs: 210, child: _label('6-digit PIN')),
              const SizedBox(height: 6),
              Entrance(
                delayMs: 230,
                child: TextField(
                  controller: _pinController,
                  obscureText: !_showPin,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: _decoration(
                    hint: '000000',
                    suffix: TextButton(
                      onPressed: () => setState(() => _showPin = !_showPin),
                      style: TextButton.styleFrom(foregroundColor: PG.magenta),
                      child: Text(_showPin ? 'Hide' : 'Show'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Entrance(
                delayMs: 280,
                child: Row(
                  children: [
                    Checkbox(
                      value: _remember,
                      onChanged: (v) => setState(() => _remember = v ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'Remember this device',
                        style: TextStyle(fontSize: 14, color: PG.body),
                      ),
                    ),
                    PgTextButton(
                      label: 'Forgot PIN?',
                      onPressed: () => showInfoSnack(
                        context,
                        'PIN reset is not available in this prototype yet.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Entrance(
                delayMs: 330,
                child: Column(
                  children: [
                    PgButton(
                      label: 'Log in',
                      onPressed: _canLogIn ? _logIn : null,
                    ),
                    const SizedBox(height: 4),
                    PgTextButton(
                      label: 'Cancel and return',
                      onPressed: () => Navigator.of(context).pop(),
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

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: PG.ink,
        ),
      );

  InputDecoration _decoration({required String hint, Widget? suffix}) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(PG.radius),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: PG.muted),
      filled: true,
      fillColor: PG.canvas,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(PG.border),
      focusedBorder: border(PG.plum, 2),
    );
  }
}
