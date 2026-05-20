// Smoke test : vérifie que l'application démarre sans exception.
//
// Le test généré par `flutter create` testait un compteur (MyApp) qui
// n'existe pas dans cette application. Il est remplacé ici par un
// smoke test minimal sur la classe App réelle.

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    // Le simple fait d'arriver ici sans exception valide le smoke test.
    expect(find.byType(App), findsOneWidget);
  });
}
