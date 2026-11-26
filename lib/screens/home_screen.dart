import 'package:flutter/material.dart';

import '../data/mock_school_data.dart';
import '../models/school_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Student launchpad: the current lesson, a compact day, and next actions.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.homeworks,
    required this.onNavigate,
  });
  final List<HomeworkItem> homeworks;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final student = MockSchoolData.student;
    final today = MockSchoolData.weekSchedule.firstWhere((day) => day.isToday);
    final current = today.lessons.firstWhere(
      (lesson) => lesson.isCurrent,
      orElse: () => today.lessons.first,
    );
    final pending = homeworks.where((item) => !item.isCompleted).toList();
    return AppPage(
      children: [
        PageHeader(
          title: 'Добрый день, ${student.shortName}',
          meta:
              '${today.weekdayFull}, ${today.dateLabel} · ${student.gradeClass}',
          trailing: InitialsAvatar(
            initials: student.initials,
            onTap: () => onNavigate(4),
          ),
        ),
        const SizedBox(height: AppSpacing.section),
        LayoutBuilder(
          builder: (context, constraints) {
            final focus = _LessonFocus(
              lesson: current,
              onTap: () => onNavigate(1),
            );
            final grades = _GradesSnapshot(
              onTap: () => onNavigate(2),
              wide: constraints.maxWidth >= AppSpacing.medium,
            );
            final day = _DayStrip(day: today, onTap: () => onNavigate(1));
            final tasks = _HomeworkPreview(
              items: pending,
              onTap: () => onNavigate(3),
            );
            if (constraints.maxWidth >= AppSpacing.medium) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: focus),
                        const SizedBox(width: AppSpacing.section),
                        Expanded(flex: 2, child: grades),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  day,
                  const SizedBox(height: AppSpacing.section),
                  tasks,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                focus,
                const SizedBox(height: 14),
                day,
                const SizedBox(height: 14),
                tasks,
                const SizedBox(height: 14),
                grades,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LessonFocus extends StatelessWidget {
  const _LessonFocus({required this.lesson, required this.onTap});
  final LessonItem lesson;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final subject = MockSchoolData.subjectById(lesson.subjectId);
    const ink = AppColors.panelInk;
    const muted = AppColors.panelMuted;
    return Material(
      color: context.appHero,
      borderRadius: BorderRadius.circular(AppRadii.focus),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: context.isDark
              ? const BoxDecoration(
                  border: Border(left: BorderSide(color: ink, width: 4)),
                )
              : null,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  const StatusLabel(label: 'Сейчас идёт', color: ink),
                  Text(
                    '${lesson.startTime}–${lesson.endTime}',
                    style: AppText.small(muted)
                        .copyWith(fontFeatures: AppText.tabular),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      subject.shortName,
                      style: AppText.pageTitle(ink).copyWith(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Text(lesson.room, style: AppText.small(ink)),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                lesson.topic,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(ink),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(subject.teacher, style: AppText.small(muted)),
                  ),
                  Text(
                    'Урок',
                    style: AppText.small(ink, weight: FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, color: ink, size: 16),
                ],
              ),
              if (lesson.lessonNote != null) ...[
                const SizedBox(height: 8),
                Text(
                  lesson.lessonNote!,
                  style: AppText.small(muted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip({required this.day, required this.onTap});
  final DaySchedule day;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final currentIndex = day.lessons.indexWhere((lesson) => lesson.isCurrent);
    final next = currentIndex >= 0 && currentIndex + 1 < day.lessons.length
        ? day.lessons[currentIndex + 1]
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(
          title: 'Сегодняшние уроки',
          actionLabel: 'Расписание',
          onAction: onTap,
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(13) / 13;
            final minimum = 60.0 * scale;
            final natural = day.lessons.isEmpty
                ? constraints.maxWidth
                : (constraints.maxWidth - (day.lessons.length - 1) * 6) /
                      day.lessons.length;
            final width = natural < minimum ? minimum : natural;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < day.lessons.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    _DaySlot(
                      lesson: day.lessons[i],
                      width: width,
                      onTap: onTap,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        if (next != null)
          Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Text(
              'Далее: ${MockSchoolData.subjectById(next.subjectId).shortName}'
              ' · ${next.room} · ${next.startTime}–${next.endTime}',
              style: AppText.small(context.appMuted),
            ),
          ),
      ],
    );
  }
}

class _DaySlot extends StatelessWidget {
  const _DaySlot({
    required this.lesson,
    required this.width,
    required this.onTap,
  });
  final LessonItem lesson;
  final double width;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final subject = MockSchoolData.subjectById(lesson.subjectId);
    final active = lesson.isCurrent;
    final ink = active ? context.appOnInk : context.appInk;
    return SizedBox(
      width: width,
      child: Semantics(
        label: '${subject.name}, ${lesson.startTime}',
        selected: active,
        button: true,
        child: Material(
          color: active ? context.appInk : context.appSurface,
          borderRadius: BorderRadius.circular(AppRadii.input),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.input),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 22),
                    child: lesson.grade != null
                        ? GradeMark(
                            value: lesson.grade!.value,
                            size: 26,
                            onInk: active,
                          )
                        : Center(
                            child: Text(
                              lesson.isDone ? '✓' : '№ ${lesson.order}',
                              style: AppText.small(
                                ink,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subject.shortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small(ink, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lesson.startTime,
                    style: AppText.small(active ? ink : context.appMuted)
                        .copyWith(fontSize: 12, fontFeatures: AppText.tabular),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeworkPreview extends StatelessWidget {
  const _HomeworkPreview({required this.items, required this.onTap});
  final List<HomeworkItem> items;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final preview = items.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(
          title: 'Задания к сдаче',
          actionLabel: items.length < 2
              ? 'Все задания'
              : 'Все ${items.length} в работе',
          onAction: onTap,
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Все задания выполнены',
              style: AppText.body(context.appMuted),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= AppSpacing.medium) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < preview.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(
                          child: _TaskPreview(
                            item: preview[i],
                            onTap: onTap,
                            wide: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (final item in preview)
                    _TaskPreview(
                      key: ValueKey(item.id),
                      item: item,
                      onTap: onTap,
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _TaskPreview extends StatelessWidget {
  const _TaskPreview({
    super.key,
    required this.item,
    required this.onTap,
    this.wide = false,
  });
  final HomeworkItem item;
  final VoidCallback onTap;
  final bool wide;
  @override
  Widget build(BuildContext context) {
    final subject = MockSchoolData.subjectById(item.subjectId);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                subject.shortName,
                style: AppText.small(context.appMuted, weight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.dueDateLabel,
                textAlign: TextAlign.end,
                style: AppText.small(
                  item.isUrgent ? context.appError : context.appMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppText.body(context.appInk, weight: FontWeight.w500),
        ),
      ],
    );
    return Material(
      color: wide ? context.appSurface : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 14 : 0,
            vertical: 10,
          ),
          decoration: wide
              ? null
              : BoxDecoration(
                  border: Border(bottom: BorderSide(color: context.appBorder)),
                ),
          child: content,
        ),
      ),
    );
  }
}

class _GradesSnapshot extends StatelessWidget {
  const _GradesSnapshot({required this.onTap, this.wide = false});
  final VoidCallback onTap;
  final bool wide;
  @override
  Widget build(BuildContext context) {
    final student = MockSchoolData.student;
    final marks = MockSchoolData.weekSchedule
        .expand((day) => day.lessons)
        .where((lesson) => lesson.grade != null)
        .toList();
    final recent =
        MockSchoolData.grades.where((entry) => entry.quarter == 2).toList()
          // Current-quarter demo entries all use November day labels.
          ..sort(
            (a, b) => (int.tryParse(b.dateLabel.split(' ').first) ?? 0)
                .compareTo(int.tryParse(a.dateLabel.split(' ').first) ?? 0),
          );
    final average = student.averageGpa.toStringAsFixed(2).replaceAll('.', ',');
    final trend = MockSchoolData.gpaTrend;
    final delta = trend.length > 1 ? trend.last - trend[trend.length - 2] : 0.0;
    final deltaLabel =
        '${delta >= 0 ? '+' : '−'}'
        '${delta.abs().toStringAsFixed(2).replaceAll('.', ',')}';
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Средний балл',
                      style: AppText.small(context.appMuted),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          average,
                          style: AppText.display(context.appInk, size: 25),
                        ),
                        Text(
                          deltaLabel,
                          style: AppText.small(
                            delta < 0 ? context.appError : context.appMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Последняя оценка',
                      style: AppText.small(context.appMuted),
                    ),
                    const SizedBox(height: 5),
                    if (marks.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              MockSchoolData.subjectById(marks.last.subjectId)
                                  .shortName,
                              style: AppText.small(
                                context.appInk,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GradeMark(value: marks.last.grade!.value, size: 28),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (wide) ...[
            const SizedBox(height: 16),
            Divider(color: context.appBorder),
            for (final entry in recent.take(3))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MockSchoolData.subjectById(entry.subjectId)
                                .shortName,
                            style: AppText.small(
                              context.appInk,
                              weight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${entry.workType} · ${entry.dateLabel}',
                            style: AppText.small(context.appMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GradeMark(value: entry.value, size: 28),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
