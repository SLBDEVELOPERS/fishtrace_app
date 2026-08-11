import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/data/repositories.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../domain/entities/mobile_settings.dart';
import '../../domain/repositories/profile_repository.dart';
import '../controllers/mobile_settings_controller.dart';
import '../widgets/role_bottom_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<AppController>();
    final repository = Get.find<ProfileRepository>();
    final settingsController = Get.find<MobileSettingsController>();
    return Obx(() {
      final user = session.user.value;
      final settings = settingsController.settings.value;
      if (user == null) {
        return const FishTraceScaffold(
          body: LoadingState(message: 'Loading profile…'),
        );
      }
      return FishTraceScaffold(
        backgroundColor: FishTraceColors.surface,
        bottomNavigation: RoleBottomBar(role: user.role, selectedIndex: 3),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FishTraceColors.primaryDark,
                    FishTraceColors.primary,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 37,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.name
                                .split(' ')
                                .take(2)
                                .map((word) => word[0])
                                .join(),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: FishTraceColors.primary),
                          ),
                        ),
                        Positioned(
                          right: -3,
                          bottom: -2,
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: const BoxDecoration(
                              color: FishTraceColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 15,
                              color: FishTraceColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: FishTraceSpacing.sm),
                    Text(
                      user.name,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    Text(
                      user.role.name[0].toUpperCase() +
                          user.role.name.substring(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: .85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: .72),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    onTap: () => _editPersonalInformation(
                      context,
                      session,
                      repository,
                      user,
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.business_outlined,
                    title: 'Business Information',
                    onTap: () => _showInformation(
                      context,
                      'Business Information',
                      _businessInformation(user.organization),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.shield_outlined,
                    title: 'Security',
                    onTap: () => context.push(AppRoute.recovery),
                  ),
                  _SettingsTile(
                    icon: Icons.tune,
                    title: 'Preferences',
                    trailing: settings.compactDashboard
                        ? 'Compact'
                        : 'Standard',
                    onTap: () => _showPreferences(context, settingsController),
                  ),
                  _SettingsTile(
                    icon: Icons.straighten,
                    title: 'Units & Measurements',
                    trailing: settings.measurementLabel,
                    onTap: () =>
                        _showMeasurementSystems(context, settingsController),
                  ),
                  _SettingsTile(
                    icon: Icons.language,
                    title: 'Language',
                    trailing: settings.languageLabel,
                    onTap: () => _showLanguages(context, settingsController),
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notification Settings',
                    trailing: _notificationSummary(settings),
                    onTap: () =>
                        _showNotificationSettings(context, settingsController),
                  ),
                  const Divider(height: 18),
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () => context.push(AppRoute.support),
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About FishTrace',
                    onTap: () => _showInformation(
                      context,
                      'About FishTrace',
                      'FishTrace 1.0.0\nTrace Every Fish. Trust Every Step.',
                    ),
                  ),
                  const Divider(height: 18),
                  _SettingsTile(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    destructive: true,
                    onTap: () => _confirmLogout(context, session),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _editPersonalInformation(
    BuildContext context,
    AppController session,
    ProfileRepository repository,
    User currentUser,
  ) async {
    final name = TextEditingController(text: currentUser.name);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Personal Information'),
        content: FishTraceTextField(
          label: 'Full name',
          controller: name,
          required: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final normalizedName = name.text.trim();
              if (normalizedName.isEmpty) return;
              final updated = await repository.updateProfile(
                name: normalizedName,
                email: currentUser.email,
              );
              session.user.value = updated;
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Personal information saved')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    name.dispose();
  }

  String _businessInformation(UserOrganization? organization) {
    if (organization == null) return 'No organization is assigned.';
    return [
      organization.name,
      if (organization.code.isNotEmpty) 'Code: ${organization.code}',
      if (organization.type.isNotEmpty) 'Type: ${organization.type}',
      'Status: ${organization.active ? 'Active' : 'Inactive'}',
    ].join('\n');
  }

  Future<void> _showInformation(
    BuildContext context,
    String title,
    String message,
  ) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  String _notificationSummary(MobileSettings settings) {
    final enabled = [
      settings.temperatureAlerts,
      settings.workflowUpdates,
      settings.systemMessages,
    ].where((value) => value).length;
    return '$enabled of 3';
  }

  Future<void> _showPreferences(
    BuildContext context,
    MobileSettingsController controller,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Obx(() {
          final settings = controller.settings.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferences',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Compact dashboard'),
                value: settings.compactDashboard,
                onChanged: (value) =>
                    controller.save(settings.copyWith(compactDashboard: value)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use device theme'),
                value: settings.useDeviceTheme,
                onChanged: (value) =>
                    controller.save(settings.copyWith(useDeviceTheme: value)),
              ),
            ],
          );
        }),
      ),
    ),
  );

  Future<void> _showMeasurementSystems(
    BuildContext context,
    MobileSettingsController controller,
  ) => _showSingleChoice<MeasurementSystem>(
    context: context,
    title: 'Units & Measurements',
    values: MeasurementSystem.values,
    selected: () => controller.settings.value.measurementSystem,
    label: (value) => switch (value) {
      MeasurementSystem.metric => 'Metric (kg, km)',
      MeasurementSystem.imperial => 'Imperial (lb, mi)',
    },
    onSelected: (value) => controller.save(
      controller.settings.value.copyWith(measurementSystem: value),
    ),
  );

  Future<void> _showLanguages(
    BuildContext context,
    MobileSettingsController controller,
  ) => _showSingleChoice<MobileLanguage>(
    context: context,
    title: 'Language',
    values: MobileLanguage.values,
    selected: () => controller.settings.value.language,
    label: (value) => switch (value) {
      MobileLanguage.english => 'English',
      MobileLanguage.sinhala => 'සිංහල',
      MobileLanguage.tamil => 'தமிழ்',
    },
    onSelected: (value) =>
        controller.save(controller.settings.value.copyWith(language: value)),
  );

  Future<void> _showSingleChoice<T>({
    required BuildContext context,
    required String title,
    required List<T> values,
    required T Function() selected,
    required String Function(T value) label,
    required Future<void> Function(T value) onSelected,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final value in values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(label(value)),
                trailing: value == selected()
                    ? const Icon(Icons.check, color: FishTraceColors.primary)
                    : null,
                onTap: () async {
                  await onSelected(value);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    ),
  );

  Future<void> _showNotificationSettings(
    BuildContext context,
    MobileSettingsController controller,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Obx(() {
          final settings = controller.settings.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notification Settings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Temperature alerts'),
                value: settings.temperatureAlerts,
                onChanged: (value) => controller.save(
                  settings.copyWith(temperatureAlerts: value),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Workflow updates'),
                value: settings.workflowUpdates,
                onChanged: (value) =>
                    controller.save(settings.copyWith(workflowUpdates: value)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('System messages'),
                value: settings.systemMessages,
                onChanged: (value) =>
                    controller.save(settings.copyWith(systemMessages: value)),
              ),
            ],
          );
        }),
      ),
    ),
  );

  Future<void> _confirmLogout(
    BuildContext context,
    AppController session,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Pending offline records remain on this device and can be synced after you sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: FishTraceColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      session.signOut();
      context.go(AppRoute.login);
    }
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailing;
  final bool destructive;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 48,
    leading: Icon(
      icon,
      size: 20,
      color: destructive
          ? FishTraceColors.error
          : FishTraceColors.textSecondary,
    ),
    title: Text(
      title,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: destructive ? FishTraceColors.error : null,
        fontWeight: FontWeight.w500,
      ),
    ),
    trailing: trailing == null
        ? const Icon(Icons.chevron_right, size: 18)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(trailing!, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
    onTap: onTap,
  );
}
