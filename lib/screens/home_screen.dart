import 'package:flutter/material.dart';

import '../data/mock_school_data.dart';
import '../models/school_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Dashboard with the student's day and progress summary.
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
    final currentLesson = today.lessons.firstWhere(
      (lesson) => lesson.isCurrent,
      orElse: () => today.lessons.first,
    );
    final pendingHomeworks =
        homeworks.where((homework) => !homework.isCompleted).length;

    return AppPage(
      children: [
        PageHeader(
          title: 'Добрый день, ${student.shortName}',
          meta: '${student.gradeClass} · ${student.schoolName} · '
              '${today.dateLabel}',
          trailing: InitialsAvatar(
            initials: student.initials,
            onTap: () => onNavigate(4),
          ),
        ),
        const SizedBox(height: 20),
        _GpaHero(
          pendingHomeworks: pendingHomeworks,
          lessonCount: today.lessons.length,
          student: student,
        ),
        const SizedBox(height: 24),
        const SectionHeading(title: 'Сейчас идёт'),
        const SizedBox(height: 10),
        _CurrentLessonCard(
          lesson: currentLesson,
          onTap: () => onNavigate(1),
        ),
        const SizedBox(height: 24),
        SectionHeading(
          title: 'Расписание на сегодня',
          actionLabel: 'Вся неделя',
          onAction: () => onNavigate(1),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < today.lessons.length; index++) ...[
                if (index > 0)
                  Divider(
                    color: context.appBorder,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                _TodayLessonRow(
                  lesson: today.lessons[index],
                  onTap: () => onNavigate(1),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GpaHero extends StatelessWidget {
  const _GpaHero({
    required this.pendingHomeworks,
    required this.lessonCount,
    required this.student,
  });

  final int pendingHomeworks;
  final int lessonCount;
  final StudentProfile student;

  @override
  Widget build(BuildContext context) {
    final classIn = student.gradeClass.endsWith('класс')
        ? '${student.gradeClass}е'
        : student.gradeClass;
    final average = student.averageGpa.toStringAsFixed(2).replaceAll('.', ',');
    final trend = MockSchoolData.gpaTrend;
    final delta = trend.length >= 2 ? trend.last - trend[trend.length - 2] : 0;
    final deltaLabel =
        '${delta >= 0 ? '+' : '−'}${delta.abs().toStringAsFixed(2).replaceAll('.', ',')}';
    final white = Colors.white;
    final softWhite = white.withValues(alpha: 0.76);
    final taskLabel =
        '$pendingHomeworks ${_plural(pendingHomeworks, 'задание', 'задания', 'заданий')}';
    final lessonLabel =
        '$lessonCount ${_plural(lessonCount, 'урок', 'урока', 'уроков')}';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.appHero,
            Color.lerp(context.appHero, Colors.black, 0.18)!,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GraphPaperPainter(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Средний балл',
                        style: AppText.small(
                          softWhite,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        taskLabel,
                        style: AppText.small(
                          white.withValues(alpha: 0.66),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Transform.rotate(
                        angle: -0.035,
                        child: Container(
                          color: context.appAccent,
                          padding: const EdgeInsets.fromLTRB(10, 3, 12, 5),
                          child: Text(
                            average,
                            style: AppText.display(
                              AppColors.accentInk,
                              size: 58,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('из 5,00', style: AppText.small(softWhite)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            delta >= 0
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 15,
                            color: context.appAccent,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$deltaLabel за четверть',
                            style: AppText.small(
                              context.appAccent,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${student.rankInClass}-е место в $classIn · '
                    '$lessonLabel',
                    style: AppText.small(white.withValues(alpha: 0.86)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentLessonCard extends StatelessWidget {
  const _CurrentLessonCard({required this.lesson, required this.onTap});

  final LessonItem lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subject = MockSchoolData.subjectById(lesson.subjectId);
    return AppCard(
      color: context.appAccentSoft,
      borderColor: context.appAccent.withValues(alpha: 0.7),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusLabel(
                  label: 'Сейчас',
                  color: context.appInk,
                ),
                const Spacer(),
                Text(
                  '${lesson.startTime}–${lesson.endTime}',
                  style: AppText.small(
                    context.appInk,
                    weight: FontWeight.w600,
                  ).copyWith(fontFeatures: AppText.tabular),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subject.shortName,
              style: AppText.section(context.appInk),
            ),
            const SizedBox(height: 4),
            Text(
              lesson.topic,
              style: AppText.body(context.appInk),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                MetaLine(
                  icon: Icons.room_outlined,
                  text: lesson.room,
                  color: context.appMuted,
                ),
                MetaLine(
                  icon: Icons.person_outline_rounded,
                  text: subject.teacher,
                  color: context.appMuted,
                ),
              ],
            ),
            if (lesson.lessonNote != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: context.appInk.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: context.appMuted,
                    ),
                    const SizedBox(width: 6),
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
          ],
        ),
      ),
    );
  }
}

class _TodayLessonRow extends StatelessWidget {
  const _TodayLessonRow({required this.lesson, required this.onTap});

  final LessonItem lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subject = MockSchoolData.subjectById(lesson.subjectId);
    final accent = context.isDark
        ? Color.lerp(subject.color, Colors.white, 0.35)!
        : subject.color;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
        child: Row(
          children: [
            SizedBox(
              width: 42,
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
                  const SizedBox(height: 2),
                  Text(
                    lesson.endTime,
                    style: AppText.small(context.appMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 3,
              height: 34,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(3),
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
                            size: 28,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lesson.topic,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small(context.appMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
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

class _GraphPaperPainter extends CustomPainter {
  const _GraphPaperPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 26.0;
    for (var x = 0.0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPaperPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

String _plural(int value, String one, String few, String many) {
  final mod100 = value % 100;
  if (mod100 >= 11 && mod100 <= 14) return many;
  switch (value % 10) {
    case 1:
      return one;
    case 2:
    case 3:
    case 4:
      return few;
    default:
      return many;
  }
}
