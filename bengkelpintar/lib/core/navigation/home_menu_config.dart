import 'app_routes.dart';
import '../role/role_provider.dart';

class HomeMenuItem {
  const HomeMenuItem({required this.label, required this.route});

  final String label;
  final String route;
}

abstract final class HomeMenuConfig {
  static List<HomeMenuItem> forRole(UserRole role) {
    if (role == UserRole.admin) {
      return const [
        HomeMenuItem(label: 'Diagnosis', route: AppRoutes.diagnosis),
        HomeMenuItem(label: 'Transaksi', route: AppRoutes.transactions),
        HomeMenuItem(label: 'Produk', route: AppRoutes.productCatalog),
        HomeMenuItem(label: 'Jasa', route: AppRoutes.serviceCatalog),
        HomeMenuItem(label: 'Laporan', route: AppRoutes.reports),
        HomeMenuItem(label: 'Pengguna', route: AppRoutes.manageUsers),
        HomeMenuItem(label: 'Data Master', route: AppRoutes.dataMaster),
      ];
    }
    return const [
      HomeMenuItem(label: 'Diagnosis', route: AppRoutes.diagnosis),
      HomeMenuItem(label: 'Riwayat', route: AppRoutes.history),
      HomeMenuItem(label: 'Draft', route: AppRoutes.draft),
    ];
  }

  static List<HomeMenuItem> bottomNavigationFor(UserRole role) {
    return role == UserRole.admin
        ? const [
            HomeMenuItem(label: 'Beranda', route: AppRoutes.home),
            HomeMenuItem(label: 'Transaksi', route: AppRoutes.transactions),
            HomeMenuItem(label: 'Diagnosis', route: AppRoutes.diagnosis),
            HomeMenuItem(label: 'Katalog', route: AppRoutes.productCatalog),
            HomeMenuItem(label: 'Profil', route: AppRoutes.profile),
          ]
        : const [
            HomeMenuItem(label: 'Beranda', route: AppRoutes.home),
            HomeMenuItem(label: 'Riwayat', route: AppRoutes.history),
            HomeMenuItem(label: 'Diagnosis', route: AppRoutes.diagnosis),
            HomeMenuItem(label: 'Draft', route: AppRoutes.draft),
            HomeMenuItem(label: 'Profil', route: AppRoutes.profile),
          ];
  }
}
