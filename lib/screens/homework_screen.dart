import 'package:flutter/material.dart';

import '../data/mock_school_data.dart';
import '../models/school_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Full homework workspace with weekly progress, search, filters and details.
class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({
    super.key,
    required this.homeworks,
    required this.onToggleHomework,
  });

  final List<HomeworkItem> homeworks;
  final ValueChanged<String> onToggleHomework;

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final TextEditingController _searchController = TextEditingController();

  _StatusFilter _statusFilter = _StatusFilter.all;
  String? _subjectFilterId;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _statusFilter != _StatusFilter.all ||
      _subjectFilterId != null ||
      _query.trim().isNotEmpty;

  List<HomeworkItem> get _filteredHomeworks {
    final query = _query.trim().toLowerCase();
    return widget.homeworks.where((homework) {
      if (_subjectFilterId != null && homework.subjectId != _subjectFilterId) {
        return false;
      }

      final matchesStatus = switch (_statusFilter) {
        _StatusFilter.all => true,
        _StatusFilter.active => !homework.isCompleted,
        _StatusFilter.urgent => homework.isUrgent && !homework.isCompleted,
        _StatusFilter.completed => homework.isCompleted,
      };
      if (!matchesStatus) return false;
      if (query.isEmpty) return true;

      final subject = MockSchoolData.subjectById(homework.subjectId);
      final haystack =
          '${homework.title} ${homework.description} ${subject.name} '
                  '${subject.shortName} ${subject.teacher}'
              .toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _statusFilter = _StatusFilter.all;
      _subjectFilterId = null;
    });
  }

  void _openHomeworkDetails(HomeworkItem homework) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.44),
      builder: (context) => _HomeworkDetailSheet(
        homework: homework,
        onToggleHomework: widget.onToggleHomework,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeworks = _filteredHomeworks;

    return AppPage(
      children: [
        const PageHeader(
          title: 'Домашние задания',
          meta: 'Учебная неделя · 23–28 ноября',
        ),
        const SizedBox(height: 22),
        _WeeklyProgress(homeworks: widget.homeworks),
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          textInputAction: TextInputAction.search,
          style: AppText.body(context.appInk),
          decoration: InputDecoration(
            hintText: 'Предмет, тема или задание',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    onPressed: _clearSearch,
                    tooltip: 'Очистить поиск',
                    icon: const Icon(Icons.close_rounded, size: 19),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        _StatusTabs(
          selected: _statusFilter,
          onSelected: (filter) => setState(() => _statusFilter = filter),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _SubjectFilter(
              selectedId: _subjectFilterId,
              onSelected: (subjectId) {
                setState(() => _subjectFilterId = subjectId);
              },
            ),
            const Spacer(),
            Text(
              '${homeworks.length} '
              '${_plural(homeworks.length, 'задание', 'задания', 'заданий')}',
              style: AppText.small(context.appMuted),
            ),
            if (_hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Сбросить'),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (homeworks.isEmpty)
          EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Ничего не найдено',
            message: _hasActiveFilters
                ? 'Попробуй изменить запрос или сбросить фильтры.'
                : 'На эту неделю заданий нет.',
            actionLabel: _hasActiveFilters ? 'Сбросить фильтры' : null,
            onAction: _hasActiveFilters ? _resetFilters : null,
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var index = 0; index < homeworks.length; index++) ...[
                  if (index > 0)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: context.appBorder,
                    ),
                  _HomeworkRow(
                    key: ValueKey(homeworks[index].id),
                    homework: homeworks[index],
                    onTap: () => _openHomeworkDetails(homeworks[index]),
                    onToggle: () => widget
                        .onToggleHomework(homeworks[index].id),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Status buckets for the homework filters.
enum _StatusFilter { all, active, urgent, completed }

extension on _StatusFilter {
  String get label => switch (this) {
        _StatusFilter.all => 'Все',
        _StatusFilter.active => 'Активные',
        _StatusFilter.urgent => 'Срочные',
        _StatusFilter.completed => 'Выполненные',
      };
}

class _WeeklyProgress extends StatelessWidget {
  const _WeeklyProgress({required this.homeworks});

  final List<HomeworkItem> homeworks;

  @override
  Widget build(BuildContext context) {
    final total = homeworks.length;
    final completed = homeworks.where((item) => item.isCompleted).length;
    final ratio = total == 0 ? 0.0 : completed / total;
    final percent = (ratio * 100).round();
    final complete = total > 0 && completed == total;

    return Column(
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
                    'Прогресс недели',
                    style: AppText.section(context.appInk),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Выполнено $completed из $total заданий',
                    style: AppText.small(context.appMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$percent%',
              style: AppText.display(context.appInk, size: 36),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ProgressBar(
          value: ratio,
          color: complete ? AppColors.success : context.appPrimary,
        ),
      ],
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.selected, required this.onSelected});

  final _StatusFilter selected;
  final ValueChanged<_StatusFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _StatusFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: InkWell(
                onTap: () => onSelected(filter),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filter.label,
                        style: AppText.small(
                          selected == filter
                              ? context.appInk
                              : context.appMuted,
                          weight: selected == filter
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration:
                            appMotion(context, const Duration(milliseconds: 160)),
                        curve: Curves.easeOutCubic,
                        width: selected == filter ? 20 : 0,
                        height: 2,
                        decoration: BoxDecoration(
                          color: context.appPrimary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubjectFilter extends StatelessWidget {
  const _SubjectFilter({
    required this.selectedId,
    required this.onSelected,
  });

  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final label = selectedId == null
        ? 'Все предметы'
        : MockSchoolData.subjectById(selectedId!).shortName;

    return PopupMenuButton<String>(
      initialValue: selectedId ?? '__all__',
      tooltip: 'Фильтр по предмету',
      onSelected: (value) => onSelected(value == '__all__' ? null : value),
      position: PopupMenuPosition.under,
      color: context.appSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.appBorder),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: '__all__',
          child: Text('Все предметы'),
        ),
        for (final subject in MockSchoolData.subjects.values)
          PopupMenuItem<String>(
            value: subject.id,
            child: Text(subject.name),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 15,
              color: context.appMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppText.small(
                context.appInk,
                weight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 18,
              color: context.appMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeworkRow extends StatelessWidget {
  const _HomeworkRow({
    super.key,
    required this.homework,
    required this.onTap,
    required this.onToggle,
  });

  final HomeworkItem homework;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final subject = MockSchoolData.subjectById(homework.subjectId);
    final accent = context.isDark
        ? Color.lerp(subject.color, Colors.white, 0.35)!
        : subject.color;
    final completed = homework.isCompleted;
    final status = completed
        ? StatusLabel(label: 'Готово', color: AppColors.success)
        : homework.isUrgent
            ? const StatusLabel(label: 'Срочно', color: AppColors.danger)
            : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 15, 12, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: _CompletionControl(
                completed: completed,
                onTap: onToggle,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 3,
              height: 48,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: completed ? context.appBorder : accent,
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
                      ?status,
                      const Spacer(),
                      Text(
                        subject.shortName,
                        style: AppText.small(context.appMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    homework.title,
                    style: AppText.body(
                      completed ? context.appMuted : context.appInk,
                      weight: FontWeight.w600,
                    ).copyWith(
                      decoration:
                          completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 13,
                    runSpacing: 4,
                    children: [
                      MetaLine(
                        icon: Icons.event_outlined,
                        text: homework.dueDateLabel,
                      ),
                      MetaLine(
                        icon: Icons.schedule_rounded,
                        text: '${homework.estimatedMinutes} мин',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
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

class _CompletionControl extends StatelessWidget {
  const _CompletionControl({
    required this.completed,
    required this.onTap,
  });

  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: completed ? 'Вернуть в работу' : 'Отметить выполненным',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: AnimatedContainer(
          duration: appMotion(context, const Duration(milliseconds: 160)),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed ? AppColors.success : Colors.transparent,
            border: Border.all(
              color: completed ? AppColors.success : context.appBorder,
              width: 1.5,
            ),
          ),
          child: completed
              ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

class _HomeworkDetailSheet extends StatefulWidget {
  const _HomeworkDetailSheet({
    required this.homework,
    required this.onToggleHomework,
  });

  final HomeworkItem homework;
  final ValueChanged<String> onToggleHomework;

  @override
  State<_HomeworkDetailSheet> createState() => _HomeworkDetailSheetState();
}

class _HomeworkDetailSheetState extends State<_HomeworkDetailSheet> {
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _completed = widget.homework.isCompleted;
  }

  void _toggle() {
    widget.onToggleHomework(widget.homework.id);
    setState(() => _completed = !_completed);
  }

  @override
  Widget build(BuildContext context) {
    final homework = widget.homework;
    final subject = MockSchoolData.subjectById(homework.subjectId);
    final status = _completed
        ? const StatusLabel(label: 'Выполнено', color: AppColors.success)
        : homework.isUrgent
            ? const StatusLabel(label: 'Срочно', color: AppColors.danger)
            : StatusLabel(label: 'В работе', color: context.appPrimary);

    return AppSheet(
      children: [
        SheetHeader(
          title: subject.name,
          subtitle: 'Домашнее задание',
          leading: SubjectMark(
            color: subject.color,
            icon: subject.icon,
          ),
        ),
        const SizedBox(height: 16),
        status,
        const SizedBox(height: 10),
        Text(
          homework.title,
          style: AppText.section(context.appInk),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 5,
          children: [
            MetaLine(
              icon: Icons.event_outlined,
              text: homework.dueDateLabel,
            ),
            MetaLine(
              icon: Icons.schedule_rounded,
              text: '${homework.estimatedMinutes} мин',
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(homework.description, style: AppText.body(context.appInk)),
        if (homework.steps.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text('План выполнения', style: AppText.section(context.appInk)),
          const SizedBox(height: 8),
          for (var index = 0; index < homework.steps.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 27,
                    child: Text(
                      '${index + 1}'.padLeft(2, '0'),
                      style: AppText.small(
                        context.appPrimary,
                        weight: FontWeight.w700,
                      ).copyWith(fontFeatures: AppText.tabular),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      homework.steps[index],
                      style: AppText.body(context.appInk),
                    ),
                  ),
                ],
              ),
            ),
        ],
        if (homework.attachments.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text('Материалы', style: AppText.section(context.appInk)),
          const SizedBox(height: 8),
          for (final attachment in homework.attachments)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Icon(
                    Icons.attach_file_rounded,
                    size: 17,
                    color: context.appMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      attachment,
                      style: AppText.small(context.appInk),
                    ),
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _toggle,
            child: Text(
              _completed ? 'Вернуть в работу' : 'Отметить выполненным',
            ),
          ),
        ),
      ],
    );
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
