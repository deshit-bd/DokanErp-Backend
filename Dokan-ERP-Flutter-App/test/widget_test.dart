import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dokan_erp/app.dart';
import 'package:dokan_erp/modules/auth/auth.dart';
import 'package:dokan_erp/data/data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'Splash reaches onboarding, next button navigates pages, then finish opens login',
      (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(DokanErpApp(
      overrides: [
        apiConfiguredProvider.overrideWithValue(false),
      ],
    ));
    await tester.pump();

    // Pump enough to finish the splash screen and transition to onboarding
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);

    // Verify we are on the first onboarding page (title checks)
    expect(find.text('আপনার দোকান এখন আপনার হাতে'), findsOneWidget);

    // Find and tap the "Next" button (ElevatedButton in _PageFooter)
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify we are on the second onboarding page
    expect(find.text('বিক্রি করুন মাত্র কয়েক সেকেন্ডে'), findsOneWidget);

    // Tap "Next" button again
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify we are on the third onboarding page
    expect(find.text('বাকি, লাভ-ক্ষতি সব নজরে রাখুন'), findsOneWidget);

    // Tap "শুরু করুন" (Start) button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify we are now on the login screen
    expect(find.byType(DokanLoginScreen), findsOneWidget);
  });
}
