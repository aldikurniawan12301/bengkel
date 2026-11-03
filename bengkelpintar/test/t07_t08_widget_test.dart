import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bengkelpintar/core/role/role_provider.dart';
import 'package:bengkelpintar/core/theme/app_theme.dart';
import 'package:bengkelpintar/data/models/user.dart';
import 'package:bengkelpintar/data/models/hasil_diagnosis.dart';
import 'package:bengkelpintar/data/models/riwayat_diagnosis.dart';
import 'package:bengkelpintar/data/models/statistik_diagnosis.dart';
import 'package:bengkelpintar/features/auth/login_screen.dart';
import 'package:bengkelpintar/features/home/home_screen.dart';
import 'package:bengkelpintar/services/mock_services.dart';
import 'package:bengkelpintar/services/mock_store.dart';
import 'package:bengkelpintar/services/service_interfaces.dart';

class _LoginAuthService implements AuthService {
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

class _ImmediateDiagnosisService implements DiagnosisService {
  @override
  Future<HasilDiagnosis?> diagnose(List<int> gejalaIds) async => null;

  @override
  Future<List<RiwayatDiagnosis>> listHistory() async => const [];

  @override
  Future<RiwayatDiagnosis?> getHistory(int id) async => null;
  @override
  Future<StatistikDiagnosis> getStatistics() async =>
      const StatistikDiagnosis(total: 0, items: []);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MockStore> store() => MockStore.load();

  test('login menyimpan sesi dan logout menghapusnya', () async {
    SharedPreferences.setMockInitialValues({});
    final mockStore = await store();
    final auth = MockAuthService(mockStore);

    expect((await auth.login('budi', 'budi123'))?.nama, 'Budi Santoso');
    expect((await auth.currentUser())?.username, 'budi');
    await auth.logout();
    expect(await auth.currentUser(), isNull);
  });

  testWidgets('Login menampilkan validasi dan error kredensial', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: _LoginAuthService()),
          ChangeNotifierProvider(create: (_) => RoleProvider()),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
      ),
    );
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    expect(find.text('Kolom ini wajib diisi.'), findsOneWidget);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'budi');
    await tester.enterText(fields.at(1), 'salah');
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Nama pengguna atau kata sandi salah.'), findsOneWidget);
  });

  testWidgets('Beranda tidak overflow di 320 dan teks 130%', (tester) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(320, 800);
    view.platformDispatcher.textScaleFactorTestValue = 1.3;
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => RoleProvider()),
          Provider<DiagnosisService>.value(value: _ImmediateDiagnosisService()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HomeScreen(role: UserRole.admin),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
    view.platformDispatcher.clearTextScaleFactorTestValue();
  });
}
