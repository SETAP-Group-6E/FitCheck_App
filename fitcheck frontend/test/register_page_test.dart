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
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      throw Exception('All fields are required');
    }
  }
}

void main() {
  group('Register Page Tests', () {
    testWidgets('Name field is visible', (WidgetTester tester) async {
      // MaterialApp gives the page a proper Material context.
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Email field is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('Password field is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
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

    testWidgets('Register button is visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    });

    testWidgets('Login link opens Login page', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      // The "Login" link can be off-screen in test viewports.
      final loginLink = find.widgetWithText(TextButton, 'Login');
      await tester.dragUntilVisible(
        loginLink,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.tap(loginLink);

      // Wait for the page transition animation to finish.
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Name, email, password fields and register button are all visible together',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterPage(),
        ),
      );

      expect(find.byType(TextField), findsWidgets);

      expect(find.byType(PasswordField), findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
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
            home: RegisterPage(),
          ),
        ),
      );

      // Scroll the button into view before tapping.
      final registerButton = find.widgetWithText(ElevatedButton, 'Register');
      await tester.dragUntilVisible(
        registerButton,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.tap(registerButton);
      // Let the SnackBar animation complete.
      await tester.pumpAndSettle();

      expect(find.textContaining('Error'), findsOneWidget);
    });

    testWidgets('Register flow shows success SnackBar when sign-up succeeds',
        (WidgetTester tester) async {
      // Use FakeAuthRepository to avoid network calls.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(
            home: RegisterPage(),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField).at(0),
        'John Doe',
      );
      await tester.pump();

      await tester.enterText(
        find.byType(TextField).at(1),
        'john@example.com',
      );
      await tester.pump();

      await tester.enterText(
        find.byType(PasswordField),
        'password123',
      );
      await tester.pump();

      // Scroll the button into view before tapping.
      final registerButton = find.widgetWithText(ElevatedButton, 'Register');
      await tester.dragUntilVisible(
        registerButton,
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.tap(registerButton);
      // Let the SnackBar animation complete.
      await tester.pumpAndSettle();

      expect(find.text('Success! Check your email.'), findsOneWidget);
    });
  });
}
