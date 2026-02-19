import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitcheck/Domain/repositories/auth_repository.dart';
import 'package:fitcheck/Presentation/App/app_style/password_field.dart';
import 'package:fitcheck/Presentation/auth/pages/login_page.dart';
import 'package:fitcheck/Presentation/auth/pages/register_page.dart';
import 'package:fitcheck/Presentation/auth/provider/auth_provider.dart';

// Simple fake to keep tests fast and predictable.
class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Empty fields');
    }
    return;
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return;
  }
}

void main() {
  group('Login Page Tests', () {
    testWidgets('Email field is visible', (WidgetTester tester) async {
      // MaterialApp gives the page a proper Material context.
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Password field is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      expect(find.byType(PasswordField), findsOneWidget);
    });

    testWidgets('Password visibility toggles when eye icon is tapped',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordField(controller),
          ),
        ),
      );

      TextField textField = tester.widget(find.byType(TextField));
      expect(textField.obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility));
      // pump() rebuilds after the state change.
      await tester.pump();

      textField = tester.widget(find.byType(TextField));
      expect(textField.obscureText, isFalse);
    });

    testWidgets('Login button is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('Sign up link opens Register page',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      // The "Sign up" link can be off-screen in test viewports.
      final signUpLink = find.widgetWithText(TextButton, 'Sign up');
      await tester.dragUntilVisible(
        signUpLink,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.tap(signUpLink);

      // Wait for the page transition animation to finish.
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('Shows error message when fields are empty',
        (WidgetTester tester) async {
      // Fake repo forces a predictable error path without network calls.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      // Let the SnackBar animation complete.
      await tester.pumpAndSettle();

      expect(find.textContaining('Login failed'), findsOneWidget);
    });

    testWidgets('Email field, password field and login button are all visible together',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(),
        ),
      );

      expect(find.byType(TextField), findsWidgets);

      expect(find.byType(PasswordField), findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('Login flow shows success SnackBar when sign-in succeeds',
        (WidgetTester tester) async {
      // Use FakeAuthRepository to avoid network calls.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.pump();

      await tester.enterText(find.byType(PasswordField), 'password123');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      // Let the SnackBar animation complete.
      await tester.pumpAndSettle();

      expect(find.text('Login successful!'), findsOneWidget);
    });

    testWidgets('Successful login with valid email and password inputs are accepted',
        (WidgetTester tester) async {
      // Use FakeAuthRepository to avoid network calls.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'user@example.com');
      await tester.pump();

      expect(find.text('user@example.com'), findsWidgets);

      final passwordField = find.byType(PasswordField);
      await tester.enterText(passwordField, 'securePassword123');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Login successful!'), findsOneWidget);
    });
  });
}
