import '../role/role_provider.dart';

abstract final class AppRoutes {
  static const splash = '/splash';
  static const home = '/home';
  static const serverSettings = '/server-settings';
  static const login = '/login';
  static const diagnosis = '/diagnosis';
  static const history = '/history';
  static const transactions = '/transactions';
  static const draft = '/draft';
  static const cashier = '/cashier';
  static const finalize = '/finalize';
  static const receipt = '/receipt';
  static const productCatalog = '/catalog/products';
  static const serviceCatalog = '/catalog/services';
  static const dataMaster = '/data-master';
  static const manageUsers = '/manage-users';
  static const reports = '/reports';
  static const profile = '/profile';
  static const historyDetail = '/history/detail';
  static const transactionDetail = '/transaction/detail';
  static const productPicker = '/product-picker';
  static const productForm = '/product/form';
  static const serviceForm = '/service/form';
  static const productDetail = '/product/detail';
  static const symptomForm = '/symptom/form';
  static const damageForm = '/damage/form';
  static const userForm = '/user/form';
  static const accessDenied = '/access-denied';
  static const symptomList = '/symptoms';
  static const damageList = '/damages';
  static const changePassword = '/change-password';
  static const resetPassword = '/reset-password';
  static const workshopSettings = '/workshop-settings';
  static const serverUnreachable = '/server-unreachable';
  static const categoryList = '/categories';
  static const diagnosisStatistics = '/diagnosis-statistics';

  static const titles = <String, String>{
    home: 'Beranda',
    login: 'Login',
    serverSettings: 'Pengaturan Server',
    diagnosis: 'Diagnosis',
    history: 'Riwayat Diagnosis',
    transactions: 'Transaksi',
    draft: 'Draft Transaksi',
    cashier: 'Kasir',
    finalize: 'Finalisasi dan Nota',
    productCatalog: 'Produk',
    serviceCatalog: 'Jasa',
    dataMaster: 'Data Gejala dan Kerusakan',
    manageUsers: 'Kelola Pengguna',
    reports: 'Laporan',
    profile: 'Profil',
    historyDetail: 'Detail Riwayat Diagnosis',
    transactionDetail: 'Detail Transaksi',
    productPicker: 'Pemilih Produk dan Jasa',
    productForm: 'Produk',
    serviceForm: 'Jasa',
    productDetail: 'Detail Produk',
    symptomForm: 'Gejala',
    damageForm: 'Kerusakan',
    userForm: 'Pengguna',
    accessDenied: 'Akses Ditolak',
    symptomList: 'Daftar Gejala',
    damageList: 'Daftar Kerusakan',
    changePassword: 'Ganti Password',
    resetPassword: 'Reset Password',
    workshopSettings: 'Pengaturan Bengkel',
    serverUnreachable: 'Server Tidak Terjangkau',
    categoryList: 'Kategori Produk',
    diagnosisStatistics: 'Statistik Diagnosis',
  };

  static String titleFor(String routeName) => titles[routeName] ?? 'Tujuan';

  /// Halaman yang ditandai hanya untuk admin di docs/HALAMAN.md.
  static const adminOnly = <String>{
    serverSettings,
    finalize,
    productCatalog,
    serviceCatalog,
    dataMaster,
    manageUsers,
    reports,
    transactionDetail,
    receipt,
    productForm,
    serviceForm,
    productDetail,
    symptomForm,
    damageForm,
    userForm,
    symptomList,
    damageList,
    resetPassword,
    workshopSettings,
    categoryList,
    diagnosisStatistics,
  };
}

abstract final class AppRouteGuard {
  static bool canAccess(String routeName, UserRole role) {
    return role == UserRole.admin || !AppRoutes.adminOnly.contains(routeName);
  }

  static String routeFor(String routeName, UserRole role) {
    return canAccess(routeName, role) ? routeName : AppRoutes.accessDenied;
  }
}
