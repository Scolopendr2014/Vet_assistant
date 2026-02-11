// Basic Flutter widget test. App uses VetAssistantApp; DI инициализируется в тесте.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vet_assistant/core/di/di_container.dart';
import 'package:vet_assistant/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await setupDependencies();
    await tester.pumpWidget(const ProviderScope(child: VetAssistantApp()));
    // Не используем pumpAndSettle — в приложении могут быть таймеры/анимации, из-за которых кадры не перестают планироваться.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Пациенты'), findsOneWidget);
  });
}
