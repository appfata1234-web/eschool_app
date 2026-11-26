import 'package:flutter/material.dart';

import '../data/mock_school_data.dart';
import '../models/school_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Student profile with deep-navy ID pass, open hairline details and settings.
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
              style: AppText.small(context.appInk, weight: FontWeight.w600),
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
        const PageHeader(title: 'Профиль', meta: 'Личный кабинет ученика'),
        const SizedBox(height: 16),
        _StudentIdPass(student: student),
        const SizedBox(height: AppSpacing.section),
        const SectionHeading(title: 'Данные ученика'),
        const SizedBox(height: 6),
        Divider(height: 1, color: context.appBorder),
        InfoRow(label: 'Школа', value: student.schoolName, showDivider: true),
        InfoRow(label: 'Класс', value: student.gradeClass, showDivider: true),
        InfoRow(
          label: 'Баланс питания',
          value: '${student.cafeteriaBalanceRub} ₽',
          showDivider: true,
        ),
        const SizedBox(height: AppSpacing.section),
        const SectionHeading(title: 'Настройки'),
        const SizedBox(height: 6),
        Divider(height: 1, color: context.appBorder),
        _SwitchRow(
          icon: Icons.dark_mode_outlined,
          title: 'Тёмная тема',
          subtitle: 'Тёмное оформление #011627',
          value: widget.isDarkMode,
          onChanged: widget.onDarkModeChanged,
        ),
        Divider(height: 1, color: context.appBorder),
        _SwitchRow(
          icon: Icons.notifications_none_rounded,
          title: 'Уведомления',
          subtitle: 'Напоминания о домашних заданиях',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
          },
        ),
        Divider(height: 1, color: context.appBorder),
        _AboutRow(onTap: _showAboutDialog),
        Divider(height: 1, color: context.appBorder),
        const SizedBox(height: AppSpacing.section),
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

class _StudentIdPass extends StatelessWidget {
  const _StudentIdPass({required this.student});

  final StudentProfile student;

  @override
  Widget build(BuildContext context) {
    final panelColor = context.isDark ? context.appSurface : AppColors.primary;
    final ruleColor = context.isDark ? context.appBorder : context.appInkSoft;
    const onNavyText = AppColors.accent;
    const onNavyMuted = AppColors.darkTextSecondary;
    final average = student.averageGpa.toStringAsFixed(2).replaceAll('.', ',');

    return Semantics(
      label: 'Карточка ученика и успеваемость',
      child: Container(
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(AppRadii.focus),
          border: context.isDark
              ? Border.all(color: context.appBorderStrong)
              : null,
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: AppSpacing.touch,
                  height: AppSpacing.touch,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.appInkSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.isDark
                          ? context.appBorderStrong
                          : const Color(0xFF244057),
                    ),
                  ),
                  child: Text(
                    student.initials,
                    style: AppText.section(onNavyText),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: AppText.section(onNavyText).copyWith(
                          fontSize: 19,
                          height: 1.18,
                          letterSpacing: -0.35,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${student.gradeClass} · ${student.schoolName}',
                        style: AppText.small(onNavyMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: ruleColor),
            const SizedBox(height: 11),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _IdMetric(
                    value: average,
                    label: 'Средний балл',
                    valueColor: onNavyText,
                    labelColor: onNavyMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _IdMetric(
                    value: '${student.attendancePercent}%',
                    label: 'Посещаемость',
                    valueColor: onNavyText,
                    labelColor: onNavyMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _IdMetric(
                    value: '${student.rankInClass}-е',
                    label: 'Место в классе',
                    valueColor: onNavyText,
                    labelColor: onNavyMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IdMetric extends StatelessWidget {
  const _IdMetric({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.labelColor,
  });

  final String value;
  final String label;
  final Color valueColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppText.section(
            valueColor,
          ).copyWith(fontSize: 17, height: 1.15, fontFeatures: AppText.tabular),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppText.small(labelColor)),
      ],
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
    return Semantics(
      toggled: value,
      label: '$title, $subtitle',
      child: InkWell(
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
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
                  child: Switch(value: value, onChanged: onChanged),
                ),
              ],
            ),
          ),
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
    return Semantics(
      button: true,
      label: 'О приложении, Версия 1.0.0',
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 58),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
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
        ),
      ),
    );
  }
}
