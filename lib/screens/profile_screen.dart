import 'package:flutter/material.dart';

import '../data/mock_school_data.dart';
import '../models/school_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Student profile with performance summary, personal details and settings.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Электронный дневник'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Версия 1.0.0',
              style: AppText.small(
                context.appPrimary,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Учебный прототип школьного дневника: расписание, оценки, '
              'домашние задания и профиль ученика в одном приложении.',
              style: AppText.body(context.appMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = MockSchoolData.student;

    return AppPage(
      children: [
        const PageHeader(
          title: 'Профиль',
          meta: 'Личный кабинет ученика',
        ),
        const SizedBox(height: 20),
        _IdentityPanel(student: student),
        const SizedBox(height: 24),
        const SectionHeading(title: 'Успеваемость'),
        const SizedBox(height: 10),
        _PerformanceCard(student: student),
        const SizedBox(height: 24),
        const SectionHeading(title: 'Данные ученика'),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Column(
            children: [
              InfoRow(
                label: 'Школа',
                value: student.schoolName,
                showDivider: true,
              ),
              InfoRow(
                label: 'Класс',
                value: student.gradeClass,
                showDivider: true,
              ),
              InfoRow(
                label: 'Баланс питания',
                value: '${student.cafeteriaBalanceRub} ₽',
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeading(title: 'Настройки'),
        const SizedBox(height: 10),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SwitchRow(
                icon: Icons.dark_mode_outlined,
                title: 'Тёмная тема',
                subtitle: 'Тёмное оформление интерфейса',
                value: widget.isDarkMode,
                onChanged: widget.onDarkModeChanged,
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: context.appBorder,
              ),
              _SwitchRow(
                icon: Icons.notifications_none_rounded,
                title: 'Уведомления',
                subtitle: 'Напоминания о домашних заданиях',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: context.appBorder,
              ),
              _AboutRow(onTap: _showAboutDialog),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Text(
            'Электронный дневник · 2026',
            style: AppText.small(context.appMuted),
          ),
        ),
      ],
    );
  }
}

class _IdentityPanel extends StatelessWidget {
  const _IdentityPanel({required this.student});

  final StudentProfile student;

  @override
  Widget build(BuildContext context) {
    final panelColor =
        context.isDark ? const Color(0xFF16223A) : const Color(0xFF0B1524);
    final softWhite = Colors.white.withValues(alpha: 0.68);

    return Container(
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(26),
        border: context.isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.08))
            : null,
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InitialsAvatar(initials: student.initials, size: 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: TextStyle(
                        fontFamily: AppText.displayFamily,
                        fontSize: 24,
                        height: 1.08,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.9,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${student.gradeClass} · ${student.schoolName}',
                      style: AppText.small(softWhite),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.16),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                color: context.appAccent,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Text(
                  student.gradeClass,
                  style: AppText.body(
                    AppColors.accentInk,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('Класс', style: AppText.small(softWhite)),
              const Spacer(),
              Text(
                'Ученик',
                style: AppText.small(Colors.white.withValues(alpha: 0.46)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.student});

  final StudentProfile student;

  @override
  Widget build(BuildContext context) {
    final average =
        student.averageGpa.toStringAsFixed(2).replaceAll('.', ',');
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Column(
        children: [
          InfoRow(
            label: 'Средний балл',
            value: average,
            showDivider: true,
          ),
          InfoRow(
            label: 'Посещаемость',
            value: '${student.attendancePercent}%',
            showDivider: true,
          ),
          InfoRow(
            label: 'Место в классе',
            value: '${student.rankInClass}-е',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.appMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.body(
                      context.appInk,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.small(context.appMuted)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IgnorePointer(
              child: Switch(
                value: value,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: context.appMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'О приложении',
                    style: AppText.body(
                      context.appInk,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Версия 1.0.0',
                    style: AppText.small(context.appMuted),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.appMuted,
            ),
          ],
        ),
      ),
    );
  }
}
