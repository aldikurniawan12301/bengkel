import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:bengkelpintar/core/navigation/app_router.dart';
import 'package:bengkelpintar/core/role/role_provider.dart';
import 'package:bengkelpintar/core/theme/app_theme.dart';
import 'package:bengkelpintar/data/models/user.dart';
import 'package:bengkelpintar/features/admin/profile_screen.dart';
import 'package:bengkelpintar/features/auth/login_screen.dart';
import 'package:bengkelpintar/features/auth/splash_screen.dart';
import 'package:bengkelpintar/features/home/home_screen.dart';
import 'package:bengkelpintar/services/service_interfaces.dart';

class _Auth implements AuthService {
  _Auth(this.expectedUsername, this.expectedPassword, this.user);

  final String expectedUsername;
  final String expectedPassword;
  final User user;
  User? session;

  @override
  Future<User?> currentUser() async => session;

  @override
  Future<User?> login(String username, String password) async {
    if (username != expectedUsername || password != expectedPassword) {
      return null;
    }
    session = user;
    return user;
  }

  @override
  Future<void> logout() async => session = null;

  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async =>
      false;
}

class _PendingAuth implements AuthService {
  final currentUserCompleter = Completer<User?>();

  @override
  Future<User?> currentUser() => currentUserCompleter.future;

  @override
  Future<User?> login(String username, String password) async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async =>
      false;
}

Widget _routedApp({required AuthService auth, required Widget home}) {
  final role = RoleProvider();
  return MultiProvider(
    providers: [
      Provider<AuthService>.value(value: auth),
      ChangeNotifierProvider.value(value: role),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      home: home,
      onGenerateRoute: (settings) =>
          AppRouter.onGenerateRoute(settings, role.role),
    ),
  );
}

Future<void> _pumpBriefly(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login admin berakhir di Beranda', (tester) async {
    final auth = _Auth(
      'admin',
      'admin123',
      const User(id: 1, nama: 'Andi Pratama', peran: 'admin'),
    );
    await tester.pumpWidget(_routedApp(auth: auth, home: const LoginScreen()));
    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'admin123');
    await tester.tap(find.text('Masuk'));
    await _pumpBriefly(tester);
    expect(tester.takeException(), isNull);

    expect(find.text('Andi Pratama'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('login budi berakhir di Beranda', (tester) async {
    final auth = _Auth(
      'budi',
      'budi123',
      const User(id: 2, nama: 'Budi Santoso', peran: 'mekanik'),
    );
    await tester.pumpWidget(_routedApp(auth: auth, home: const LoginScreen()));
    await tester.enterText(find.byType(TextField).at(0), 'budi');
    await tester.enterText(find.byType(TextField).at(1), 'budi123');
    await tester.tap(find.text('Masuk'));
    await _pumpBriefly(tester);
    expect(tester.takeException(), isNull);

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('login gagal tetap di Login dan berhenti memuat', (tester) async {
    final auth = _Auth(
      'admin',
      'admin123',
      const User(id: 1, nama: 'Andi Pratama', peran: 'admin'),
    );
    await tester.pumpWidget(_routedApp(auth: auth, home: const LoginScreen()));
    await tester.enterText(find.byType(TextField).at(0), 'admin');
    await tester.enterText(find.byType(TextField).at(1), 'salah');
    await tester.tap(find.text('Masuk'));
    await _pumpBriefly(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Nama pengguna atau kata sandi salah.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('logout kembali ke Login', (tester) async {
    final auth = _Auth(
      'admin',
      'admin123',
      const User(id: 1, nama: 'Andi Pratama', peran: 'admin'),
    )..session = const User(id: 1, nama: 'Andi Pratama', peran: 'admin');
    await tester.pumpWidget(
      _routedApp(auth: auth, home: const ProfileScreen()),
    );
    await _pumpBriefly(tester);
    await tester.tap(find.text('Keluar'));
    await _pumpBriefly(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Keluar'));
    await _pumpBriefly(tester);

    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(auth.session, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('sesi aktif saat dibuka menuju Beranda', (tester) async {
    final auth = _Auth(
      'budi',
      'budi123',
      const User(id: 2, nama: 'Budi Santoso', peran: 'mekanik'),
    )..session = const User(id: 2, nama: 'Budi Santoso', peran: 'mekanik');
    await tester.pumpWidget(
      _routedApp(
        auth: auth,
        home: const SplashScreen(sessionCheckDelay: Duration.zero),
      ),
    );
    await _pumpBriefly(tester);

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('latar Splash tetap selebar layar dengan inset samping', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(320, 800);
    for (final horizontalPadding in [0.0, 24.0]) {
      final auth = _PendingAuth();
      view.viewPadding = FakeViewPadding(
        left: horizontalPadding,
        right: horizontalPadding,
      );
      await tester.pumpWidget(
        _routedApp(
          auth: auth,
          home: const SplashScreen(sessionCheckDelay: Duration.zero),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1));

      final background = tester.renderObject<RenderBox>(
        find.byKey(const ValueKey('splash-background')),
      );
      expect(background.size.width, 320);
      expect(background.size.height, 800);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
    view.viewPadding = FakeViewPadding.zero;
  });

  for (final width in [320.0, 360.0, 412.0]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('Splash terpusat di $width dp dengan skala teks $scale', (
        tester,
      ) async {
        final view = tester.view;
        view.devicePixelRatio = 1;
        view.physicalSize = Size(width, 800);
        view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
        view.platformDispatcher.textScaleFactorTestValue = scale;
        await tester.pumpWidget(
          _routedApp(
            auth: _PendingAuth(),
            home: const SplashScreen(sessionCheckDelay: Duration.zero),
          ),
        );
        await tester.pump(const Duration(milliseconds: 1));

        final logo = tester.getRect(find.byKey(const ValueKey('splash-logo')));
        expect((logo.center.dx - width / 2).abs(), lessThanOrEqualTo(.5));
        expect((logo.center.dy - 400).abs(), lessThanOrEqualTo(.5));
        expect(find.byKey(const ValueKey('splash-name')), findsNothing);
        expect(find.textContaining('Diagnosis Cepat'), findsNothing);
        expect(find.textContaining('Cek kerusakan'), findsNothing);
        expect(find.text('Memuat...'), findsNothing);
        expect(find.text('Versi 1.0'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
        view.viewPadding = FakeViewPadding.zero;
        view.platformDispatcher.clearTextScaleFactorTestValue();
      });
    }
  }
}
