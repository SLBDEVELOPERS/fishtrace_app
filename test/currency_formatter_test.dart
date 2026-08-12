import 'package:fishtrace/features/common/presentation/formatters/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats Sri Lankan rupees consistently', () {
    expect(CurrencyFormatter.lkr(1250), 'Rs. 1,250.00');
    expect(CurrencyFormatter.lkr(1250.6, showCents: false), 'Rs. 1,251');
  });
}
