import 'package:flutter_test/flutter_test.dart';
import 'package:passago_app/main.dart';

void main() {
  testWidgets('app opens on the Welcome screen', (tester) async {
    await tester.pumpWidget(const PassaGoApp());
    await tester.pumpAndSettle();

    expect(find.text('Drive with PassaGo'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
