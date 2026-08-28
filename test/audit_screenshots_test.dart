import 'dart:io';

import 'package:fishtrace/app/theme/fishtrace_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'helpers/audit_screen_catalog.dart';
import 'helpers/test_dependencies.dart';

void main() {
  String? auditFontFamily;
  const geolocatorChannel = MethodChannel('flutter.baseflow.com/geolocator');

  setUpAll(() async {
    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await materialIcons.load();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          geolocatorChannel,
          (call) async =>
              call.method == 'isLocationServiceEnabled' ? false : null,
        );
    final font = File(r'C:\Windows\Fonts\arial.ttf');
    if (await font.exists()) {
      final bytes = await font.readAsBytes();
      final loader = FontLoader('AuditSans')
        ..addFont(
          Future<ByteData>.value(
            ByteData.view(
              bytes.buffer,
              bytes.offsetInBytes,
              bytes.lengthInBytes,
            ),
          ),
        );
      await loader.load();
      auditFontFamily = 'AuditSans';
    }
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(geolocatorChannel, null);
  });

  test('audit catalogue contains exactly 40 primary screens', () {
    expect(auditScreens, hasLength(40));
    expect(auditScreens.map((screen) => screen.name).toSet(), hasLength(40));
  });

  for (final screen in auditScreens) {
    testWidgets('390x844 screenshot ${screen.name}', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      registerTestDependencies(role: screen.role);
      addTearDown(Get.reset);

      final auditTheme = buildFishTraceTheme(fontFamily: auditFontFamily);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: auditTheme,
          home: RepaintBoundary(
            key: const ValueKey('audit-boundary'),
            child: screen.builder(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const ValueKey('audit-boundary')),
        matchesGoldenFile('goldens/final_audit/${screen.name}.png'),
      );
    });
  }
}
