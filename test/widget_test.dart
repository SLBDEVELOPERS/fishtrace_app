import 'package:fishtrace/app/app.dart';
import 'package:fishtrace/core/data/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'helpers/test_dependencies.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('shows the FishTrace splash experience', (tester) async {
    registerTestDependencies();
    await tester.pumpWidget(const FishTraceApp());
    expect(find.text('FishTrace'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('mock login routes roles correctly', () async {
    final auth = MockAuthRepository();
    expect(
      (await auth.login('retailer@fishtrace.demo', 'FishTrace@2026')).role.name,
      'retailer',
    );
  });
}
