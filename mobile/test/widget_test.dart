import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fasol_doctor/app.dart';

void main() {
  testWidgets('onboarding screen shows the primary CTA', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FasolDoctorApp()));
    await tester.pumpAndSettle();

    expect(find.text('শুরু করুন'), findsOneWidget);
  });
}
