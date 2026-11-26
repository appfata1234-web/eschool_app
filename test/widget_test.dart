import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eschool_app/main.dart';

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
    expect(
      find.text('Квадратичная функция и её график'),
      findsOneWidget,
    );

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

  testWidgets('phone layout renders every tab without overflow',
      (tester) async {
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

  testWidgets('theme switch and homework toggle update app-wide state',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const EschoolApp());
    await tester.pumpAndSettle();

    await _openTab(tester, 'Профиль');
    final profileContext =
        tester.element(find.text('Личный кабинет ученика'));
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
}

Future<void> _openTab(WidgetTester tester, String label) async {
  final destination = find.descendant(
    of: find.byType(AppBottomNav),
    matching: find.text(label),
  );
  expect(destination, findsWidgets);
  await tester.tap(destination.first);
  await tester.pumpAndSettle();
}
