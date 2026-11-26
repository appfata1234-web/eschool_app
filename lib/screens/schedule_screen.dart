import 'package:flutter/material.dart';

import '../data/mock_school_data.dart';
import '../models/school_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Weekly timetable with an open weekday rail and numbered lesson blocks.
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
    final todayIndex = MockSchoolData.weekSchedule.indexWhere(
      (day) => day.isToday,
    );
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                'Расписание',
                style: AppText.pageTitle(context.appInk),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '23–28 ноября',
              style: AppText.small(context.appMuted)
                  .copyWith(fontFeatures: AppText.tabular),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.gap),
        _WeekStrip(
          selectedIndex: _selectedIndex,
          onSelected: (index) => setState(() => _selectedIndex = index),
        ),
        const SizedBox(height: AppSpacing.gap),
        _DaySummaryHeader(day: day),
        const SizedBox(height: AppSpacing.gap),
        if (day.lessons.isEmpty)
          const EmptyState(
            icon: Icons.free_breakfast_outlined,
            title: 'Уроков нет',
            message: 'На этот день занятия не запланированы.',
          )
        else
          _LessonTimeline(lessons: day.lessons, onOpen: _openLessonDetails),
      ],
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2, bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.appBorder)),
      ),
      child: Row(
        children: [
          for (
            var index = 0;
            index < MockSchoolData.weekSchedule.length;
            index++
          ) ...[
            if (index > 0) const SizedBox(width: 4),
            Expanded(
              child: _DayCell(
                day: MockSchoolData.weekSchedule[index],
                selected: selectedIndex == index,
                onTap: () => onSelected(index),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DaySchedule day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onInk = context.appOnInk;
    final foreground = selected ? onInk : context.appInk;
    final weekdayColor = selected
        ? onInk.withValues(alpha: 0.72)
        : context.appMuted;

    return Semantics(
      selected: selected,
      button: true,
      label: '${day.weekdayFull}, ${day.dayNumber}',
      child: Material(
        color: selected ? context.appInk : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.weekdayShort,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small(weekdayColor, weight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${day.dayNumber}',
                    style: AppText.body(foreground, weight: FontWeight.w700)
                        .copyWith(
                          fontSize: 16,
                          height: 1.1,
                          fontFeatures: AppText.tabular,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !day.isToday
                          ? Colors.transparent
                          : selected
                          ? onInk
                          : context.appInk,
                    ),
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

class _DaySummaryHeader extends StatelessWidget {
  const _DaySummaryHeader({required this.day});

  final DaySchedule day;

  @override
  Widget build(BuildContext context) {
    final first = day.lessons.isEmpty ? null : day.lessons.first;
    final last = day.lessons.isEmpty ? null : day.lessons.last;
    final count = day.lessons.length;
    final countLabel =
        '$count ${count == 1
            ? 'урок'
            : count >= 2 && count <= 4
            ? 'урока'
            : 'уроков'}';
    final title = day.isToday
        ? 'Сегодняшние уроки'
        : '${day.weekdayFull}, ${day.dateLabel}';

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 4,
        children: [
          Text(title, style: AppText.section(context.appInk)),
          if (first != null && last != null)
            Text(
              '$countLabel · ${first.startTime}–${last.endTime}',
              style: AppText.small(context.appMuted)
                  .copyWith(fontFeatures: AppText.tabular),
            ),
        ],
      ),
    );
  }
}

class _LessonTimeline extends StatelessWidget {
  const _LessonTimeline({required this.lessons, required this.onOpen});

  final List<LessonItem> lessons;
  final ValueChanged<LessonItem> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < lessons.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          _LessonRow(
            lesson: lessons[index],
            onTap: () => onOpen(lessons[index]),
          ),
        ],
      ],
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
    final hasHomework = lesson.homeworkId != null;
    final isWide = MediaQuery.sizeOf(context).width >= AppSpacing.wide;

    final Color blockBackground;
    final Color borderColor;
    final double borderWidth;
    if (lesson.isCurrent) {
      blockBackground = context.appSurface;
      borderColor = context.appInk;
      borderWidth = 1.5;
    } else if (lesson.isDone) {
      blockBackground = context.appSurface;
      borderColor = Colors.transparent;
      borderWidth = 1;
    } else {
      blockBackground = context.appBackground;
      borderColor = context.appBorder;
      borderWidth = 1;
    }

    final Color slotBg;
    final Color slotFg;
    if (lesson.isCurrent) {
      slotBg = context.appInk;
      slotFg = context.appOnInk;
    } else if (lesson.isDone) {
      slotBg = context.appBackground;
      slotFg = context.appMuted;
    } else {
      slotBg = context.appSurfaceAlt;
      slotFg = context.appInk;
    }

    final timeLabel = lesson.isCurrent
        ? '${lesson.startTime}–${lesson.endTime} · Сейчас'
        : '${lesson.startTime}–${lesson.endTime}';
    final roomLabel = isWide
        ? '${lesson.room} · ${subject.teacher}'
        : lesson.room;

    return Semantics(
      button: true,
      label:
          '${lesson.order} урок, ${subject.name}, ${lesson.startTime}–${lesson.endTime}, ${lesson.room}',
      child: Material(
        color: blockBackground,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              if (lesson.isCurrent)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: ColoredBox(color: context.appInk),
                ),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSpacing.touch),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    lesson.isCurrent ? 14 : AppSpacing.gap,
                    11,
                    AppSpacing.gap,
                    11,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: slotBg,
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.chip,
                                    ),
                                  ),
                                  child: Text(
                                    '${lesson.order}',
                                    style:
                                        AppText.small(
                                          slotFg,
                                          weight: FontWeight.w700,
                                        ).copyWith(
                                          height: 1.1,
                                          fontFeatures: AppText.tabular,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Flexible(
                                  child: Text(
                                    timeLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.small(
                                      lesson.isCurrent
                                          ? context.appInk
                                          : context.appMuted,
                                      weight: FontWeight.w600,
                                    ).copyWith(fontFeatures: AppText.tabular),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasHomework ||
                              lesson.grade != null ||
                              lesson.isDone) ...[
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasHomework)
                                  Text(
                                    'ДЗ',
                                    style: AppText.small(
                                      context.appInk,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                if (hasHomework &&
                                    (lesson.grade != null || lesson.isDone))
                                  const SizedBox(width: 8),
                                if (lesson.grade != null)
                                  GradeMark(
                                    value: lesson.grade!.value,
                                    size: 24,
                                  )
                                else if (lesson.isDone)
                                  Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: context.appMuted,
                                    semanticLabel: 'Завершён',
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              subject.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.body(
                                context.appInk,
                                weight: FontWeight.w700,
                              ).copyWith(height: 1.25),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            roomLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.small(context.appMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.topic,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.small(
                          context.appMuted,
                          weight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
          leading: SubjectMark(icon: subject.icon),
        ),
        const SizedBox(height: 18),
        if (lesson.isCurrent) ...[
          StatusLabel(label: 'Идёт сейчас', color: context.appInk),
          const SizedBox(height: 10),
        ],
        Text(
          lesson.topic,
          style: AppText.body(context.appInk, weight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        InfoRow(label: 'Время', value: '${lesson.startTime}–${lesson.endTime}'),
        InfoRow(label: 'Кабинет', value: lesson.room),
        InfoRow(label: 'Преподаватель', value: subject.teacher),
        if (grade != null)
          InfoRow(label: 'Оценка', value: '${grade.value} · ${grade.workType}'),
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
