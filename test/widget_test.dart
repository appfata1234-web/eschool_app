import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eschool_app/main.dart';
import 'package:eschool_app/theme/app_theme.dart';
import 'package:eschool_app/widgets/shared_widgets.dart';

void main() {
  testWidgets('navigates across all five tabs', (tester) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const EschoolApp());
    await tester.pumpAndSettle();

    expect(find.text('Добрый день, Артём'), findsOneWidget);
    expect(find.text('Средний балл'), findsOneWidget);
    expect(find.text('Сейчас идёт'), findsOneWidget);
    expect(find.text('Срочные задания'), findsNothing);
    expect(find.text('Объявления'), findsNothing);

    await _openTab(tester, 'Расписание');
    expect(find.text('Сегодняшние уроки'), findsOneWidget);
    expect(find.text('Квадратичная функция и её график'), findsOneWidget);

    await _openTab(tester, 'Оценки');
    expect(find.text('Итоги четверти'), findsOneWidget);
    expect(find.text('Оценки по предметам'), findsOneWidget);
    expect(find.text('Алгебра и начала анализа'), findsOneWidget);

    await _openTab(tester, 'Задания');
    expect(find.text('Домашние задания'), findsOneWidget);
    expect(find.text('Прогресс недели'), findsOneWidget);

    await _openTab(tester, 'Профиль');
    expect(find.text('Личный кабинет ученика'), findsOneWidget);
    expect(find.text('Данные ученика'), findsOneWidget);
    expect(find.text('Достижения'), findsNothing);
    expect(find.text('Классный руководитель'), findsNothing);
    expect(find.text('Школьная карта'), findsNothing);
  });

  testWidgets('phone layout renders every tab without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const EschoolApp());
    await tester.pumpAndSettle();

    for (final label in const [
      'Расписание',
      'Оценки',
      'Задания',
      'Профиль',
      'Главная',
    ]) {
      await _openTab(tester, label);
      expect(tester.takeException(), isNull, reason: 'Tab $label');
    }
  });

  testWidgets('theme switch and homework toggle update app-wide state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const EschoolApp());
    await tester.pumpAndSettle();

    await _openTab(tester, 'Профиль');
    final profileContext = tester.element(find.text('Личный кабинет ученика'));
    expect(Theme.of(profileContext).brightness, Brightness.light);

    await tester.tap(find.text('Тёмная тема'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(
      Theme.of(tester.element(find.text('Личный кабинет ученика'))).brightness,
      Brightness.dark,
    );

    await _openTab(tester, 'Задания');
    expect(find.text('Выполнено 2 из 6 заданий'), findsOneWidget);

    final firstToggle = find.byTooltip('Отметить выполненным').first;
    await tester.ensureVisible(firstToggle);
    await tester.tap(firstToggle);
    await tester.pumpAndSettle();

    expect(find.text('Выполнено 3 из 6 заданий'), findsOneWidget);
    expect(find.byTooltip('Вернуть в работу'), findsWidgets);
  });
  testWidgets('homework search resets and keeps its query between tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EschoolApp());
    await tester.pumpAndSettle();
    await _openTab(tester, 'Задания');
    await tester.enterText(find.byType(TextField), 'неттакогозадания');
    await tester.pumpAndSettle();
    expect(find.text('Ничего не найдено'), findsOneWidget);
    await _openTab(tester, 'Главная');
    await _openTab(tester, 'Задания');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'неттакогозадания',
    );
    await tester.ensureVisible(find.text('Сбросить фильтры'));
    await tester.tap(find.text('Сбросить фильтры'));
    await tester.pumpAndSettle();
    expect(find.text('Ничего не найдено'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('Home profile link opens settings and About dialog closes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EschoolApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(InitialsAvatar).first);
    await tester.pumpAndSettle();
    expect(find.text('Личный кабинет ученика'), findsOneWidget);
    await tester.ensureVisible(find.text('О приложении'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('О приложении'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Закрыть'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('search and selected day survive the rail breakpoint', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EschoolApp());
    await tester.pumpAndSettle();
    await _openTab(tester, 'Расписание');
    await tester.tap(find.text('Сб'));
    await tester.pumpAndSettle();
    await _openTab(tester, 'Задания');
    await tester.enterText(find.byType(TextField), 'физика');
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(1280, 800);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'физика',
    );
    await _openTab(tester, 'Расписание');
    expect(find.textContaining('Суббота'), findsWidgets);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.textContaining('Суббота'), findsWidgets);
    await _openTab(tester, 'Задания');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'физика',
    );
  });

  for (final size in const [Size(360, 800), Size(390, 844), Size(1280, 800)]) {
    testWidgets('both themes and enlarged text at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const EschoolApp());
      await tester.pumpAndSettle();
      expect(
        find.byType(AppFloatingDock),
        size.width < 840 ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(AppNavRail),
        size.width >= 840 ? findsOneWidget : findsNothing,
      );
      for (final dark in [false, true]) {
        if (dark) {
          await _openTab(tester, 'Профиль');
          await tester.ensureVisible(find.text('Тёмная тема'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Тёмная тема'));
          await tester.pumpAndSettle();
          expect(
            tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
            ThemeMode.dark,
          );
        }
        for (final label in [
          'Главная',
          'Расписание',
          'Оценки',
          'Задания',
          'Профиль',
        ]) {
          await _openTab(tester, label);
          expect(
            tester.takeException(),
            isNull,
            reason: '$size $label dark=$dark',
          );
        }
      }
    });
  }

  testWidgets('largest text keeps all sections usable', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const EschoolApp());
    await tester.pumpAndSettle();
    for (final index in [0, 1, 2, 3, 4]) {
      final dock = tester.widget<AppFloatingDock>(find.byType(AppFloatingDock));
      dock.onSelected(index);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '2x text tab $index');
    }
  });

  testWidgets('the app uses the exact selected canvas colors', (tester) async {
    await tester.pumpWidget(const EschoolApp());
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.scaffoldBackgroundColor, const Color(0xFFFDFFFC));
    expect(app.darkTheme!.scaffoldBackgroundColor, const Color(0xFF011627));
    expect(AppText.bodyFamily, 'Onest');
  });
}

Future<void> _openTab(WidgetTester tester, String label) async {
  final destination = find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is AppFloatingDock || widget is AppNavRail,
    ),
    matching: find.text(label),
  );
  expect(destination, findsWidgets);
  await tester.tap(destination.first);
  await tester.pumpAndSettle();
}
