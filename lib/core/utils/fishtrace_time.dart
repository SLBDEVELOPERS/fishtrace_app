import 'package:intl/intl.dart';

/// FishTrace operates in Sri Lanka, which uses UTC+05:30 year-round.
/// API timestamps stay as absolute instants; only presentation is shifted.
abstract final class FishTraceTime {
  static const sriLankaOffset = Duration(hours: 5, minutes: 30);

  static DateTime inSriLanka(DateTime value) =>
      value.toUtc().add(sriLankaOffset);

  static String format(DateTime value, String pattern) =>
      DateFormat(pattern).format(inSriLanka(value));
}
