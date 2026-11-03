import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:bengkelpintar/core/navigation/app_routes.dart';
import 'package:bengkelpintar/core/navigation/app_router.dart';
import 'package:bengkelpintar/core/role/role_provider.dart';

void main() {
  test('mekanik ditolak di rute admin', () {
    expect(
      AppRouteGuard.canAccess(AppRoutes.reports, UserRole.mechanic),
      isFalse,
    );
    expect(
      AppRouteGuard.routeFor(AppRoutes.reports, UserRole.mechanic),
      AppRoutes.accessDenied,
    );
  });

  test('admin diterima di rute admin', () {
    expect(AppRouteGuard.canAccess(AppRoutes.reports, UserRole.admin), isTrue);
    expect(
      AppRouteGuard.routeFor(AppRoutes.reports, UserRole.admin),
      AppRoutes.reports,
    );
  });

  test('mekanik diterima di rute bersama', () {
    expect(
      AppRouteGuard.canAccess(AppRoutes.history, UserRole.mechanic),
      isTrue,
    );
    expect(
      AppRouteGuard.routeFor(AppRoutes.history, UserRole.mechanic),
      AppRoutes.history,
    );
  });

  testWidgets('mekanik melihat Akses Ditolak saat membuka rute admin', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) =>
            AppRouter.onGenerateRoute(settings, UserRole.mechanic),
        initialRoute: AppRoutes.reports,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Akses Ditolak'), findsOneWidget);
    expect(find.text('Halaman ini hanya untuk admin'), findsOneWidget);
  });

  testWidgets('admin membuka placeholder rute admin', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) =>
            AppRouter.onGenerateRoute(settings, UserRole.admin),
        initialRoute: AppRoutes.reports,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Laporan'), findsOneWidget);
    expect(find.text('Laporan belum dapat dimuat.'), findsOneWidget);
  });

  testWidgets('Akses Ditolak tidak overflow pada lebar target', (tester) async {
    final view = tester.view;
    view.devicePixelRatio = 1;
    view.physicalSize = const Size(320, 800);
    view.platformDispatcher.textScaleFactorTestValue = 1.3;
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) =>
            AppRouter.onGenerateRoute(settings, UserRole.mechanic),
        initialRoute: AppRoutes.reports,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
    view.platformDispatcher.clearTextScaleFactorTestValue();
  });
}
