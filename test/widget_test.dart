// Basic Flutter widget test. App uses VetAssistantApp; DI инициализируется в тесте.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vet_assistant/core/di/di_container.dart';
import 'package:vet_assistant/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await setupDependencies();
    await tester.pumpWidget(const ProviderScope(child: VetAssistantApp()));
    await tester.pump();
    await tester.pumpAndSettle();
    // Проверяем, что приложение отрисовалось
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
