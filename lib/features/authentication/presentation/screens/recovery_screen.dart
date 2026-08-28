import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../controllers/authentication_controller.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _requestKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();
  final _resetKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  late final AuthenticationController _controller;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthenticationController>();
    _controller.resetRecovery();
  }

  @override
  void dispose() {
    _identifier.dispose();
    _otp.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FishTraceScaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: FishTraceAppBar(
      title: 'Password Recovery',
      leading: IconButton(
        tooltip: 'Back to login',
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: Obx(
      () => _controller.recoverySuccess.value
          ? _SuccessView(onDone: () => context.go(AppRoute.login))
          : Column(
              children: [
                _RecoveryProgress(step: _controller.recoveryStep.value),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(FishTraceSpacing.md),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: switch (_controller.recoveryStep.value) {
                        0 => _requestStep(),
                        1 => _otpStep(),
                        _ => _resetStep(),
                      },
                    ),
                  ),
                ),
              ],
            ),
    ),
  );

  Widget _requestStep() => Form(
    key: _requestKey,
    child: Column(
      key: const ValueKey('request'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Step 1: Forgot Password',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: FishTraceSpacing.xs),
        Text(
          'Enter your registered email or phone number.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: FishTraceSpacing.lg),
        FishTraceTextField(
          label: 'Email / Phone',
          controller: _identifier,
          hint: 'Enter email or phone number',
          required: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          validator: (value) => (value?.trim().isEmpty ?? true)
              ? 'Email or phone is required'
              : null,
        ),
        const SizedBox(height: FishTraceSpacing.md),
        Obx(
          () => FishTracePrimaryButton(
            label: 'Send Reset Code',
            loading: _controller.recoveryBusy.value,
            onPressed: () async {
              if (!_requestKey.currentState!.validate()) return;
              await _controller.requestReset(_identifier.text);
            },
          ),
        ),
      ],
    ),
  );

  Widget _otpStep() => Form(
    key: _otpKey,
    child: Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Step 2: Verify OTP',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: FishTraceSpacing.xs),
        Text(
          'Enter the 6-digit code sent to ${_identifier.text}.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: FishTraceSpacing.lg),
        FishTraceTextField(
          label: 'Verification code',
          controller: _otp,
          hint: '000000',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          required: true,
          validator: (value) => RegExp(r'^\d{6}$').hasMatch(value ?? '')
              ? null
              : 'Enter the six-digit code',
        ),
        const SizedBox(height: FishTraceSpacing.md),
        Obx(
          () => FishTracePrimaryButton(
            label: 'Verify Code',
            loading: _controller.recoveryBusy.value,
            onPressed: () async {
              if (!_otpKey.currentState!.validate()) return;
              await _controller.verifyOtp(_otp.text);
            },
          ),
        ),
        const SizedBox(height: FishTraceSpacing.sm),
        Obx(
          () => TextButton(
            onPressed: _controller.resendSeconds.value == 0
                ? _controller.resendOtp
                : null,
            child: Text(
              _controller.resendSeconds.value == 0
                  ? 'Resend code'
                  : 'Resend code in 00:${_controller.resendSeconds.value.toString().padLeft(2, '0')}',
            ),
          ),
        ),
      ],
    ),
  );

  Widget _resetStep() => Form(
    key: _resetKey,
    child: Column(
      key: const ValueKey('reset'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Step 3: Reset Password',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: FishTraceSpacing.xs),
        Text(
          'Use at least eight characters for your new password.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: FishTraceSpacing.lg),
        FishTraceTextField(
          label: 'New Password',
          controller: _password,
          hint: 'Enter new password',
          required: true,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          enableSuggestions: false,
          autocorrect: false,
          validator: (value) =>
              (value?.length ?? 0) < 8 ? 'Use at least eight characters' : null,
          suffixIcon: IconButton(
            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
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
        const SizedBox(height: FishTraceSpacing.md),
        FishTraceTextField(
          label: 'Confirm Password',
          controller: _confirmation,
          hint: 'Re-enter new password',
          required: true,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          enableSuggestions: false,
          autocorrect: false,
          validator: (value) =>
              value != _password.text ? 'Passwords do not match' : null,
        ),
        const SizedBox(height: FishTraceSpacing.md),
        Obx(
          () => FishTracePrimaryButton(
            label: 'Reset Password',
            loading: _controller.recoveryBusy.value,
            onPressed: () async {
              if (!_resetKey.currentState!.validate()) return;
              await _controller.resetPassword(
                _password.text,
                _confirmation.text,
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _RecoveryProgress extends StatelessWidget {
  const _RecoveryProgress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
    child: Row(
      children: [
        for (var index = 0; index < 3; index++) ...[
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Divider(
                          color: index <= step
                              ? FishTraceColors.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: index <= step
                            ? FishTraceColors.primary
                            : Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: index <= step
                              ? FishTraceColors.primary
                              : FishTraceColors.disabled,
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: index <= step
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (index < 2)
                      Expanded(
                        child: Divider(
                          color: index < step
                              ? FishTraceColors.primary
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  const ['Request', 'Verify', 'Reset'][index],
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: const BoxDecoration(
              color: FishTraceColors.successSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: FishTraceColors.success,
              size: 44,
            ),
          ),
          const SizedBox(height: FishTraceSpacing.lg),
          Text('Password reset', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: FishTraceSpacing.xs),
          Text(
            'Your password has been updated. Sign in with your new password.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: FishTraceSpacing.xl),
          FishTracePrimaryButton(label: 'Return to Login', onPressed: onDone),
        ],
      ),
    ),
  );
}
