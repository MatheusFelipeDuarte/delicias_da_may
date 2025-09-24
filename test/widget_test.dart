// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:delicias_da_may/main.dart';

void main() {
  testWidgets('App renders CalendarScreen', (tester) async {
    await initializeDateFormatting('pt_BR');
    await tester.pumpWidget(const MyApp());
    expect(find.text('Calendário'), findsOneWidget);
  });
}
