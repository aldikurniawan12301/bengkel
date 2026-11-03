import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/pos/draft_cart_controller.dart';
import '../../core/role/role_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/list_card.dart';
import '../../core/widgets/qty_stepper.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/jasa.dart';
import '../../data/models/produk.dart';
import '../../data/models/transaksi.dart';
import '../../services/service_interfaces.dart';

class DraftScreen extends StatefulWidget {
  const DraftScreen({
    super.key,
    this.transaction,
    this.initialItem,
    this.initialItems,
  });

  final Transaksi? transaction;
  final ItemTransaksiRequest? initialItem;
  final List<ItemTransaksiRequest>? initialItems;

  @override
  State<DraftScreen> createState() => _DraftScreenState();
}

class _DraftScreenState extends State<DraftScreen> {
  late Transaksi _transaction;
  late final TextEditingController _customer;
  late final TextEditingController _plate;
  final _items = <ItemTransaksi>[];
  final _stockByProduct = <int, int>{};
  bool _saving = false;
  bool _initialItemLoaded = false;

  bool get _isAdmin => context.read<RoleProvider?>()?.role == UserRole.admin;
  bool get _isFinal => _transaction.status != 'draft';

  @override
  void initState() {
    super.initState();
    _transaction =
        widget.transaction ??
        Transaksi(
          id: 0,
          nomor: 'Draft Baru',
          status: 'draft',
          namaPelanggan: '',
          platNomor: '',
          total: 0,
          dibuatOleh: '',
          dibuatOlehId: 0,
          waktu: DateTime(2026, 10, 24, 10, 15),
          items: [],
        );
    _items.addAll(_transaction.items);
    _customer = TextEditingController(text: _transaction.namaPelanggan);
    _plate = TextEditingController(text: _transaction.platNomor);
    if (widget.initialItem != null || widget.initialItems != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialItem());
    }
  }

  @override
  void dispose() {
    _customer.dispose();
    _plate.dispose();
    super.dispose();
  }

  Future<void> _loadInitialItem() async {
    if (_initialItemLoaded ||
        (widget.initialItem == null && widget.initialItems == null)) {
      return;
    }
    _initialItemLoaded = true;
    final productService = context.read<ProdukService>();
    final serviceService = context.read<JasaService>();
    final products = await productService.listProducts();
    final services = await serviceService.listServices();
    if (!mounted) return;
    final requests = <ItemTransaksiRequest>[
      if (widget.initialItem != null) widget.initialItem!,
      ...?widget.initialItems,
    ];
    if (requests.isEmpty) {
      final cart = context.read<DraftCartController?>();
      if (cart != null) requests.addAll(cart.requests);
    }
    for (final request in requests) {
      _addRequest(request, products, services);
    }
  }

  int get _total => _items.fold(0, (sum, item) => sum + item.subtotal);

  void _syncCart() {
    final cart = context.read<DraftCartController?>();
    if (cart == null) return;
    cart.replace(
      _items.map(
        (item) => ItemTransaksiRequest(
          tipe: item.tipe,
          id: item.tipe == 'produk' ? item.produkId! : item.jasaId!,
          jumlah: item.jumlah,
        ),
      ),
    );
  }

  void _addRequest(
    ItemTransaksiRequest request,
    List<Produk> products,
    List<Jasa> services,
  ) {
    if (request.jumlah < 1) return;
    final existingIndex = _items.indexWhere(
      (item) =>
          item.tipe == request.tipe &&
          (item.tipe == 'produk' ? item.produkId : item.jasaId) == request.id,
    );
    final source = request.tipe == 'produk'
        ? _findProduct(products, request.id)
        : _findService(services, request.id);
    if (source == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item sudah tidak tersedia di katalog.')),
      );
      return;
    }
    if (request.tipe == 'produk') {
      _stockByProduct[request.id] = (source as Produk).stok;
    }
    setState(() {
      if (existingIndex >= 0) {
        final current = _items[existingIndex];
        _items[existingIndex] = _withQuantity(
          current,
          current.jumlah + request.jumlah,
        );
      } else if (request.tipe == 'produk') {
        final product = source as Produk;
        _items.add(
          ItemTransaksi(
            id: product.id,
            tipe: 'produk',
            produkId: product.id,
            nama: product.nama,
            jumlah: request.jumlah,
            hargaSatuan: product.harga,
            subtotal: product.harga * request.jumlah,
          ),
        );
      } else {
        final service = source as Jasa;
        _items.add(
          ItemTransaksi(
            id: service.id,
            tipe: 'jasa',
            jasaId: service.id,
            nama: service.nama,
            jumlah: request.jumlah,
            hargaSatuan: service.harga,
            subtotal: service.harga * request.jumlah,
          ),
        );
      }
    });
    _syncCart();
    _warnStock(request.tipe, request.id);
  }

  Produk? _findProduct(List<Produk> products, int id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Jasa? _findService(List<Jasa> services, int id) {
    for (final service in services) {
      if (service.id == id) return service;
    }
    return null;
  }

  ItemTransaksi _withQuantity(ItemTransaksi item, int quantity) =>
      ItemTransaksi(
        id: item.id,
        tipe: item.tipe,
        produkId: item.produkId,
        jasaId: item.jasaId,
        nama: item.nama,
        jumlah: quantity,
        hargaSatuan: item.hargaSatuan,
        subtotal: item.hargaSatuan * quantity,
      );

  void _warnStock(String type, int id) {
    if (type != 'produk') return;
    final item = _items.firstWhere((item) => item.produkId == id);
    final stock = _stockByProduct[id];
    if (stock != null && item.jumlah > stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok ${item.nama} tersisa $stock.')),
      );
    }
  }

  Future<void> _addItem() async {
    final productService = context.read<ProdukService>();
    final serviceService = context.read<JasaService>();
    final products = await productService.listProducts();
    final services = await serviceService.listServices();
    if (!mounted) return;
    final choice = await showModalBottomSheet<ItemTransaksiRequest>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AppSheetPadding(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text('Tambah Item', style: AppText.heading),
            for (final item in products.where((item) => item.aktif))
              _PickerRow(
                title: item.nama,
                subtitle: '${formatRupiah(item.harga)} · Stok ${item.stok}',
                icon: AppIcons.inventory,
                onTap: () => Navigator.pop(
                  context,
                  ItemTransaksiRequest(tipe: 'produk', id: item.id, jumlah: 1),
                ),
              ),
            for (final item in services.where((item) => item.aktif))
              _PickerRow(
                title: item.nama,
                subtitle: formatRupiah(item.harga),
                icon: AppIcons.handyman,
                onTap: () => Navigator.pop(
                  context,
                  ItemTransaksiRequest(tipe: 'jasa', id: item.id, jumlah: 1),
                ),
              ),
          ],
        ),
      ),
    );
    if (choice != null && mounted) _addRequest(choice, products, services);
  }

  void _changeQuantity(ItemTransaksi item, int quantity) {
    if (quantity < 1) return;
    setState(() {
      final index = _items.indexOf(item);
      if (index >= 0) _items[index] = _withQuantity(item, quantity);
    });
    _syncCart();
    if (item.produkId != null) _warnStock(item.tipe, item.produkId!);
  }

  void _removeItem(ItemTransaksi item) {
    setState(() => _items.remove(item));
    _syncCart();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final requests = _items
          .map(
            (item) => ItemTransaksiRequest(
              tipe: item.tipe,
              id: item.tipe == 'produk' ? item.produkId! : item.jasaId!,
              jumlah: item.jumlah,
            ),
          )
          .toList();
      final service = context.read<TransaksiService>();
      _transaction = _transaction.id == 0
          ? await service.createDraft(
              namaPelanggan: _customer.text.trim(),
              platNomor: _plate.text.trim(),
              items: requests,
            )
          : await service.updateDraft(_copyTransaction());
      if (!mounted) return;
      if (_isAdmin) {
        Navigator.pushNamed(
          context,
          AppRoutes.finalize,
          arguments: _transaction,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft transaksi disimpan.')),
        );
        Navigator.pop(context, _transaction);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Bad state: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Transaksi _copyTransaction() => Transaksi(
    id: _transaction.id,
    nomor: _transaction.nomor,
    status: _transaction.status,
    namaPelanggan: _customer.text.trim(),
    platNomor: _plate.text.trim(),
    total: _total,
    dibuatOleh: _transaction.dibuatOleh,
    dibuatOlehId: _transaction.dibuatOlehId,
    riwayatDiagnosisId: _transaction.riwayatDiagnosisId,
    waktu: _transaction.waktu,
    items: List<ItemTransaksi>.of(_items),
  );

  @override
  Widget build(BuildContext context) => AppScaffold(
    body: Column(
      children: [
        BlueHeader(
          title: 'Draft Transaksi',
          type: BlueHeaderType.h2,
          onBack: () => Navigator.maybePop(context),
          action: StatusBadge(
            status: _isFinal ? AppStatus.finalised : AppStatus.draft,
          ),
        ),
        Expanded(
          child: ListView(
            padding: AppInsets.page(
              context,
              top: AppSpacing.contentTopGap,
              bottom: AppSpacing.xl,
            ),
            children: [
              ListCard(
                title: 'Data pelanggan',
                footer: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Pelanggan',
                      style: AppText.label.copyWith(color: AppColors.textBody),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _customer,
                      enabled: !_isFinal,
                      decoration: const InputDecoration(
                        hintText: 'Nama Pelanggan',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Plat Nomor',
                      style: AppText.label.copyWith(color: AppColors.textBody),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _plate,
                      enabled: !_isFinal,
                      decoration: const InputDecoration(hintText: 'Plat Nomor'),
                    ),
                  ],
                ),
              ),
              if (_transaction.riwayatDiagnosisId != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Text(
                    'Referensi diagnosis #${_transaction.riwayatDiagnosisId}',
                    style: AppText.bodySmall,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              if (!_isFinal)
                AppButton.tonal(
                  label: 'Tambah item',
                  icon: AppIcons.add,
                  onPressed: _addItem,
                ),
              const SizedBox(height: AppSpacing.md),
              if (_items.isEmpty)
                const EmptyState(
                  title: 'Belum ada item',
                  message: 'Tambahkan produk atau jasa ke draft ini.',
                  icon: AppIcons.shoppingCart,
                )
              else
                for (final item in _items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ListCard(
                      title: item.nama,
                      subtitle:
                          '${item.jumlah} x ${formatRupiah(item.hargaSatuan)}',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatRupiah(item.subtotal),
                            style: AppText.subheading.copyWith(
                              color: AppColors.textTitle,
                            ),
                          ),
                        ],
                      ),
                      footer: _isFinal
                          ? null
                          : Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${formatRupiah(item.hargaSatuan)} / item',
                                    style: AppText.bodySmall,
                                  ),
                                ),
                                QtyStepper(
                                  value: item.jumlah,
                                  onChanged: (value) =>
                                      _changeQuantity(item, value),
                                ),
                                IconButton(
                                  onPressed: () => _removeItem(item),
                                  tooltip: 'Hapus item',
                                  icon: const Icon(AppIcons.delete),
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                    ),
                  ),
              ListCard(
                title: 'Total',
                trailing: Text(
                  formatRupiah(_total),
                  style: AppText.metric.copyWith(color: AppColors.textTitle),
                ),
              ),
            ],
          ),
        ),
        if (!_isFinal)
          AppBottomActionBar(
            stacked: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: AppText.subheading),
                    Text(
                      formatRupiah(_total),
                      style: AppText.subheading.copyWith(
                        color: AppColors.textTitle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton.primary(
                  label: _isAdmin ? 'Lanjut ke Pembayaran' : 'Simpan Draft',
                  onPressed: _saving ? null : _save,
                  icon: _isAdmin ? AppIcons.arrowForward : null,
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(AppIcons.addRounded),
    onTap: onTap,
  );
}
