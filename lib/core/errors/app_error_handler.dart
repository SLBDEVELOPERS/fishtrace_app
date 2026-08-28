import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../network/error_mapper.dart';
import '../widgets/overlays/fishtrace_overlays.dart';
import 'app_exceptions.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Central last-resort boundary for errors that escape a feature controller.
/// Feature code should still handle expected validation and recovery locally.
class AppErrorHandler {
  AppErrorHandler._();

  static final AppErrorHandler instance = AppErrorHandler._();
  final ErrorMapper _mapper = const ErrorMapper();
  String? _lastMessage;
  DateTime? _lastShownAt;

  void install() {
    final previousFlutterHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      previousFlutterHandler?.call(details);
      if (_isFrameworkDiagnostic(details)) return;
      report(details.exception, details.stack ?? StackTrace.current);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      report(error, stackTrace);
      return true;
    };

    ErrorWidget.builder = (details) => Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                'This screen could not be displayed.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Please go back and try again.',
                style: TextStyle(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<T?> guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      report(error, stackTrace);
      return null;
    }
  }

  AppException normalize(Object error) => _mapper.map(error);

  bool _isFrameworkDiagnostic(FlutterErrorDetails details) {
    final library = details.library?.toLowerCase() ?? '';
    return library.contains('rendering') || library.contains('widgets');
  }

  void report(Object error, StackTrace stackTrace) {
    final failure = normalize(error);
    if (kDebugMode) {
      debugPrint('Handled application error: ${failure.message}');
      debugPrintStack(stackTrace: stackTrace);
    }
    _show(failure.message);
  }

  void _show(String message) {
    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastShownAt != null &&
        now.difference(_lastShownAt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastMessage = message;
    _lastShownAt = now;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = rootScaffoldMessengerKey.currentState;
      if (messenger == null) return;
      FishTraceFeedback.showForMessenger(
        messenger,
        message,
        tone: FishTraceFeedbackTone.error,
      );
    });
  }
}
