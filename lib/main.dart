import 'package:flutter/material.dart';

import 'data/mock_school_data.dart';
import 'models/school_models.dart';
import 'screens/grades_screen.dart';
import 'screens/home_screen.dart';
import 'screens/homework_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/schedule_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EschoolApp());
}

/// Root widget that owns app-wide theme mode and homework completion state.
class EschoolApp extends StatefulWidget {
  const EschoolApp({super.key});

  @override
  State<EschoolApp> createState() => _EschoolAppState();
}

class _EschoolAppState extends State<EschoolApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late List<HomeworkItem> _homeworks;
  int _tabIndex = 0;
  final _pagesKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _homeworks = List<HomeworkItem>.of(MockSchoolData.initialHomeworks);
  }

  void _toggleHomework(String id) {
    setState(() {
      _homeworks = [
        for (final homework in _homeworks)
          if (homework.id == id)
            homework.copyWith(isCompleted: !homework.isCompleted)
          else
            homework,
      ];
    });
  }

  void _selectTab(int index) {
    if (index == _tabIndex) return;
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Электронный дневник',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      themeAnimationDuration: Duration.zero,
      themeAnimationCurve: Curves.easeOutCubic,
      home: _AppShell(
        pagesKey: _pagesKey,
        tabIndex: _tabIndex,
        onTabSelected: _selectTab,
        homeworks: _homeworks,
        onToggleHomework: _toggleHomework,
        isDarkMode: _themeMode == ThemeMode.dark,
        onDarkModeChanged: (enabled) {
          setState(
            () => _themeMode = enabled ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell({
    required this.pagesKey,
    required this.tabIndex,
    required this.onTabSelected,
    required this.homeworks,
    required this.onToggleHomework,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final GlobalKey pagesKey;
  final int tabIndex;
  final ValueChanged<int> onTabSelected;
  final List<HomeworkItem> homeworks;
  final ValueChanged<String> onToggleHomework;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    final pendingHomeworks = homeworks
        .where((homework) => !homework.isCompleted)
        .length;

    final pages = IndexedStack(
      key: pagesKey,
      index: tabIndex,
      children: [
        HomeScreen(homeworks: homeworks, onNavigate: onTabSelected),
        ScheduleScreen(
          homeworks: homeworks,
          onOpenHomework: () => onTabSelected(3),
        ),
        const GradesScreen(),
        HomeworkScreen(
          homeworks: homeworks,
          onToggleHomework: onToggleHomework,
        ),
        ProfileScreen(
          isDarkMode: isDarkMode,
          onDarkModeChanged: onDarkModeChanged,
        ),
      ],
    );
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= AppSpacing.wide) {
            return Row(
              children: [
                AppNavRail(
                  selectedIndex: tabIndex,
                  onSelected: onTabSelected,
                  homeworkBadge: pendingHomeworks,
                ),
                Expanded(child: pages),
              ],
            );
          }
          return Stack(
            children: [
              Positioned.fill(child: pages),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: SafeArea(
                  top: false,
                  child: AppFloatingDock(
                    selectedIndex: tabIndex,
                    onSelected: onTabSelected,
                    homeworkBadge: pendingHomeworks,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Compact phone navigation shared with the wide workspace rail.
class AppFloatingDock extends StatelessWidget {
  const AppFloatingDock({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.homeworkBadge = 0,
  });
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int homeworkBadge;
  static const items = [
    _NavItem(
      label: 'Главная',
      icon: Icons.space_dashboard_outlined,
      selectedIcon: Icons.space_dashboard_rounded,
    ),
    _NavItem(
      label: 'Расписание',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today_rounded,
    ),
    _NavItem(
      label: 'Оценки',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
    ),
    _NavItem(
      label: 'Задания',
      icon: Icons.checklist_outlined,
      selectedIcon: Icons.checklist_rounded,
    ),
    _NavItem(
      label: 'Профиль',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.dockBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.dock),
        side: BorderSide(
          color: context.isDark
              ? context.appBorderStrong
              : context.dockBackground,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: _DockButton(
                  item: items[index],
                  selected: selectedIndex == index,
                  badge: index == 3 ? homeworkBadge : 0,
                  onTap: () => onSelected(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.item,
    required this.selected,
    required this.badge,
    required this.onTap,
  });
  final _NavItem item;
  final bool selected;
  final int badge;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final active = context.isDark ? AppColors.accent : AppColors.inkSoft;
    final background = selected ? active : context.dockBackground;
    final color = selected && context.isDark
        ? AppColors.primary
        : selected
        ? AppColors.accent
        : AppColors.darkTextSecondary;
    final showLabel = MediaQuery.textScalerOf(context).scale(12) <= 18;
    final inverseBadge = selected && context.isDark;
    return Semantics(
      selected: selected,
      button: true,
      label: badge > 0 ? '${item.label}, $badge в работе' : item.label,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSpacing.touch),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        selected ? item.selectedIcon : item.icon,
                        color: color,
                        size: 20,
                      ),
                      if (badge > 0)
                        Positioned(
                          top: -4,
                          right: -16,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: inverseBadge
                                  ? AppColors.primary
                                  : AppColors.accent,
                              border: Border.all(color: background, width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$badge',
                              textScaler: TextScaler.noScaling,
                              style: AppText.small(
                                inverseBadge
                                    ? AppColors.accent
                                    : AppColors.primary,
                                weight: FontWeight.w700,
                              ).copyWith(fontSize: 12, height: 1),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (showLabel) ...[
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.label,
                        style: AppText.small(
                          color,
                          weight: selected ? FontWeight.w700 : FontWeight.w500,
                        ).copyWith(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppNavRail extends StatelessWidget {
  const AppNavRail({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.homeworkBadge = 0,
  });
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int homeworkBadge;
  @override
  Widget build(BuildContext context) {
    final student = MockSchoolData.student;
    return Container(
      width: AppSpacing.rail,
      decoration: BoxDecoration(
        color: context.appSurface,
        border: Border(right: BorderSide(color: context.appBorder)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Text('ЭЛЕКТРОННЫЙ', style: AppText.small(context.appMuted)),
              Text('Дневник', style: AppText.pageTitle(context.appInk)),
              const SizedBox(height: 36),
              Expanded(
                child: ListView(
                  children: [
                    for (var i = 0; i < AppFloatingDock.items.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _RailDestination(
                          item: AppFloatingDock.items[i],
                          selected: selectedIndex == i,
                          badge: i == 3 ? homeworkBadge : 0,
                          onTap: () => onSelected(i),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(color: context.appBorder),
              const SizedBox(height: 12),
              Text(
                student.fullName,
                style: AppText.body(context.appInk, weight: FontWeight.w600),
              ),
              Text(student.gradeClass, style: AppText.small(context.appMuted)),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailDestination extends StatelessWidget {
  const _RailDestination({
    required this.item,
    required this.selected,
    required this.badge,
    required this.onTap,
  });
  final _NavItem item;
  final bool selected;
  final int badge;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = selected ? context.appOnInk : context.appMuted;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? context.appInk : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.input),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.input),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              children: [
                Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppText.small(color, weight: FontWeight.w600),
                  ),
                ),
                if (badge > 0) Text('$badge', style: AppText.small(color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
