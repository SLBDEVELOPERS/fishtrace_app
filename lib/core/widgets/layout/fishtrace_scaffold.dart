import 'package:flutter/material.dart';

import '../../../app/theme/fishtrace_colors.dart';
import '../../../app/theme/fishtrace_dimensions.dart';

class FishTraceScaffold extends StatelessWidget {
  const FishTraceScaffold({
    super.key,
    required this.body,
    this.title,
    this.appBar,
    this.bottomNavigation,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final String? title;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigation;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    extendBody: extendBody,
    appBar: appBar ?? (title == null ? null : FishTraceAppBar(title: title!)),
    body: SafeArea(top: appBar == null && title == null, child: body),
    bottomNavigationBar: bottomNavigation,
    floatingActionButton: floatingActionButton,
  );
}

class FishTraceAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FishTraceAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.teal = false,
    this.bottom,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;
  final bool teal;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
    FishTraceSizes.appBar + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) => AppBar(
    leading: leading,
    title: Text(title),
    actions: actions,
    backgroundColor: teal ? FishTraceColors.primaryDark : null,
    foregroundColor: teal ? Colors.white : null,
    titleTextStyle: teal
        ? Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)
        : null,
    bottom: bottom,
  );
}

class FishTraceNavigationItem {
  const FishTraceNavigationItem({
    required this.label,
    required this.icon,
    this.badge,
  });

  final String label;
  final IconData icon;
  final int? badge;
}

class FishTraceBottomNavigation extends StatelessWidget {
  const FishTraceBottomNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.onPrimaryAction,
    this.primaryActionLabel = 'Create',
  }) : assert(items.length == 4);

  final List<FishTraceNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onPrimaryAction;
  final String primaryActionLabel;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      height: FishTraceSizes.bottomNavigation,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          _NavigationButton(
            item: items[0],
            selected: selectedIndex == 0,
            onTap: () => onSelected(0),
          ),
          _NavigationButton(
            item: items[1],
            selected: selectedIndex == 1,
            onTap: () => onSelected(1),
          ),
          Expanded(
            child: Semantics(
              button: true,
              label: primaryActionLabel,
              child: Center(
                child: InkResponse(
                  onTap: onPrimaryAction,
                  radius: 30,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: FishTraceColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.surface,
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26004B5A),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 25),
                  ),
                ),
              ),
            ),
          ),
          _NavigationButton(
            item: items[2],
            selected: selectedIndex == 2,
            onTap: () => onSelected(2),
          ),
          _NavigationButton(
            item: items[3],
            selected: selectedIndex == 3,
            onTap: () => onSelected(3),
          ),
        ],
      ),
    ),
  );
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FishTraceNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              isLabelVisible: (item.badge ?? 0) > 0,
              label: Text('${item.badge ?? 0}'),
              child: Icon(
                item.icon,
                size: 20,
                color: selected
                    ? FishTraceColors.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? FishTraceColors.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
