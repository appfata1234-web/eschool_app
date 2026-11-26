import 'package:flutter/material.dart';

import '../data/mock_school_data.dart';
import '../models/school_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Quarter grades ledger with masthead average, monochrome distribution, and
/// open hairline subject rows.
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
      .where(
        (subject) =>
            _quarterGrades.any((grade) => grade.subjectId == subject.id),
      )
      .toList(growable: false);

  double _averageFor(List<GradeEntry> entries) {
    if (entries.isEmpty) return 0;
    final weighted = entries.fold<double>(
      0,
      (sum, grade) => sum + grade.value * grade.weight,
    );
    final weights = entries.fold<double>(0, (sum, grade) => sum + grade.weight);
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
    final otherQuarter = _quarter == 1 ? 2 : 1;
    final previousAverage = _averageForQuarter(otherQuarter);
    final subjects = _subjectsWithGrades;
    final delta = average - previousAverage;

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Оценки', style: AppText.pageTitle(context.appInk)),
        const SizedBox(height: 6),
        _QuarterSelector(
          quarter: _quarter,
          onChanged: (quarter) => setState(() => _quarter = quarter),
        ),
      ],
    );
    final metric = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _formatAverage(average),
          style: AppText.display(context.appInk, size: 32),
        ),
        const SizedBox(height: 4),
        if (entries.isNotEmpty)
          Text(
            '${delta >= 0 ? '+' : '−'}${delta.abs().toStringAsFixed(2).replaceAll('.', ',')} '
            'к ${otherQuarter == 1 ? 'I' : 'II'} четв.',
            style: AppText.small(
              delta < 0 ? context.appError : context.appMuted,
              weight: FontWeight.w600,
            ).copyWith(fontFeatures: AppText.tabular),
          ),
      ],
    );
    return AppPage(
      children: [
        if (MediaQuery.textScalerOf(context).scale(13) > 19.5)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading,
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: metric),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: heading),
              const SizedBox(width: AppSpacing.gap),
              metric,
            ],
          ),
        const SizedBox(height: AppSpacing.gap),
        _GradeDistributionBand(entries: entries),
        const SizedBox(height: AppSpacing.section),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                'Оценки по предметам',
                style: AppText.section(context.appInk),
              ),
            ),
            const SizedBox(width: 8),
            Text('Средний', style: AppText.small(context.appMuted)),
          ],
        ),
        const SizedBox(height: 10),
        if (subjects.isEmpty)
          const EmptyState(
            icon: Icons.insights_outlined,
            title: 'Оценок пока нет',
            message: 'В этой четверти оценки ещё не выставлены.',
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.appBorder)),
            ),
            child: Column(
              children: [
                for (var index = 0; index < subjects.length; index++) ...[
                  _SubjectGradeRow(
                    subject: subjects[index],
                    entries: entries
                        .where((grade) => grade.subjectId == subjects[index].id)
                        .toList(growable: false),
                    average: _averageFor(
                      entries
                          .where(
                            (grade) => grade.subjectId == subjects[index].id,
                          )
                          .toList(growable: false),
                    ),
                    onTap: () => _openSubjectSheet(subjects[index]),
                  ),
                  Divider(height: 1, color: context.appBorder),
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
  const _QuarterSelector({required this.quarter, required this.onChanged});

  final int quarter;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final value in [1, 2])
          Semantics(
            selected: quarter == value,
            button: true,
            label: _quarterLabel(value),
            child: InkWell(
              onTap: () => onChanged(value),
              borderRadius: BorderRadius.circular(AppRadii.chip),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppSpacing.touch),
                child: AnimatedContainer(
                  duration: appMotion(
                    context,
                    const Duration(milliseconds: 160),
                  ),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: quarter == value
                            ? context.appInk
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    _quarterLabel(value),
                    style: AppText.body(
                      quarter == value ? context.appInk : context.appMuted,
                      weight: quarter == value
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ).copyWith(fontSize: 14, height: 1.2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GradeDistributionBand extends StatelessWidget {
  const _GradeDistributionBand({required this.entries});

  final List<GradeEntry> entries;

  Color _stepColor(BuildContext context, int value) {
    switch (value) {
      case 5:
        return context.appInk;
      case 4:
        return Color.lerp(context.appInk, context.appOnInk, 0.38)!;
      case 3:
        return Color.lerp(context.appInk, context.appOnInk, 0.72)!;
      default:
        return context.appError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final counts = <int, int>{5: 0, 4: 0, 3: 0, 2: 0};
    for (final entry in entries) {
      final value = entry.value.clamp(2, 5).toInt();
      counts[value] = (counts[value] ?? 0) + 1;
    }
    final total = entries.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.appInk),
          bottom: BorderSide(color: context.appBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 6,
              children: [
                Wrap(
                  spacing: 5,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Итоги четверти',
                      style: AppText.small(
                        context.appInk,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '· $total ${_countWord(total, 'оценка', 'оценки', 'оценок')}',
                      style: AppText.small(
                        context.appInk,
                        weight: FontWeight.w700,
                      ).copyWith(fontFeatures: AppText.tabular),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
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
                                color: _stepColor(context, value),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$value·${counts[value]}',
                              style: AppText.small(context.appMuted)
                                  .copyWith(fontFeatures: AppText.tabular),
                            ),
                          ],
                        ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (total == 0)
            Text(
              'Нет выставленных оценок',
              style: AppText.small(context.appMuted),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < 4; i++)
                      if ((counts[5 - i] ?? 0) > 0) ...[
                        if (i > 0 &&
                            [
                              5,
                              4,
                              3,
                              2,
                            ].take(i).any((v) => (counts[v] ?? 0) > 0))
                          const SizedBox(width: 2),
                        Expanded(
                          flex: counts[5 - i]!,
                          child: ColoredBox(color: _stepColor(context, 5 - i)),
                        ),
                      ],
                  ],
                ),
              ),
            ),
        ],
      ),
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
    final latest = entries.reversed.take(3).toList().reversed.toList();

    return Semantics(
      button: true,
      label: '${subject.name}, средний балл ${_formatAverage(average)}',
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
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
                        ).copyWith(height: 1.25),
                      ),
                      const SizedBox(height: 2),
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
                if (latest.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < latest.length; index++) ...[
                        if (index > 0) const SizedBox(width: 4),
                        GradeMark(value: latest[index].value, size: 24),
                      ],
                    ],
                  ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 44),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatAverage(average),
                      style: AppText.body(
                        context.appInk,
                        weight: FontWeight.w700,
                      ).copyWith(fontFeatures: AppText.tabular),
                    ),
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
          leading: SubjectMark(icon: subject.icon),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _formatAverage(average),
              style: AppText.display(context.appInk, size: 32),
            ),
            const SizedBox(width: 10),
            Text('средний балл', style: AppText.small(context.appMuted)),
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
    final weight = entry.weight.toStringAsFixed(1).replaceAll('.', ',');
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
                  style: AppText.body(context.appInk, weight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  '${entry.dateLabel} · вес $weight',
                  style: AppText.small(context.appMuted),
                ),
                if (entry.comment != null) ...[
                  const SizedBox(height: 7),
                  Text(entry.comment!, style: AppText.small(context.appMuted)),
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
