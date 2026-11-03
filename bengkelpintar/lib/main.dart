import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/server_config.dart';
import 'core/navigation/app_router.dart';
import 'core/pos/draft_cart_controller.dart';
import 'core/role/role_provider.dart';
import 'core/theme/app_system_ui.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_scaffold.dart';
import 'data/models/user.dart';
import 'features/auth/splash_screen.dart';
import 'services/mock_services.dart';
import 'services/mock_store.dart';
import 'services/mock_failure.dart';
import 'services/service_interfaces.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSystemUi.configure();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final Future<MockStore> _mockStore = MockStore.load();
  static final Future<ServerConfig> _serverConfig = ServerConfig.load();
  static final MockFailureController _mockFailure = MockFailureController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RoleProvider(),
      child: FutureBuilder<MockStore>(
        future: _mockStore,
        builder: (context, snapshot) {
          final roleProvider = context.read<RoleProvider>();
          final store = snapshot.data;
          if (store == null) {
            return _app(roleProvider, const SplashScreen(checkSession: false));
          }

          return FutureBuilder<ServerConfig>(
            future: _serverConfig,
            builder: (context, configSnapshot) {
              final config = configSnapshot.data;
              if (config == null) {
                return _app(
                  roleProvider,
                  const SplashScreen(checkSession: false),
                );
              }

              MockFailureController.global = _mockFailure;
              User activeUser() => store.users.firstWhere(
                (user) =>
                    user.peran ==
                    (roleProvider.role == UserRole.admin ? 'admin' : 'mekanik'),
              );

              return MultiProvider(
                providers: [
                  Provider<MockStore>.value(value: store),
                  ChangeNotifierProvider<ServerConfig>.value(value: config),
                  ChangeNotifierProvider<MockFailureController>.value(
                    value: _mockFailure,
                  ),
                  Provider<AuthService>(create: (_) => MockAuthService(store)),
                  Provider<ServerService>(create: (_) => MockServerService()),
                  Provider<DiagnosisService>(
                    create: (_) => MockDiagnosisService(store, activeUser),
                  ),
                  Provider<ProdukService>(
                    create: (_) => MockProdukService(store, activeUser),
                  ),
                  Provider<JasaService>(
                    create: (_) => MockJasaService(store, activeUser),
                  ),
                  Provider<TransaksiService>(
                    create: (_) => MockTransaksiService(store, activeUser),
                  ),
                  Provider<LaporanService>(
                    create: (_) => MockLaporanService(store, activeUser),
                  ),
                  Provider<PenggunaService>(
                    create: (_) => MockPenggunaService(store, activeUser),
                  ),
                  Provider<KerusakanService>(
                    create: (_) => MockKerusakanService(store, activeUser),
                  ),
                  Provider<KategoriService>(
                    create: (_) => MockKategoriService(store, activeUser),
                  ),
                  Provider<PengaturanBengkelService>(
                    create: (_) =>
                        MockPengaturanBengkelService(store, activeUser),
                  ),
                  ChangeNotifierProvider(create: (_) => DraftCartController()),
                ],
                child: _app(roleProvider, const SplashScreen()),
              );
            },
          );
        },
      ),
    );
  }

  MaterialApp _app(RoleProvider roleProvider, Widget home) => MaterialApp(
    title: 'BengkelPintar',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: home,
    builder: (context, child) => AppViewport(child: child!),
    onGenerateRoute: (settings) =>
        AppRouter.onGenerateRoute(settings, roleProvider.role),
  );
}
