import 'package:flutter/material.dart';

import '../data/mock_school_data.dart';
import '../models/school_models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

/// Actionable deadline-grouped homework inbox with inline progress,
/// search, subject/status filtering and detail sheets.
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
    return widget.homeworks
        .where((homework) {
          if (_subjectFilterId != null &&
              homework.subjectId != _subjectFilterId) {
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
        })
        .toList(growable: false);
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
    final urgentItems = homeworks
        .where((item) => !item.isCompleted && item.isUrgent)
        .toList(growable: false);
    final upcomingItems = homeworks
        .where((item) => !item.isCompleted && !item.isUrgent)
        .toList(growable: false);
    final completedItems = homeworks
        .where((item) => item.isCompleted)
        .toList(growable: false);

    return AppPage(
      children: [
        _InboxHeader(homeworks: widget.homeworks),
        const SizedBox(height: AppSpacing.gap),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                textInputAction: TextInputAction.search,
                style: AppText.body(context.appInk),
                decoration: InputDecoration(
                  hintText: 'Предмет или тема',
                  hintStyle: AppText.small(context.appMuted),
                  filled: true,
                  fillColor: context.appSurface,
                  isDense: true,
                  constraints: const BoxConstraints(
                    minHeight: AppSpacing.touch,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: context.appMuted,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _clearSearch,
                          tooltip: 'Очистить поиск',
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: context.appMuted,
                          ),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.input),
                    borderSide: BorderSide(color: context.appBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.input),
                    borderSide: BorderSide(color: context.appBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.input),
                    borderSide: BorderSide(color: context.appInk, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SubjectFilter(
              selectedId: _subjectFilterId,
              onSelected: (subjectId) {
                setState(() => _subjectFilterId = subjectId);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        _StatusTabs(
          homeworks: widget.homeworks,
          selected: _statusFilter,
          onSelected: (filter) => setState(() => _statusFilter = filter),
        ),
        if (_hasActiveFilters) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${homeworks.length} '
                  '${_plural(homeworks.length, 'задание', 'задания', 'заданий')}',
                  style: AppText.small(context.appMuted)
                      .copyWith(fontFeatures: AppText.tabular),
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Сбросить'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
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
        else ...[
          if (urgentItems.isNotEmpty) ...[
            _HomeworkGroup(
              title: 'Завтра, 27 ноя',
              countLabel:
                  '${urgentItems.length} '
                  '${_plural(urgentItems.length, 'срочное', 'срочных', 'срочных')}',
              urgent: true,
              items: urgentItems,
              onOpenDetails: _openHomeworkDetails,
              onToggleHomework: widget.onToggleHomework,
            ),
            const SizedBox(height: 14),
          ],
          if (upcomingItems.isNotEmpty) ...[
            _HomeworkGroup(
              title: 'На выходных и далее',
              countLabel:
                  '${upcomingItems.length} '
                  '${_plural(upcomingItems.length, 'задание', 'задания', 'заданий')}',
              urgent: false,
              items: upcomingItems,
              onOpenDetails: _openHomeworkDetails,
              onToggleHomework: widget.onToggleHomework,
            ),
            const SizedBox(height: 14),
          ],
          if (completedItems.isNotEmpty)
            _HomeworkGroup(
              title: 'Выполнено',
              countLabel:
                  '${completedItems.length} '
                  '${_plural(completedItems.length, 'задание', 'задания', 'заданий')}',
              urgent: false,
              items: completedItems,
              onOpenDetails: _openHomeworkDetails,
              onToggleHomework: widget.onToggleHomework,
            ),
        ],
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
    _StatusFilter.completed => 'Готово',
  };

  int countFor(List<HomeworkItem> homeworks) => switch (this) {
    _StatusFilter.all => homeworks.length,
    _StatusFilter.active => homeworks.where((item) => !item.isCompleted).length,
    _StatusFilter.urgent =>
      homeworks.where((item) => item.isUrgent && !item.isCompleted).length,
    _StatusFilter.completed =>
      homeworks.where((item) => item.isCompleted).length,
  };
}

class _InboxHeader extends StatelessWidget {
  const _InboxHeader({required this.homeworks});

  final List<HomeworkItem> homeworks;

  @override
  Widget build(BuildContext context) {
    final total = homeworks.length;
    final completed = homeworks.where((item) => item.isCompleted).length;
    final ratio = total == 0 ? 0.0 : completed / total;
    final percent = (ratio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                'Домашние задания',
                style: AppText.pageTitle(context.appInk),
              ),
            ),
            const SizedBox(width: 10),
            Semantics(
              label: '$percent процента выполнено',
              child: Text(
                '$percent%',
                style: AppText.body(
                  context.appInk,
                  weight: FontWeight.w700,
                ).copyWith(fontFeatures: AppText.tabular),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Flexible(
              child: Text(
                'Прогресс недели',
                style: AppText.small(context.appMuted),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Выполнено $completed из $total заданий',
                textAlign: TextAlign.end,
                style: AppText.small(context.appMuted)
                    .copyWith(fontFeatures: AppText.tabular),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Semantics(
          label: 'Прогресс выполнения: $percent процентов',
          child: ProgressBar(value: ratio, height: 4, color: context.appInk),
        ),
      ],
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({
    required this.homeworks,
    required this.selected,
    required this.onSelected,
  });

  final List<HomeworkItem> homeworks;
  final _StatusFilter selected;
  final ValueChanged<_StatusFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.appBorder)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final filter in _StatusFilter.values)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Semantics(
                  selected: selected == filter,
                  button: true,
                  child: InkWell(
                    onTap: () => onSelected(filter),
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: AppSpacing.touch,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: selected == filter
                                  ? context.appInk
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          '${filter.label} · ${filter.countFor(homeworks)}',
                          style: AppText.small(
                            selected == filter
                                ? context.appInk
                                : context.appMuted,
                            weight: selected == filter
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ).copyWith(fontFeatures: AppText.tabular),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SubjectFilter extends StatelessWidget {
  const _SubjectFilter({required this.selectedId, required this.onSelected});

  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedId != null;
    final label = hasSelection
        ? MockSchoolData.subjectById(selectedId!).shortName
        : 'Предметы';

    return PopupMenuButton<String>(
      initialValue: selectedId ?? '__all__',
      tooltip: 'Фильтр по предмету',
      onSelected: (value) => onSelected(value == '__all__' ? null : value),
      position: PopupMenuPosition.under,
      color: context.appSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: BorderSide(color: context.appBorder),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: '__all__',
          child: Text('Все предметы', style: AppText.body(context.appInk)),
        ),
        for (final subject in MockSchoolData.subjects.values)
          PopupMenuItem<String>(
            value: subject.id,
            child: Text(subject.name, style: AppText.body(context.appInk)),
          ),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppSpacing.touch,
          maxWidth: 156,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(AppRadii.input),
            border: Border.all(
              color: hasSelection ? context.appInk : context.appBorder,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small(
                      context.appInk,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
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

class _HomeworkGroup extends StatelessWidget {
  const _HomeworkGroup({
    required this.title,
    required this.countLabel,
    required this.urgent,
    required this.items,
    required this.onOpenDetails,
    required this.onToggleHomework,
  });

  final String title;
  final String countLabel;
  final bool urgent;
  final List<HomeworkItem> items;
  final ValueChanged<HomeworkItem> onOpenDetails;
  final ValueChanged<String> onToggleHomework;

  @override
  Widget build(BuildContext context) {
    final headerColor = urgent ? context.appError : context.appMuted;
    final headerBorder = urgent ? context.appError : context.appBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 4, bottom: 5),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: headerBorder)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppText.small(headerColor, weight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                countLabel,
                style: AppText.small(
                  headerColor,
                  weight: FontWeight.w700,
                ).copyWith(fontFeatures: AppText.tabular),
              ),
            ],
          ),
        ),
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) Divider(height: 1, color: context.appBorder),
          _HomeworkRow(
            key: ValueKey(items[index].id),
            homework: items[index],
            onTap: () => onOpenDetails(items[index]),
            onToggle: () => onToggleHomework(items[index].id),
          ),
        ],
      ],
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
    final completed = homework.isCompleted;
    final urgent = !completed && homework.isUrgent;

    final metaDetails = urgent
        ? '${subject.shortName} · ${homework.estimatedMinutes} мин'
        : completed
        ? '${subject.shortName} · ${homework.estimatedMinutes} мин'
        : '${subject.shortName} · ${homework.dueDateLabel} · '
              '${homework.estimatedMinutes} мин';

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 58),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CompletionControl(
            completed: completed,
            urgent: urgent,
            subjectName: subject.name,
            onTap: onToggle,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadii.input),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            homework.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppText.body(
                                  completed ? context.appMuted : context.appInk,
                                  weight: completed
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                                ).copyWith(
                                  height: 1.25,
                                  decoration: completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            spacing: 8,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (urgent)
                                Text(
                                  'Срочно',
                                  style: AppText.small(
                                    context.appError,
                                    weight: FontWeight.w600,
                                  ),
                                )
                              else if (completed)
                                Text(
                                  'Готово',
                                  style: AppText.small(
                                    context.appInk,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              Text(
                                metaDetails,
                                style: AppText.small(context.appMuted)
                                    .copyWith(fontFeatures: AppText.tabular),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!completed) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: context.appMuted,
                      ),
                    ],
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

class _CompletionControl extends StatelessWidget {
  const _CompletionControl({
    required this.completed,
    required this.urgent,
    required this.subjectName,
    required this.onTap,
  });

  final bool completed;
  final bool urgent;
  final String subjectName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = completed
        ? context.appInk
        : urgent
        ? context.appError
        : context.appBorderStrong;

    return Semantics(
      button: true,
      toggled: completed,
      label: completed
          ? 'Вернуть в работу: $subjectName'
          : 'Отметить выполненным: $subjectName',
      child: Tooltip(
        message: completed ? 'Вернуть в работу' : 'Отметить выполненным',
        child: InkResponse(
          onTap: onTap,
          radius: 24,
          child: SizedBox(
            width: AppSpacing.touch,
            height: AppSpacing.touch,
            child: Center(
              child: AnimatedContainer(
                duration: appMotion(context, const Duration(milliseconds: 160)),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: completed ? context.appInk : context.appBackground,
                  borderRadius: BorderRadius.circular(AppRadii.chip),
                  border: Border.all(color: borderColor, width: 1.8),
                ),
                child: completed
                    ? Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: context.appOnInk,
                      )
                    : null,
              ),
            ),
          ),
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
        ? StatusLabel(label: 'Выполнено', color: context.appInk)
        : homework.isUrgent
        ? StatusLabel(label: 'Срочно', color: context.appError)
        : StatusLabel(label: 'В работе', color: context.appMuted);

    return AppSheet(
      children: [
        SheetHeader(
          title: subject.name,
          subtitle: 'Домашнее задание',
          leading: SubjectMark(color: context.appInk, icon: subject.icon),
        ),
        const SizedBox(height: 16),
        status,
        const SizedBox(height: 10),
        Text(homework.title, style: AppText.section(context.appInk)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 5,
          children: [
            MetaLine(icon: Icons.event_outlined, text: homework.dueDateLabel),
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
                        context.appInk,
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
