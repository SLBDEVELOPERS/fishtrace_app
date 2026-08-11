import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/data/repositories.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../domain/repositories/onboarding_repository.dart';

class AuthenticationController extends GetxController {
  AuthenticationController({
    required AppController session,
    required OnboardingRepository onboarding,
  }) : _session = session,
       _onboarding = onboarding;

  final AppController _session;
  final OnboardingRepository _onboarding;

  final onboardingPage = 0.obs;
  final signingIn = false.obs;
  final loginError = RxnString();
  final recoveryStep = 0.obs;
  final recoveryBusy = false.obs;
  final recoverySuccess = false.obs;
  final resendSeconds = 0.obs;
  Timer? _resendTimer;
  String _recoveryIdentifier = '';
  String _resetToken = '';

  Future<bool> get onboardingComplete => _onboarding.isComplete();

  void setOnboardingPage(int value) => onboardingPage.value = value;

  Future<void> finishOnboarding() => _onboarding.markComplete();

  Future<bool> signIn(String identifier, String password) async {
    signingIn.value = true;
    loginError.value = null;
    try {
      await _session.signIn(identifier.trim(), password);
      return true;
    } catch (error) {
      loginError.value = _readableError(error);
      return false;
    } finally {
      signingIn.value = false;
    }
  }

  Future<bool> requestReset(String identifier) async {
    if (identifier.trim().isEmpty) return false;
    recoveryBusy.value = true;
    try {
      _recoveryIdentifier = identifier.trim();
      await _session.auth.forgotPassword(_recoveryIdentifier);
      recoveryStep.value = 1;
      _startResendTimer();
      return true;
    } on AppException catch (error) {
      loginError.value = error.message;
      return false;
    } finally {
      recoveryBusy.value = false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    if (!RegExp(r'^\d{6}$').hasMatch(otp.trim())) return false;
    recoveryBusy.value = true;
    try {
      _resetToken = await _session.auth.verifyOtp(
        _recoveryIdentifier,
        otp.trim(),
      );
      recoveryStep.value = 2;
      return true;
    } on AppException catch (error) {
      loginError.value = error.message;
      return false;
    } finally {
      recoveryBusy.value = false;
    }
  }

  Future<bool> resetPassword(String password, String confirmation) async {
    final strongPassword =
        password.length >= 10 &&
        RegExp('[a-z]').hasMatch(password) &&
        RegExp('[A-Z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);
    if (!strongPassword || password != confirmation) return false;
    recoveryBusy.value = true;
    try {
      await _session.auth.resetPassword(
        identifier: _recoveryIdentifier,
        resetToken: _resetToken,
        password: password,
        confirmation: confirmation,
      );
      recoverySuccess.value = true;
      return true;
    } on AppException catch (error) {
      loginError.value = error.message;
      return false;
    } finally {
      recoveryBusy.value = false;
    }
  }

  void resendOtp() {
    if (resendSeconds.value > 0) return;
    unawaited(_session.auth.forgotPassword(_recoveryIdentifier));
    _startResendTimer();
  }

  void resetRecovery() {
    recoveryStep.value = 0;
    recoverySuccess.value = false;
    _resetToken = '';
    resendSeconds.value = 0;
    _resendTimer?.cancel();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds.value = 30;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value <= 1) {
        resendSeconds.value = 0;
        timer.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  String _readableError(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '');
    return text.isEmpty ? 'Unable to sign in. Please try again.' : text;
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }
}
