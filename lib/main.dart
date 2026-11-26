import 'package:flutter/material.dart';

import 'data/mock_school_data.dart';
import 'models/school_models.dart';
import 'screens/grades_screen.dart';
import 'screens/home_screen.dart';
import 'screens/homework_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/schedule_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/shared_widgets.dart';

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
      themeAnimationDuration: const Duration(milliseconds: 220),
      themeAnimationCurve: Curves.easeOutCubic,
      home: _AppShell(
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
    required this.tabIndex,
    required this.onTabSelected,
    required this.homeworks,
    required this.onToggleHomework,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final int tabIndex;
  final ValueChanged<int> onTabSelected;
  final List<HomeworkItem> homeworks;
  final ValueChanged<String> onToggleHomework;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    final pendingHomeworks =
        homeworks.where((homework) => !homework.isCompleted).length;

    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: [
          HomeScreen(
            homeworks: homeworks,
            onNavigate: onTabSelected,
          ),
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
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: tabIndex,
        onSelected: onTabSelected,
        homeworkBadge: pendingHomeworks,
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

/// Five-tab student navigation with a highlighter indicator and no material
/// navigation strip.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.homeworkBadge = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int homeworkBadge;

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Главная',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
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
      color: context.appSurface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.appBorder)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var index = 0; index < _items.length; index++)
                  Expanded(
                    child: _NavButton(
                      item: _items[index],
                      selected: selectedIndex == index,
                      badge: index == 3 ? homeworkBadge : 0,
                      onTap: () => onSelected(index),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
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
    final color = selected ? context.appPrimary : context.appMuted;
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 7, bottom: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration:
                    appMotion(context, const Duration(milliseconds: 160)),
                curve: Curves.easeOutCubic,
                width: selected ? 20 : 8,
                height: 3,
                decoration: BoxDecoration(
                  color: selected ? context.appAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 6),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    selected ? item.selectedIcon : item.icon,
                    size: 22,
                    color: color,
                  ),
                  if (badge > 0)
                    Positioned(
                      top: -5,
                      right: -9,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 16),
                        height: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: context.appAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '$badge',
                          style: TextStyle(
                            fontFamily: AppText.bodyFamily,
                            fontSize: 10,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentInk,
                            fontFeatures: AppText.tabular,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppText.bodyFamily,
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: -0.1,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
