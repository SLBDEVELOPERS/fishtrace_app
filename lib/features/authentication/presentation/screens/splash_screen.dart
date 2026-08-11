import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../controllers/authentication_controller.dart';
import '../widgets/ocean_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => FishTraceScaffold(
    backgroundColor: FishTraceColors.navy,
    body: OceanBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
        child: Column(
          children: [
            const Spacer(flex: 3),
            const FishTraceMark(size: 82, onDark: true),
            const SizedBox(height: FishTraceSpacing.md),
            const FishTraceWordmark(onDark: true),
            const SizedBox(height: FishTraceSpacing.xs),
            Text(
              'Trace Every Fish. Trust Every Step.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: .82),
              ),
            ),
            const Spacer(flex: 3),
            const _Feature(
              icon: Icons.account_tree_outlined,
              title: 'End-to-end Traceability',
              message: 'From catch to consumer',
            ),
            const _Feature(
              icon: Icons.near_me_outlined,
              title: 'Real-time Monitoring',
              message: 'Track every step in real time',
            ),
            const _Feature(
              icon: Icons.verified_user_outlined,
              title: 'Built on Trust',
              message: 'Transparent. Secure. Verifiable.',
            ),
            const Spacer(),
            FishTracePrimaryButton(
              label: 'Get Started',
              onPressed: () async {
                final complete = await Get.find<AuthenticationController>()
                    .onboardingComplete;
                if (!context.mounted) return;
                context.go(complete ? AppRoute.login : AppRoute.onboarding);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _Feature extends StatelessWidget {
  const _Feature({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .09),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: FishTraceColors.aqua, size: 20),
        ),
        const SizedBox(width: FishTraceSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: .72),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
