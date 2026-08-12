import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/data/repositories.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../controllers/authentication_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  late final AuthenticationController _controller;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthenticationController>();
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final success = await _controller.signIn(_identifier.text, _password.text);
    if (!success || !mounted) return;
    final role = Get.find<AppController>().user.value!.role;
    context.go('/${role.name}');
  }

  void _selectDemo(String role) {
    _identifier.text = '$role@fishtrace.demo';
    _password.text = 'FishTrace@2026';
  }

  @override
  Widget build(BuildContext context) => FishTraceScaffold(
    backgroundColor: FishTraceColors.surface,
    body: Stack(
      children: [
        const Positioned.fill(child: _LoginWaveBackground()),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: FishTraceMark(size: 58)),
                  const SizedBox(height: FishTraceSpacing.sm),
                  Text(
                    'Welcome back!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to continue to your account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: FishTraceSpacing.xl),
                  FishTraceTextField(
                    label: 'Email / Phone',
                    controller: _identifier,
                    hint: 'Enter email or phone number',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    required: true,
                    validator: (value) {
                      final input = value?.trim() ?? '';
                      if (input.isEmpty) return 'Email or phone is required';
                      if (!input.contains('@') && input.length < 7) {
                        return 'Enter a valid email or phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: FishTraceSpacing.md),
                  FishTraceTextField(
                    label: 'Password',
                    controller: _password,
                    hint: 'Enter password',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    required: true,
                    validator: (value) => (value?.length ?? 0) < 8
                        ? 'Password must contain at least 8 characters'
                        : null,
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 19,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(AppRoute.recovery),
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  Obx(
                    () => _controller.loginError.value == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _controller.loginError.value!,
                              style: const TextStyle(
                                color: FishTraceColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                  ),
                  Obx(
                    () => FishTracePrimaryButton(
                      label: 'Sign In',
                      loading: _controller.signingIn.value,
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: FishTraceSpacing.md),
                  const _OrDivider(),
                  const SizedBox(height: FishTraceSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          label: 'Google',
                          mark: 'G',
                          onPressed: () => _showSocialConfiguration('Google'),
                        ),
                      ),
                      const SizedBox(width: FishTraceSpacing.sm),
                      Expanded(
                        child: _SocialButton(
                          label: 'Apple',
                          icon: Icons.apple,
                          onPressed: () => _showSocialConfiguration('Apple'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: FishTraceSpacing.lg),
                  Text(
                    'Demo role',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: FishTraceSpacing.xs),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final role in const [
                        'fisher',
                        'processor',
                        'transporter',
                        'retailer',
                      ])
                        ActionChip(
                          label: Text(role),
                          onPressed: () => _selectDemo(role),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void _showSocialConfiguration(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$provider sign-in requires provider credentials in API mode.',
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: Divider()),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'or continue with',
          style: TextStyle(color: FishTraceColors.textSecondary, fontSize: 11),
        ),
      ),
      Expanded(child: Divider()),
    ],
  );
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.onPressed,
    this.mark,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final String? mark;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 46,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: FishTraceColors.textPrimary,
        side: const BorderSide(color: FishTraceColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mark != null)
            Text(
              mark!,
              style: const TextStyle(
                color: FishTraceColors.info,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            )
          else
            Icon(icon, size: 19),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    ),
  );
}

class _LoginWaveBackground extends StatelessWidget {
  const _LoginWaveBackground();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 115,
        width: double.infinity,
        child: CustomPaint(painter: _LoginWavePainter()),
      ),
    ),
  );
}

class _LoginWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < 5; index++) {
      final path = Path()..moveTo(0, size.height * (.35 + index * .11));
      path.cubicTo(
        size.width * .28,
        size.height * (.1 + index * .12),
        size.width * .7,
        size.height * (.65 + index * .04),
        size.width,
        size.height * (.32 + index * .1),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = FishTraceColors.cyan.withValues(alpha: .1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
