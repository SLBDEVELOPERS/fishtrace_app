import 'dart:async';

import 'app/bootstrap.dart';
import 'core/errors/app_error_handler.dart';

void main() {
  runZonedGuarded(
    bootstrap,
    (error, stackTrace) => AppErrorHandler.instance.report(error, stackTrace),
  );
}
