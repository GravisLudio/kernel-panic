// This is a basic smoke test for the Kernel Panic application.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kernelpanic/main.dart';

void main() {
  testWidgets('Kernel Panic app smoke test', (WidgetTester tester) async {
    // Build our app inside a ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: KernelPanicApp(),
      ),
    );

    // Verify that the title and instructions button are displayed on the main menu.
    expect(find.text('KERNEL PANIC'), findsOneWidget);
    expect(find.text('SELECCIONAR MODO DE JUEGO'), findsOneWidget);
    expect(find.text('MANUAL DE OPERACIONES'), findsOneWidget);
  });
}
