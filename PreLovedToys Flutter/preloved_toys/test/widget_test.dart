import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:preloved_toys/providers/auth_provider.dart';
import 'package:preloved_toys/screens/auth_gate.dart';
import 'package:preloved_toys/screens/login_screen.dart';
import 'package:preloved_toys/screens/otp_screen.dart';
import 'package:preloved_toys/utils/error_message.dart';

/// Wraps [home] in the app's provider. Repeating animations (button glare, splash
/// rings) are turned off through "reduce motion" so pumpAndSettle can finish.
Widget _app(Widget home, {double keyboard = 0}) {
  return ChangeNotifierProvider(
    create: (_) => AuthProvider(),
    child: MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          viewInsets: EdgeInsets.only(bottom: keyboard),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: home,
    ),
  );
}

Widget _login({double keyboard = 0}) => _app(const LoginScreen(), keyboard: keyboard);
Widget _otp() => _app(const OtpScreen(mobile: '9876543210'));

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1080, 2340); // 360 x 780 phone
    view.devicePixelRatio = 3;
  });

  tearDown(() {
    final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  group('login', () {
    testWidgets('shows the brand, the field and the links', (tester) async {
      await tester.pumpWidget(_login());
      await tester.pumpAndSettle();

      expect(find.text('PreLoved Toys'), findsOneWidget);
      expect(find.text('Memories never go out of play'), findsOneWidget);
      expect(find.text('Log in or sign up'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(find.text('Get OTP'), findsOneWidget);
      expect(find.textContaining('Terms & Conditions', findRichText: true), findsOneWidget);
      // No phone number is pre-filled.
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
    });

    testWidgets('tapping Get OTP with no number explains what is missing', (tester) async {
      await tester.pumpWidget(_login());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get OTP'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your mobile number'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '98765');
      await tester.tap(find.text('Get OTP'));
      await tester.pumpAndSettle();
      expect(find.text('Enter all 10 digits'), findsOneWidget);
    });

    testWidgets('numbers must start with 6-9; a pasted +91 is removed', (tester) async {
      await tester.pumpWidget(_login());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '1234567890');
      await tester.pump();
      expect(find.text('Mobile numbers start with 6, 7, 8 or 9'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '+91 98765-43210');
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, '9876543210');
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('header shrinks while the keyboard is open', (tester) async {
      await tester.pumpWidget(_login(keyboard: 300));
      await tester.pumpAndSettle();
      expect(find.text('Memories never go out of play'), findsNothing);
      expect(find.text('PreLoved Toys'), findsOneWidget);
      // The card rides up above the keyboard (screen is 780 tall).
      expect(tester.getRect(find.text('Log in or sign up')).bottom, lessThan(780 - 300));
    });

    testWidgets('card sits over the bottom 35% of the screen', (tester) async {
      await tester.pumpWidget(_login());
      await tester.pumpAndSettle();
      // Header is 65% of 780 = 507; the card overlaps it by 40.
      expect(tester.getRect(find.text('Log in or sign up')).top, greaterThan(467));
      expect(tester.getRect(find.text('PreLoved Toys')).bottom, lessThan(467));
    });

    testWidgets('fits a small phone without overflow', (tester) async {
      tester.view.physicalSize = const Size(640, 1136); // 320 x 568
      tester.view.devicePixelRatio = 2;
      await tester.pumpWidget(_login());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get OTP'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your mobile number'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('otp', () {
    testWidgets('shows the number, four boxes and the resend countdown', (tester) async {
      await tester.pumpWidget(_otp());
      await tester.pumpAndSettle();

      expect(find.text('Verification'), findsOneWidget);
      // Number without +91, with a pencil button to change it.
      expect(find.textContaining('98765 43210', findRichText: true), findsOneWidget);
      expect(find.textContaining('+91', findRichText: true), findsNothing);
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
      expect(find.text('Verify & Login'), findsOneWidget);
      expect(find.textContaining('Resend in 00:20', findRichText: true), findsOneWidget);
      // Same layout as login: the card starts below the header.
      expect(tester.getRect(find.text('Verification')).top, greaterThan(467));

      await tester.pump(const Duration(seconds: 20));
      expect(find.textContaining('Resend OTP', findRichText: true), findsOneWidget);
    });

    testWidgets('keeps digits only, max 4, and shows them in the boxes', (tester) async {
      await tester.pumpWidget(_otp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '1a2b3c4d5');
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '1234');
      for (final d in ['1', '2', '3', '4']) {
        expect(find.text(d), findsOneWidget);
      }
    });

    testWidgets('verifying an incomplete code explains what is missing', (tester) async {
      await tester.pumpWidget(_otp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '12');
      await tester.tap(find.text('Verify & Login'));
      await tester.pumpAndSettle();
      expect(find.text('Enter all 4 digits'), findsOneWidget);
    });
  });

  testWidgets('splash moves on to login when there is no saved session', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_app(const AuthGate()));
    await tester.pump();
    expect(find.text('PreLoved Toys'), findsOneWidget);
    expect(find.text('Log in or sign up'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Log in or sign up'), findsOneWidget);
  });

  group('friendlyError', () {
    test('shows the server message', () {
      final e = Exception(
        'Error: 403 {"message":"This account has been blocked. Please contact support.","code":"ACCOUNT_BLOCKED"}',
      );
      expect(friendlyError(e), 'This account has been blocked. Please contact support.');
      expect(isAccountBlocked(e), isTrue);
    });

    test('explains network problems', () {
      expect(
        friendlyError(Exception('Network Error: ClientException: Connection refused')),
        contains("Can't reach PreLoved Toys"),
      );
    });

    test('falls back to a generic message', () {
      expect(friendlyError(Exception('Error: 500 <html>oops</html>')), contains('error 500'));
      expect(friendlyError(StateError('x')), 'Something went wrong. Please try again.');
    });
  });
}
