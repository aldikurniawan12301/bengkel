import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bengkelpintar/core/config/server_config.dart';
import 'package:bengkelpintar/core/navigation/app_routes.dart';
import 'package:bengkelpintar/core/navigation/app_router.dart';
import 'package:bengkelpintar/core/role/role_provider.dart';
import 'package:bengkelpintar/core/theme/app_theme.dart';
import 'package:bengkelpintar/data/models/user.dart';
import 'package:bengkelpintar/features/auth/server_settings_screen.dart';
import 'package:bengkelpintar/features/auth/splash_screen.dart';
import 'package:bengkelpintar/features/home/home_screen.dart';
import 'package:bengkelpintar/services/service_interfaces.dart';

class _NoSessionAuthService implements AuthService {
  @override
  Future<User?> currentUser() async => null;

  @override
  Future<User?> login(String username, String password) async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async =>
      false;
}

class _UserAuthService implements AuthService {
  @override
  Future<User?> currentUser() async =>
      const User(id: 1, nama: 'Admin', peran: 'admin');

  @override
  Future<User?> login(String username, String password) async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async =>
      false;
}

class _SuccessfulServerService implements ServerService {
  @override
  Future<bool> checkHealth(String baseUrl) async => true;
}

class _RecordingObserver extends NavigatorObserver {
  final pushedRoutes = <String?>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route.settings.name);
    super.didPush(route, previousRoute);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ServerConfig> config() async {
    SharedPreferences.setMockInitialValues({});
    return ServerConfig.load();
  }

  testWidgets('Splash tanpa sesi menuju Login', (tester) async {
    final serverConfig = await config();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: _NoSessionAuthService()),
          ChangeNotifierProvider<ServerConfig>.value(value: serverConfig),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: (settings) =>
              AppRouter.onGenerateRoute(settings, UserRole.mechanic),
          home: const SplashScreen(sessionCheckDelay: Duration.zero),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.text('Selamat datang kembali'), findsOneWidget);
  });

  testWidgets('Splash dengan sesi menuju Beranda', (tester) async {
    final serverConfig = await config();
    final observer = _RecordingObserver();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: _UserAuthService()),
          ChangeNotifierProvider<ServerConfig>.value(value: serverConfig),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          navigatorObservers: [observer],
          onGenerateRoute: (settings) =>
              AppRouter.onGenerateRoute(settings, UserRole.admin),
          home: const SplashScreen(sessionCheckDelay: Duration.zero),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Splash hanya tampil sekali dan Beranda tidak membuka Splash', (
    tester,
  ) async {
    final serverConfig = await config();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: _UserAuthService()),
          ChangeNotifierProvider<ServerConfig>.value(value: serverConfig),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          onGenerateRoute: (settings) =>
              AppRouter.onGenerateRoute(settings, UserRole.admin),
          home: const SplashScreen(sessionCheckDelay: Duration.zero),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);

    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
  });

  testWidgets('mekanik ditolak di Pengaturan Server', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        onGenerateRoute: (settings) =>
            AppRouter.onGenerateRoute(settings, UserRole.mechanic),
        initialRoute: AppRoutes.serverSettings,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Akses Ditolak'), findsOneWidget);
    expect(find.text('Pengaturan Server'), findsNothing);
  });

  testWidgets('Pengaturan Server tidak overflow pada 320 dan teks 130%', (
    tester,
  ) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(320, 800);
    view.platformDispatcher.textScaleFactorTestValue = 1.3;
    final serverConfig = await config();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ServerConfig>.value(value: serverConfig),
          Provider<ServerService>.value(value: _SuccessfulServerService()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ServerSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Alamat Server'), findsWidgets);
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
    view.platformDispatcher.clearTextScaleFactorTestValue();
  });
}
