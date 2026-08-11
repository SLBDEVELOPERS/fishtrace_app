import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../controllers/authentication_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = const [
    _OnboardingPage(
      title: 'Complete Traceability,\nFrom Catch to Consumer',
      message: 'Track, verify, and trust every step of your seafood journey.',
      illustration: _OnboardingIllustration.boat,
    ),
    _OnboardingPage(
      title: 'Protect Every Degree\nAcross the Cold Chain',
      message: 'Monitor storage and transport conditions as they change.',
      illustration: _OnboardingIllustration.temperature,
    ),
    _OnboardingPage(
      title: 'Confidence for Every\nBusiness and Customer',
      message: 'Use verified records to make transparent decisions.',
      illustration: _OnboardingIllustration.trust,
    ),
  ];

  late final PageController _pageController;
  late final AuthenticationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AuthenticationController>();
    _pageController = PageController(
      initialPage: _controller.onboardingPage.value,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await _controller.finishOnboarding();
    if (mounted) context.go(AppRoute.login);
  }

  @override
  Widget build(BuildContext context) => FishTraceScaffold(
    backgroundColor: FishTraceColors.surface,
    body: Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(
              top: FishTraceSpacing.xs,
              right: FishTraceSpacing.sm,
            ),
            child: TextButton(onPressed: _finish, child: const Text('Skip')),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: _controller.setOnboardingPage,
            itemBuilder: (context, index) =>
                _OnboardingPageView(page: _pages[index]),
          ),
        ),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: index == _controller.onboardingPage.value ? 18 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: index == _controller.onboardingPage.value
                      ? FishTraceColors.primary
                      : FishTraceColors.chartSecondary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Obx(() {
            final last = _controller.onboardingPage.value == _pages.length - 1;
            return FishTracePrimaryButton(
              label: last ? 'Get Started' : 'Next',
              onPressed: last
                  ? _finish
                  : () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                    ),
            );
          }),
        ),
        TextButton(
          onPressed: () {
            if (_controller.onboardingPage.value > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
              );
            }
          },
          child: const Text('Back'),
        ),
        const SizedBox(height: FishTraceSpacing.xs),
      ],
    ),
  );
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.message,
    required this.illustration,
  });

  final String title;
  final String message;
  final _OnboardingIllustration illustration;
}

enum _OnboardingIllustration { boat, temperature, trust }

class _OnboardingPageView extends StatelessWidget {
  const _OnboardingPageView({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      children: [
        const Spacer(),
        SizedBox(
          height: 250,
          width: double.infinity,
          child: CustomPaint(painter: _OnboardingPainter(page.illustration)),
        ),
        const SizedBox(height: FishTraceSpacing.xl),
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: FishTraceSpacing.sm),
        Text(
          page.message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: FishTraceColors.textSecondary),
        ),
        const Spacer(),
      ],
    ),
  );
}

class _OnboardingPainter extends CustomPainter {
  const _OnboardingPainter(this.kind);

  final _OnboardingIllustration kind;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .55);
    final pale = Paint()..color = FishTraceColors.oceanLight;
    final primary = Paint()..color = FishTraceColors.primary;
    final cyan = Paint()..color = FishTraceColors.cyan;

    canvas.drawCircle(center, size.height * .38, pale);
    final wave = Paint()
      ..color = FishTraceColors.chartSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var row = 0; row < 4; row++) {
      final y = size.height * (.67 + row * .055);
      final path = Path()..moveTo(size.width * .12, y);
      for (double x = size.width * .12; x < size.width * .88; x += 8) {
        path.lineTo(x, y + math.sin((x / size.width * math.pi * 5) + row) * 3);
      }
      canvas.drawPath(path, wave);
    }

    switch (kind) {
      case _OnboardingIllustration.boat:
        final hull = Path()
          ..moveTo(size.width * .28, size.height * .55)
          ..lineTo(size.width * .72, size.height * .55)
          ..lineTo(size.width * .62, size.height * .68)
          ..lineTo(size.width * .36, size.height * .68)
          ..close();
        canvas.drawPath(hull, primary);
        canvas.drawRect(
          Rect.fromLTWH(
            size.width * .4,
            size.height * .39,
            size.width * .22,
            size.height * .16,
          ),
          cyan,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            size.width * .51,
            size.height * .2,
            3,
            size.height * .2,
          ),
          primary,
        );
      case _OnboardingIllustration.temperature:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center,
              width: size.width * .26,
              height: size.height * .48,
            ),
            const Radius.circular(30),
          ),
          primary,
        );
        canvas.drawCircle(
          Offset(center.dx, size.height * .65),
          size.height * .13,
          cyan,
        );
        canvas.drawRect(
          Rect.fromLTWH(
            center.dx - 7,
            size.height * .28,
            14,
            size.height * .35,
          ),
          Paint()..color = Colors.white,
        );
      case _OnboardingIllustration.trust:
        final shield = Path()
          ..moveTo(center.dx, size.height * .22)
          ..lineTo(size.width * .7, size.height * .34)
          ..lineTo(size.width * .64, size.height * .65)
          ..quadraticBezierTo(
            center.dx,
            size.height * .82,
            size.width * .36,
            size.height * .65,
          )
          ..lineTo(size.width * .3, size.height * .34)
          ..close();
        canvas.drawPath(shield, primary);
        final check = Path()
          ..moveTo(size.width * .4, size.height * .51)
          ..lineTo(size.width * .48, size.height * .61)
          ..lineTo(size.width * .64, size.height * .41);
        canvas.drawPath(
          check,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 8,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _OnboardingPainter oldDelegate) =>
      oldDelegate.kind != kind;
}
