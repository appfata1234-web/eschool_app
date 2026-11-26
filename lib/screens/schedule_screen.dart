import 'package:flutter/material.dart';

import '../data/mock_school_data.dart';
import '../models/school_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Weekly timetable with day switching and detailed lesson sheets.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({
    super.key,
    required this.homeworks,
    required this.onOpenHomework,
  });

  final List<HomeworkItem> homeworks;
  final VoidCallback onOpenHomework;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final todayIndex =
        MockSchoolData.weekSchedule.indexWhere((day) => day.isToday);
    _selectedIndex = todayIndex >= 0 ? todayIndex : 0;
  }

  DaySchedule get _selectedDay => MockSchoolData.weekSchedule[_selectedIndex];

  HomeworkItem? _homeworkFor(LessonItem lesson) {
    if (lesson.homeworkId == null) return null;
    for (final homework in widget.homeworks) {
      if (homework.id == lesson.homeworkId) return homework;
    }
    return null;
  }

  void _openLessonDetails(LessonItem lesson) {
    final homework = _homeworkFor(lesson);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.44),
      builder: (sheetContext) => _LessonDetailSheet(
        lesson: lesson,
        day: _selectedDay,
        homework: homework,
        onOpenHomework: homework == null
            ? null
            : () {
                Navigator.of(sheetContext).pop();
                widget.onOpenHomework();
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = _selectedDay;

    return AppPage(
      children: [
        const PageHeader(
          title: 'Расписание',
          meta: 'Учебная неделя · 23–28 ноября',
        ),
        const SizedBox(height: 20),
        _WeekStrip(
          selectedIndex: _selectedIndex,
          onSelected: (index) => setState(() => _selectedIndex = index),
        ),
        const SizedBox(height: 22),
        _DayIntro(day: day),
        const SizedBox(height: 24),
        SectionHeading(
          title: day.isToday
              ? 'Сегодняшние уроки'
              : 'Уроки · ${day.weekdayFull}',
        ),
        const SizedBox(height: 10),
        if (day.lessons.isEmpty)
          const EmptyState(
            icon: Icons.free_breakfast_outlined,
            title: 'Уроков нет',
            message: 'На этот день занятия не запланированы.',
          )
        else
          _LessonTimeline(
            lessons: day.lessons,
            onOpen: _openLessonDetails,
          ),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (var index = 0;
              index < MockSchoolData.weekSchedule.length;
              index++)
            Expanded(
              child: _DayCell(
                day: MockSchoolData.weekSchedule[index],
                selected: selectedIndex == index,
                first: index == 0,
                onTap: () => onSelected(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.first,
    required this.onTap,
  });

  final DaySchedule day;
  final bool selected;
  final bool first;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : context.appInk;
    return Semantics(
      selected: selected,
      button: true,
      label: '${day.weekdayFull}, ${day.dayNumber}',
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? context.appHero : Colors.transparent,
            border: first
                ? null
                : Border(
                    left: BorderSide(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.16)
                          : context.appBorder,
                    ),
                  ),
          ),
          child: Column(
            children: [
              Text(
                day.weekdayShort,
                style: AppText.small(
                  selected
                      ? Colors.white.withValues(alpha: 0.72)
                      : context.appMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${day.dayNumber}',
                style: AppText.body(
                  foreground,
                  weight: FontWeight.w700,
                ).copyWith(
                  fontSize: 18,
                  height: 1.1,
                  fontFeatures: AppText.tabular,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: !day.isToday
                      ? Colors.transparent
                      : selected
                          ? context.appAccent
                          : context.appPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayIntro extends StatelessWidget {
  const _DayIntro({required this.day});

  final DaySchedule day;

  @override
  Widget build(BuildContext context) {
    final first = day.lessons.isEmpty ? null : day.lessons.first;
    final last = day.lessons.isEmpty ? null : day.lessons.last;
    final count = day.lessons.length;
    final countLabel =
        '$count ${count == 1 ? 'урок' : count >= 2 && count <= 4 ? 'урока' : 'уроков'}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${day.dayNumber}',
          style: AppText.display(context.appInk, size: 54),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day.weekdayFull, style: AppText.section(context.appInk)),
              const SizedBox(height: 4),
              Text(
                day.dateLabel,
                style: AppText.small(context.appMuted),
              ),
            ],
          ),
        ),
        if (first != null && last != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                countLabel,
                style: AppText.small(
                  context.appInk,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${first.startTime}–${last.endTime}',
                style: AppText.small(context.appMuted).copyWith(
                  fontFeatures: AppText.tabular,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _LessonTimeline extends StatelessWidget {
  const _LessonTimeline({
    required this.lessons,
    required this.onOpen,
  });

  final List<LessonItem> lessons;
  final ValueChanged<LessonItem> onOpen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < lessons.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                indent: 78,
                color: context.appBorder,
              ),
            _LessonRow(
              lesson: lessons[index],
              onTap: () => onOpen(lessons[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.onTap});

  final LessonItem lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subject = MockSchoolData.subjectById(lesson.subjectId);
    final accent = context.isDark
        ? Color.lerp(subject.color, Colors.white, 0.35)!
        : subject.color;
    final hasHomework = lesson.homeworkId != null;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: lesson.isCurrent ? context.appPrimarySoft : Colors.transparent,
          border: lesson.isCurrent
              ? Border(left: BorderSide(color: context.appPrimary, width: 3))
              : null,
        ),
        padding: EdgeInsets.fromLTRB(lesson.isCurrent ? 13 : 16, 15, 14, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.startTime,
                    style: AppText.small(
                      context.appInk,
                      weight: FontWeight.w600,
                    ).copyWith(fontFeatures: AppText.tabular),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lesson.endTime,
                    style: AppText.small(context.appMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lesson.isCurrent ? context.appPrimary : accent,
                  border: Border.all(
                    color: lesson.isCurrent
                        ? context.appPrimary
                        : context.appSurface,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subject.shortName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(
                            context.appInk,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (lesson.isDone)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: context.appMuted,
                          ),
                        ),
                      if (lesson.grade != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: GradeMark(
                            value: lesson.grade!.value,
                            size: 29,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.topic,
                    style: AppText.small(
                      context.appMuted,
                      weight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 14,
                    runSpacing: 4,
                    children: [
                      MetaLine(
                        icon: Icons.room_outlined,
                        text: lesson.room,
                      ),
                      MetaLine(
                        icon: Icons.person_outline_rounded,
                        text: subject.teacher,
                      ),
                      if (hasHomework)
                        MetaLine(
                          icon: Icons.assignment_outlined,
                          text: 'Задание',
                          color: context.appPrimary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: context.appMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonDetailSheet extends StatelessWidget {
  const _LessonDetailSheet({
    required this.lesson,
    required this.day,
    required this.homework,
    required this.onOpenHomework,
  });

  final LessonItem lesson;
  final DaySchedule day;
  final HomeworkItem? homework;
  final VoidCallback? onOpenHomework;

  @override
  Widget build(BuildContext context) {
    final subject = MockSchoolData.subjectById(lesson.subjectId);
    final grade = lesson.grade;
    final homeworkItem = homework;

    return AppSheet(
      children: [
        SheetHeader(
          title: subject.name,
          subtitle: '${day.weekdayFull}, ${day.dateLabel}',
          leading: SubjectMark(
            color: subject.color,
            icon: subject.icon,
          ),
        ),
        const SizedBox(height: 18),
        if (lesson.isCurrent) ...[
          StatusLabel(label: 'Идёт сейчас', color: context.appPrimary),
          const SizedBox(height: 10),
        ],
        Text(
          lesson.topic,
          style: AppText.body(context.appInk, weight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        InfoRow(
          label: 'Время',
          value: '${lesson.startTime}–${lesson.endTime}',
        ),
        InfoRow(label: 'Кабинет', value: lesson.room),
        InfoRow(label: 'Преподаватель', value: subject.teacher),
        if (grade != null)
          InfoRow(
            label: 'Оценка',
            value: '${grade.value} · ${grade.workType}',
          ),
        if (lesson.lessonNote != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.appSurfaceAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: context.appMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lesson.lessonNote!,
                    style: AppText.small(context.appMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        Text('Домашнее задание', style: AppText.section(context.appInk)),
        const SizedBox(height: 8),
        if (homeworkItem != null) ...[
          Text(
            homeworkItem.title,
            style: AppText.body(context.appInk, weight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            '${homeworkItem.dueDateLabel} · '
            '${homeworkItem.estimatedMinutes} мин',
            style: AppText.small(context.appMuted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onOpenHomework,
              child: const Text('Открыть задание'),
            ),
          ),
        ] else
          Text(
            'На этот урок задание не задано.',
            style: AppText.small(context.appMuted),
          ),
      ],
    );
  }
}
