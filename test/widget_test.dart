import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rydu_user/app/app.dart';
import 'package:rydu_user/app/providers/shared_preferences_provider.dart';
import 'package:rydu_user/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:rydu_user/features/auth/presentation/state/auth_session_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState.unauthenticated();

  @override
  Future<void> restore() async {
    state = const AuthSessionState.unauthenticated();
  }
}

void main() {
  testWidgets('RyduUserApp shows splash branding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authSessionProvider.overrideWith(_TestAuthSessionNotifier.new),
        ],
        child: const RyduUserApp(),
      ),
    );

    await tester.pump();
    expect(find.text('RYD U'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Welcome to RYD U'), findsOneWidget);
  });
}
