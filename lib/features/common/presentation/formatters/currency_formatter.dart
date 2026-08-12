import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final NumberFormat _withCents = NumberFormat('#,##0.00', 'en_LK');
  static final NumberFormat _whole = NumberFormat('#,##0', 'en_LK');

  static String lkr(num amount, {bool showCents = true}) =>
      'Rs. ${showCents ? _withCents.format(amount) : _whole.format(amount)}';
}
