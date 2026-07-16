import 'package:co2diet/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: Co2DietApp()),
    );
    expect(find.text('CO2 Diet'), findsOneWidget);
  });
}
