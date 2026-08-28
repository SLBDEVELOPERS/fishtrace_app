import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/fishtrace_colors.dart';
import '../../../../app/theme/fishtrace_dimensions.dart';
import '../../../../core/widgets/fishtrace_widgets.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/common_controller.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommonController>();
    return FishTraceScaffold(
      appBar: FishTraceAppBar(
        title: 'Help & Support',
        teal: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.helpLoading.value) {
          return const LoadingState(message: 'Loading help…');
        }
        final articles = controller.filteredHelpArticles;
        return ListView(
          padding: const EdgeInsets.all(FishTraceSpacing.md),
          children: [
            Text(
              'How can we help?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: FishTraceSpacing.sm),
            FishTraceSearchField(
              hint: 'Search help articles',
              onChanged: (value) => controller.searchQuery.value = value,
            ),
            if (articles.isEmpty)
              const SizedBox(
                height: 380,
                child: EmptyState(
                  title: 'No help articles found',
                  message: 'Try a different search phrase.',
                  icon: Icons.search_off,
                ),
              )
            else
              for (final category
                  in articles.map((item) => item.category).toSet()) ...[
                SectionHeader(title: category),
                FishTraceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final article in articles.where(
                        (item) => item.category == category,
                      ))
                        _HelpTile(
                          article: article,
                          onTap: () => _openArticle(context, article),
                        ),
                    ],
                  ),
                ),
              ],
            const SizedBox(height: FishTraceSpacing.md),
            FishTraceSecondaryButton(
              label: 'Report an Issue',
              icon: Icons.bug_report_outlined,
              onPressed: () => _reportIssue(context, controller),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _openArticle(
    BuildContext context,
    HelpArticle article,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(article.subtitle),
            const SizedBox(height: 16),
            Text(
              article.title == 'Video Tutorials'
                  ? 'Video tutorials are provided by the configured content service in API mode.'
                  : 'This guide explains the workflow with concise, role-specific steps. Content can be updated remotely through the FishTrace support API.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _reportIssue(
    BuildContext context,
    CommonController controller,
  ) async {
    final formKey = GlobalKey<FormState>();
    final subject = TextEditingController();
    final description = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report an Issue',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              FishTraceTextField(
                label: 'Subject',
                controller: subject,
                required: true,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Subject is required'
                    : null,
              ),
              const SizedBox(height: 12),
              FishTraceTextField(
                label: 'Description',
                controller: description,
                required: true,
                maxLines: 4,
                validator: (value) => (value?.trim().length ?? 0) < 10
                    ? 'Add at least ten characters'
                    : null,
              ),
              const SizedBox(height: 16),
              Obx(
                () => FishTracePrimaryButton(
                  label: 'Submit Issue',
                  loading: controller.supportSubmitting.value,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    final success = await controller.submitIssue(
                      subject.text,
                      description.text,
                    );
                    if (success && sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                      FishTraceFeedback.success(
                        context,
                        'Support issue submitted',
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    subject.dispose();
    description.dispose();
  }
}

class _HelpTile extends StatelessWidget {
  const _HelpTile({required this.article, required this.onTap});

  final HelpArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (article.iconKey) {
      'start' => Icons.rocket_launch_outlined,
      'faq' => Icons.help_outline,
      'practice' => Icons.auto_awesome_outlined,
      'contact' => Icons.support_agent,
      'guide' => Icons.menu_book_outlined,
      _ => Icons.play_circle_outline,
    };
    return ListTile(
      minTileHeight: 62,
      leading: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: FishTraceColors.oceanLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: FishTraceColors.primary, size: 20),
      ),
      title: Text(article.title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(
        article.subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
