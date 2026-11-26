import 'package:flutter/material.dart';

import '../data/mock_school_data.dart';
import '../models/school_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Quarter grades overview with weighted averages and subject breakdowns.
class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  int _quarter = 2;

  List<GradeEntry> get _quarterGrades => MockSchoolData.grades
      .where((grade) => grade.quarter == _quarter)
      .toList(growable: false);

  List<SubjectMeta> get _subjectsWithGrades => MockSchoolData.subjects.values
      .where((subject) => _quarterGrades
          .any((grade) => grade.subjectId == subject.id))
      .toList(growable: false);

  double _averageFor(List<GradeEntry> entries) {
    if (entries.isEmpty) return 0;
    final weighted = entries.fold<double>(
      0,
      (sum, grade) => sum + grade.value * grade.weight,
    );
    final weights =
        entries.fold<double>(0, (sum, grade) => sum + grade.weight);
    return weighted / weights;
  }

  double _averageForQuarter(int quarter) {
    return _averageFor(
      MockSchoolData.grades.where((grade) => grade.quarter == quarter).toList(),
    );
  }

  void _openSubjectSheet(SubjectMeta subject) {
    final entries = _quarterGrades
        .where((grade) => grade.subjectId == subject.id)
        .toList(growable: false);
    if (entries.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.44),
      builder: (context) => _SubjectGradesSheet(
        subject: subject,
        quarter: _quarter,
        entries: entries,
        average: _averageFor(entries),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _quarterGrades;
    final average = _averageFor(entries);
    final previousAverage = _averageForQuarter(_quarter == 1 ? 2 : 1);
    final subjects = _subjectsWithGrades;
    final delta = average - previousAverage;

    return AppPage(
      children: [
        PageHeader(
          title: 'Оценки',
          meta: '${_quarterLabel(_quarter)} · '
              '${entries.length} ${_countWord(entries.length, 'оценка', 'оценки', 'оценок')}',
        ),
        const SizedBox(height: 20),
        _QuarterSelector(
          quarter: _quarter,
          onChanged: (quarter) => setState(() => _quarter = quarter),
        ),
        const SizedBox(height: 20),
        SectionHeading(
          title: 'Итоги четверти',
          trailing: Text(
            '${subjects.length} предметов',
            style: AppText.small(context.appMuted),
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Средний балл',
                          style: AppText.small(context.appMuted),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatAverage(average),
                          style: AppText.display(context.appInk, size: 54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _quarterLabel(_quarter == 1 ? 2 : 1),
                        style: AppText.small(context.appMuted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatAverage(previousAverage),
                        style: AppText.section(context.appInk),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            delta >= 0
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 14,
                            color: delta >= 0
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${delta >= 0 ? '+' : '−'}'
                            '${delta.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                            style: AppText.small(
                              delta >= 0
                                  ? AppColors.success
                                  : AppColors.danger,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _GradeDistribution(entries: entries),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SectionHeading(
          title: 'Оценки по предметам',
          trailing: Text(
            '${subjects.length} ${_countWord(subjects.length, 'предмет', 'предмета', 'предметов')}',
            style: AppText.small(context.appMuted),
          ),
        ),
        const SizedBox(height: 10),
        if (subjects.isEmpty)
          const EmptyState(
            icon: Icons.insights_outlined,
            title: 'Оценок пока нет',
            message: 'В этой четверти оценки ещё не выставлены.',
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var index = 0; index < subjects.length; index++) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: context.appBorder,
                    ),
                  _SubjectGradeRow(
                    subject: subjects[index],
                    entries: entries
                        .where((grade) =>
                            grade.subjectId == subjects[index].id)
                        .toList(growable: false),
                    average: _averageFor(
                      entries
                          .where((grade) =>
                              grade.subjectId == subjects[index].id)
                          .toList(growable: false),
                    ),
                    onTap: () => _openSubjectSheet(subjects[index]),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 14),
        Text(
          'Средний балл рассчитывается с учётом веса контрольных '
          'и самостоятельных работ.',
          style: AppText.small(context.appMuted),
        ),
      ],
    );
  }
}

class _QuarterSelector extends StatelessWidget {
  const _QuarterSelector({
    required this.quarter,
    required this.onChanged,
  });

  final int quarter;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (final value in [1, 2])
            Expanded(
              child: Semantics(
                selected: quarter == value,
                button: true,
                label: _quarterLabel(value),
                child: InkWell(
                  onTap: () => onChanged(value),
                  child: AnimatedContainer(
                    duration:
                        appMotion(context, const Duration(milliseconds: 160)),
                    curve: Curves.easeOutCubic,
                    color: quarter == value ? context.appHero : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Text(
                      _quarterLabel(value),
                      style: AppText.body(
                        quarter == value ? Colors.white : context.appMuted,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GradeDistribution extends StatelessWidget {
  const _GradeDistribution({required this.entries});

  final List<GradeEntry> entries;

  @override
  Widget build(BuildContext context) {
    final counts = <int, int>{5: 0, 4: 0, 3: 0, 2: 0};
    for (final entry in entries) {
      final value = entry.value.clamp(2, 5).toInt();
      counts[value] = (counts[value] ?? 0) + 1;
    }
    final total = entries.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final value in [5, 4, 3, 2])
                  if ((counts[value] ?? 0) > 0)
                    Expanded(
                      flex: counts[value]!,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Container(color: AppColors.forGrade(value)),
                      ),
                    ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 5,
          children: [
            for (final value in [5, 4, 3, 2])
              if ((counts[value] ?? 0) > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.forGrade(value),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$value · ${counts[value]}',
                      style: AppText.small(context.appMuted),
                    ),
                  ],
                ),
          ],
        ),
        if (total == 0)
          Text(
            'Нет выставленных оценок',
            style: AppText.small(context.appMuted),
          ),
      ],
    );
  }
}

class _SubjectGradeRow extends StatelessWidget {
  const _SubjectGradeRow({
    required this.subject,
    required this.entries,
    required this.average,
    required this.onTap,
  });

  final SubjectMeta subject;
  final List<GradeEntry> entries;
  final double average;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.isDark
        ? Color.lerp(subject.color, Colors.white, 0.35)!
        : subject.color;
    final latest = entries.reversed.take(3).toList().reversed.toList();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 38,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(
                      context.appInk,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subject.teacher,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small(context.appMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAverage(average),
                  style: AppText.body(
                    context.appInk,
                    weight: FontWeight.w700,
                  ).copyWith(fontFeatures: AppText.tabular),
                ),
                const SizedBox(height: 5),
                if (latest.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < latest.length; index++) ...[
                        if (index > 0) const SizedBox(width: 4),
                        GradeMark(
                          value: latest[index].value,
                          size: 22,
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 17,
              color: context.appMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectGradesSheet extends StatelessWidget {
  const _SubjectGradesSheet({
    required this.subject,
    required this.quarter,
    required this.entries,
    required this.average,
  });

  final SubjectMeta subject;
  final int quarter;
  final List<GradeEntry> entries;
  final double average;

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      children: [
        SheetHeader(
          title: subject.name,
          subtitle: '${_quarterLabel(quarter)} · ${subject.teacher}',
          leading: SubjectMark(
            color: subject.color,
            icon: subject.icon,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              color: context.appAccent,
              padding: const EdgeInsets.fromLTRB(9, 2, 10, 3),
              child: Text(
                _formatAverage(average),
                style: AppText.display(AppColors.accentInk, size: 36),
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                'средний балл',
                style: AppText.small(context.appMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Divider(color: context.appBorder, height: 1),
        for (var index = 0; index < entries.length; index++) ...[
          _GradeEntryRow(entry: entries[index]),
          if (index < entries.length - 1)
            Divider(color: context.appBorder, height: 1),
        ],
      ],
    );
  }
}

class _GradeEntryRow extends StatelessWidget {
  const _GradeEntryRow({required this.entry});

  final GradeEntry entry;

  @override
  Widget build(BuildContext context) {
    final weight =
        entry.weight.toStringAsFixed(1).replaceAll('.', ',');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradeMark(value: entry.value, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.workType,
                  style: AppText.body(
                    context.appInk,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${entry.dateLabel} · вес $weight',
                  style: AppText.small(context.appMuted),
                ),
                if (entry.comment != null) ...[
                  const SizedBox(height: 7),
                  Text(
                    entry.comment!,
                    style: AppText.small(context.appMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _quarterLabel(int quarter) =>
    quarter == 1 ? 'I четверть' : 'II четверть';

String _formatAverage(double value) {
  if (value == 0) return '—';
  return value.toStringAsFixed(2).replaceAll('.', ',');
}

String _countWord(int value, String one, String few, String many) {
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
