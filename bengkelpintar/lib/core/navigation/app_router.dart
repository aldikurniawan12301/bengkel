import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../role/role_provider.dart';
import '../../features/access/access_denied_screen.dart';
import '../../features/auth/server_settings_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/diagnosis/diagnosis_screens.dart';
import '../../features/pos/pos_screens.dart';
import '../../features/pos/cashier_screen.dart';
import '../../features/admin/admin_screens.dart';
import '../../features/pos/product_form_screen.dart';
import '../../features/pos/service_form_screen.dart';
import '../../features/pos/product_detail_screen.dart';
import '../../features/admin/data_master_screen.dart';
import '../../features/admin/symptom_list_screen.dart';
import '../../features/admin/damage_list_screen.dart';
import '../../features/admin/user_list_screen.dart';
import '../../features/admin/server_unreachable_screen.dart';
import '../../features/admin/reset_password_screen.dart';
import '../../features/admin/symptom_form_screen.dart';
import '../../features/admin/damage_form_screen.dart';
import '../../features/admin/user_form_screen.dart';
import '../../features/pos/transaction_detail_screen.dart';
import '../../features/laporan/sales_report_screen.dart';
import '../../features/laporan/diagnosis_statistics_screen.dart';
import '../../data/models/hasil_diagnosis.dart';
import '../../data/models/transaksi.dart';
import '../../data/models/user.dart';
import '../../data/models/gejala.dart';
import '../../data/models/kerusakan.dart';
import '../../data/models/riwayat_diagnosis.dart';
import '../../data/models/produk.dart';
import '../../data/models/jasa.dart';
import '../../features/placeholder/placeholder_screen.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings, UserRole role) {
    final routeName = settings.name ?? AppRoutes.splash;
    if (!AppRouteGuard.canAccess(routeName, role)) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: AppRoutes.accessDenied),
        builder: (_) => const AccessDeniedScreen(),
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => _pageFor(routeName, role, settings.arguments),
    );
  }

  static Widget _pageFor(String routeName, UserRole role, Object? arguments) {
    if (routeName == AppRoutes.accessDenied) {
      return const AccessDeniedScreen();
    }
    if (routeName == AppRoutes.serverSettings) {
      return const ServerSettingsScreen();
    }
    if (routeName == AppRoutes.login) {
      return const LoginScreen();
    }
    if (routeName == AppRoutes.splash) {
      return const SplashScreen();
    }
    if (routeName == AppRoutes.home) {
      return _HomeRoute(role: role);
    }
    if (routeName == AppRoutes.diagnosis && arguments is HasilDiagnosis) {
      return DiagnosisResultScreen(result: arguments);
    }
    if (routeName == AppRoutes.diagnosis) return const SymptomScreen();
    if (routeName == AppRoutes.history) return const HistoryScreen();
    if (routeName == AppRoutes.historyDetail && arguments is RiwayatDiagnosis) {
      return DiagnosisResultScreen(result: arguments.hasil, history: arguments);
    }
    if (routeName == AppRoutes.historyDetail && arguments is HasilDiagnosis) {
      return DiagnosisResultScreen(result: arguments);
    }
    if (routeName == AppRoutes.transactions) {
      return const TransactionListScreen();
    }
    if (routeName == AppRoutes.cashier) {
      final entry = arguments is CashierEntry ? arguments : null;
      return CashierScreen(entry: entry);
    }
    if (routeName == AppRoutes.productPicker) {
      return const CashierScreen();
    }
    if (routeName == AppRoutes.productCatalog) {
      return const CatalogScreen();
    }
    if (routeName == AppRoutes.serviceCatalog) {
      return const CatalogScreen(services: true);
    }
    if (routeName == AppRoutes.draft) {
      return DraftScreen(
        transaction: arguments is Transaksi ? arguments : null,
        initialItems: arguments is List<ItemTransaksiRequest>
            ? arguments
            : null,
        initialItem: arguments is ItemTransaksiRequest
            ? arguments
            : arguments is Produk
            ? ItemTransaksiRequest(tipe: 'produk', id: arguments.id, jumlah: 1)
            : arguments is Jasa
            ? ItemTransaksiRequest(tipe: 'jasa', id: arguments.id, jumlah: 1)
            : null,
      );
    }
    if (routeName == AppRoutes.profile) return const ProfileScreen();
    if (routeName == AppRoutes.changePassword) {
      return const ChangePasswordScreen();
    }
    if (routeName == AppRoutes.workshopSettings) {
      return const WorkshopSettingsScreen();
    }
    if (routeName == AppRoutes.categoryList) return const CategoryScreen();
    if (routeName == AppRoutes.productForm) {
      return ProductFormScreen(product: arguments is Produk ? arguments : null);
    }
    if (routeName == AppRoutes.serviceForm) {
      return ServiceFormScreen(service: arguments is Jasa ? arguments : null);
    }
    if (routeName == AppRoutes.productDetail && arguments is Produk) {
      return ProductDetailScreen(product: arguments);
    }
    if (routeName == AppRoutes.transactionDetail && arguments is Transaksi) {
      return TransactionDetailScreen(transaction: arguments);
    }
    if (routeName == AppRoutes.symptomForm) {
      return SymptomFormScreen(symptom: arguments is Gejala ? arguments : null);
    }
    if (routeName == AppRoutes.damageForm) {
      return DamageFormScreen(
        damage: arguments is Kerusakan ? arguments : null,
      );
    }
    if (routeName == AppRoutes.userForm) {
      return UserFormScreen(user: arguments is User ? arguments : null);
    }
    if (routeName == AppRoutes.dataMaster) return const DataMasterScreen();
    if (routeName == AppRoutes.symptomList) return const SymptomListScreen();
    if (routeName == AppRoutes.damageList) return const DamageListScreen();
    if (routeName == AppRoutes.manageUsers) return const UserListScreen();
    if (routeName == AppRoutes.reports) return const SalesReportScreen();
    if (routeName == AppRoutes.diagnosisStatistics) {
      return const DiagnosisStatisticsScreen();
    }
    if (routeName == AppRoutes.serverUnreachable) {
      return const ServerUnreachableScreen();
    }
    if (routeName == AppRoutes.resetPassword && arguments is User) {
      return ResetPasswordScreen(user: arguments);
    }
    if (routeName == AppRoutes.finalize && arguments is Transaksi) {
      return FinalizationScreen(transaction: arguments);
    }
    if (routeName == AppRoutes.receipt && arguments is Transaksi) {
      return ReceiptScreen(transaction: arguments);
    }
    return PlaceholderScreen(routeName: routeName);
  }
}

class _HomeRoute extends StatelessWidget {
  const _HomeRoute({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final child = HomeScreen(role: role);
    if (context.read<RoleProvider?>() != null) return child;
    return ChangeNotifierProvider.value(
      value: RoleProvider()..setRole(role),
      child: child,
    );
  }
}
