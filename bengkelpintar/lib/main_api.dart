import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/server_config.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/app_routes.dart';
import 'core/pos/draft_cart_controller.dart';
import 'core/role/role_provider.dart';
import 'core/theme/app_system_ui.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_scaffold.dart';
import 'features/auth/splash_screen.dart';
import 'services/api_client.dart';
import 'services/api_services.dart';
import 'services/service_interfaces.dart';

/// Navigator key global untuk menangani navigasi dari callback ApiClient.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Mode API: aplikasi terhubung ke server FastAPI.
///
/// File ini adalah entry point alternatif untuk build yang menggunakan
/// server sungguhan (produksi atau demo dengan server di laptop).
/// Untuk mode mock, gunakan main.dart.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[BP] 1 sebelum configure');
  try {
    await AppSystemUi.configure().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('[BP] configure gagal/timeout: $e');
  }
  debugPrint('[BP] 2 sebelum runApp');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final Future<ServerConfig> _serverConfig = () async {
    debugPrint('[BP] 3 ServerConfig.load mulai');
    final c = await ServerConfig.load();
    debugPrint('[BP] 4 ServerConfig.load selesai');
    return c;
  }();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoleProvider(),
      child: FutureBuilder<ServerConfig>(
        future: _serverConfig,
        builder: (context, configSnapshot) {
          final roleProvider = context.read<RoleProvider>();
          final config = configSnapshot.data;
          if (config == null) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              home: const SplashScreen(checkSession: false),
            );
          }

          return MultiProvider(
            providers: [
              ChangeNotifierProvider<ServerConfig>.value(value: config),
              ChangeNotifierProvider(create: (_) => DraftCartController()),
              Provider<ApiClient>(
                create: (_) {
                  final client = ApiClient(
                    baseUrlProvider: () => config.effectiveUrl,
                  );
                  // Callback untuk error jaringan menggunakan navigatorKey
                  client.onUnauthorized = () {
                    _navigateToLogin();
                  };
                  client.onForbidden = () {
                    _navigateToAccessDenied();
                  };
                  client.onNetworkError = () {
                    _navigateToServerUnreachable();
                  };
                  return client;
                },
              ),
              // Services menggunakan API
              Provider<AuthService>(
                create: (ctx) => ApiAuthService(ctx.read<ApiClient>()),
              ),
              Provider<ServerService>(
                create: (ctx) => ApiServerService(ctx.read<ApiClient>()),
              ),
              Provider<DiagnosisService>(
                create: (ctx) => ApiDiagnosisService(ctx.read<ApiClient>()),
              ),
              Provider<ProdukService>(
                create: (ctx) => ApiProdukService(ctx.read<ApiClient>()),
              ),
              Provider<JasaService>(
                create: (ctx) => ApiJasaService(ctx.read<ApiClient>()),
              ),
              Provider<TransaksiService>(
                create: (ctx) => ApiTransaksiService(ctx.read<ApiClient>()),
              ),
              Provider<LaporanService>(
                create: (ctx) => ApiLaporanService(ctx.read<ApiClient>()),
              ),
              Provider<PenggunaService>(
                create: (ctx) => ApiPenggunaService(ctx.read<ApiClient>()),
              ),
              Provider<KerusakanService>(
                create: (ctx) => ApiKerusakanService(ctx.read<ApiClient>()),
              ),
              Provider<KategoriService>(
                create: (ctx) => ApiKategoriService(ctx.read<ApiClient>()),
              ),
              Provider<PengaturanBengkelService>(
                create: (ctx) =>
                    ApiPengaturanBengkelService(ctx.read<ApiClient>()),
              ),
            ],
            child: _app(roleProvider, const SplashScreen()),
          );
        },
      ),
    );
  }

  MaterialApp _app(RoleProvider roleProvider, Widget home) => MaterialApp(
    navigatorKey: navigatorKey,
    title: 'BengkelPintar',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: home,
    builder: (context, child) => AppViewport(child: child!),
    onGenerateRoute: (settings) =>
        AppRouter.onGenerateRoute(settings, roleProvider.role),
  );

  /// Navigasi ke layar login saat token kedaluwarsa.
  void _navigateToLogin() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    });
  }

  /// Navigasi ke layar akses ditolak.
  void _navigateToAccessDenied() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(AppRoutes.accessDenied);
    });
  }

  /// Navigasi ke layar server tidak terjangkau.
  void _navigateToServerUnreachable() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(AppRoutes.serverUnreachable);
    });
  }
}
