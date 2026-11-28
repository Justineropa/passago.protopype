import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../data/mock_data.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'schedule_screen.dart';

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

  // Prototype rule: an ID of 3+ characters "verifies" as the placeholder driver.
  bool get _idLooksValid => _idController.text.trim().length >= 3;
  bool get _canLogIn => _idLooksValid && _pinController.text.length == 6;

  void _notAvailable(String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what is not available in this prototype yet.')),
    );
  }

  void _logIn() {
    AppScope.of(context).signIn();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ScheduleScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Driver login',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
        ),
      ),
      extendBodyBehindAppBar: false,
      body: Container(
        decoration: const BoxDecoration(gradient: PG.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Entrance(
                  delayMs: 60,
                  child: Row(
                    children: [
                      PgLogo(size: 44),
                      SizedBox(width: 12),
                      Text(
                        'Sign in to PassaGo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: PG.plum,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Entrance(
                  delayMs: 120,
                  child: Text(
                    'Enter your TODA-registered Driver ID and 6-digit '
                    'security PIN to begin your shift.',
                    style: TextStyle(fontSize: 15, height: 1.45, color: PG.body),
                  ),
                ),
                const SizedBox(height: 24),
                Entrance(
                  delayMs: 180,
                  child: _label('Driver ID'),
                ),
                const SizedBox(height: 6),
                Entrance(
                  delayMs: 200,
                  child: TextField(
                    controller: _idController,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(
                      hint: 'Enter your Driver ID',
                      suffix: _idLooksValid
                          ? const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(Icons.check_circle,
                                  color: PG.magenta, size: 22),
                            )
                          : null,
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _idLooksValid
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_outlined,
                                  size: 16, color: PG.secondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Verified • ${state.driverName} '
                                  '(Body No. ${MockData.driverBodyNo})',
                                  style: const TextStyle(
                                      fontSize: 13, color: PG.secondary),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                const SizedBox(height: 18),
                Entrance(
                  delayMs: 260,
                  child: _label('6-digit security PIN'),
                ),
                const SizedBox(height: 6),
                Entrance(
                  delayMs: 280,
                  child: TextField(
                    controller: _pinController,
                    obscureText: !_showPin,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: _decoration(
                      hint: '••••••',
                      suffix: TextButton(
                        onPressed: () => setState(() => _showPin = !_showPin),
                        style: TextButton.styleFrom(
                          foregroundColor: PG.magenta,
                        ),
                        child: Text(_showPin ? 'Hide' : 'Show'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Entrance(
                  delayMs: 340,
                  child: Row(
                    children: [
                      Checkbox(
                        value: _remember,
                        activeColor: PG.plum,
                        onChanged: (v) => setState(() => _remember = v ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'Remember this device',
                          style: TextStyle(fontSize: 14, color: PG.body),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _notAvailable('PIN reset'),
                        style: TextButton.styleFrom(foregroundColor: PG.magenta),
                        child: const Text('Forgot PIN?'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Entrance(
                  delayMs: 400,
                  child: Column(
                    children: [
                      PgButton(
                        label: 'Log in',
                        onPressed: _canLogIn ? _logIn : null,
                      ),
                      const SizedBox(height: 12),
                      PgButton(
                        label: 'Log in with mobile number (SMS OTP)',
                        icon: Icons.call_outlined,
                        outlined: true,
                        onPressed: () => _notAvailable('SMS login'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: PG.muted),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: border(const Color(0xFFD1D5DB)),
      focusedBorder: border(PG.plum, 2),
    );
  }
}
