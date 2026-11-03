import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/navigation/home_menu_config.dart';
import '../../core/pos/draft_cart_controller.dart';
import '../../core/role/role_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_horizontal_chip_list.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/app_search_bar.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/qty_stepper.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/jasa.dart';
import '../../data/models/produk.dart';
import '../../data/models/transaksi.dart';
import '../../services/service_interfaces.dart';

class CashierEntry {
  const CashierEntry({this.clear = false, this.items});

  final bool clear;
  final List<ItemTransaksiRequest>? items;
}

class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key, this.entry});

  final CashierEntry? entry;

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  late Future<_CashierData> _future;
  late final TextEditingController _customer;
  late final TextEditingController _plate;
  String _query = '';
  String _category = 'Semua';
  bool _products = true;

  @override
  void initState() {
    super.initState();
    final cart = context.read<DraftCartController?>();
    if (widget.entry?.clear == true) cart?.clear();
    if (widget.entry?.items != null) cart?.replace(widget.entry!.items!);
    _customer = TextEditingController(text: cart?.customerName ?? '');
    _plate = TextEditingController(text: cart?.plateNumber ?? '');
    final productService = context.read<ProdukService>();
    final serviceService = context.read<JasaService>();
    _future = _load(productService, serviceService);
  }

  Future<_CashierData> _load(
    ProdukService productService,
    JasaService serviceService,
  ) async {
    final productService = context.read<ProdukService>();
    final serviceService = context.read<JasaService>();
    final products = await productService.listProducts(query: _query);
    final services = await serviceService.listServices(query: _query);
    return _CashierData(products: products, services: services);
  }

  @override
  void dispose() {
    _customer.dispose();
    _plate.dispose();
    super.dispose();
  }

  void _refresh() {
    final productService = context.read<ProdukService>();
    final serviceService = context.read<JasaService>();
    setState(() => _future = _load(productService, serviceService));
  }

  void _syncCustomer() => context.read<DraftCartController?>()?.setCustomer(
    name: _customer.text,
    plate: _plate.text,
  );

  Future<void> _editCustomer() async {
    final name = TextEditingController(text: _customer.text);
    final plate = TextEditingController(text: _plate.text);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.lg,
          AppSpacing.pageMargin,
          AppInsets.bottom(sheetContext, extra: AppSpacing.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Data pelanggan', style: AppText.heading),
            const SizedBox(height: AppSpacing.lg),
            const Text('Nama pelanggan', style: AppText.label),
            const SizedBox(height: AppSpacing.xs),
            TextField(controller: name),
            const SizedBox(height: AppSpacing.md),
            const Text('Plat nomor', style: AppText.label),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: plate,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton.primary(
              label: 'Simpan',
              onPressed: () => Navigator.pop(sheetContext, true),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !mounted) {
      name.dispose();
      plate.dispose();
      return;
    }
    _customer.text = name.text;
    _plate.text = plate.text;
    _syncCustomer();
    name.dispose();
    plate.dispose();
    setState(() {});
  }

  void _openDraft() {
    final cart = context.read<DraftCartController>();
    if (cart.isEmpty) return;
    Navigator.pushNamed(context, AppRoutes.draft, arguments: cart.requests);
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<RoleProvider?>()?.role ?? UserRole.mechanic;
    final nav = HomeMenuConfig.bottomNavigationFor(role);
    final cart = context.watch<DraftCartController>();
    return AppScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              BlueHeader(
                title: 'Kasir',
                type: BlueHeaderType.h4,
                action: CircleIconButton(
                  icon: role == UserRole.admin
                      ? AppIcons.inventory
                      : AppIcons.description,
                  tooltip: role == UserRole.admin
                      ? 'Kelola katalog'
                      : 'Draft Saya',
                  medium: true,
                  onHeader: true,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    role == UserRole.admin
                        ? AppRoutes.productCatalog
                        : AppRoutes.transactions,
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<_CashierData>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingSkeleton();
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: AppButton.secondary(
                          label: 'Coba lagi',
                          onPressed: _refresh,
                        ),
                      );
                    }
                    final data = snapshot.data ?? const _CashierData();
                    final List<dynamic> visible = _products
                        ? <dynamic>[
                            ...data.products.where(
                              (item) =>
                                  item.aktif &&
                                  (_category == 'Semua' ||
                                      item.kategoriNama == _category),
                            ),
                          ]
                        : <dynamic>[
                            ...data.services.where((item) => item.aktif),
                          ];
                    return ListView(
                      padding: AppInsets.page(
                        context,
                        top: AppSpacing.contentTopGap,
                        bottom: AppSpacing.bottomBarClearance + 88,
                      ),
                      children: [
                        _CustomerCard(
                          name: _customer.text,
                          plate: _plate.text,
                          onTap: _editCustomer,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SegmentedCashier(
                          products: _products,
                          onChanged: (value) => setState(() {
                            _products = value;
                            _category = 'Semua';
                          }),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppSearchBar(
                          hintText: _products ? 'Cari produk' : 'Cari jasa',
                          onChanged: (value) {
                            _query = value;
                            _refresh();
                          },
                        ),
                        if (_products) ...[
                          const SizedBox(height: AppSpacing.md),
                          AppHorizontalChipList(
                            children: [
                              for (final category in {
                                'Semua',
                                ...data.products
                                    .where((item) => item.aktif)
                                    .map((item) => item.kategoriNama),
                              })
                                AppChip(
                                  label: category,
                                  selected: category == _category,
                                  onSelected: (_) =>
                                      setState(() => _category = category),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        if (visible.isEmpty)
                          const EmptyState(
                            title: 'Belum ada item',
                            message: 'Coba kata kunci atau kategori lain.',
                          )
                        else if (_products)
                          for (final product in visible)
                            _CashierItemRow(
                              name: product.nama,
                              category: product.kategoriNama,
                              description: 'Stok ${product.stok}',
                              price: product.harga,
                              quantity: cart.quantity('produk', product.id),
                              stock: product.stok,
                              disabled: product.stok == 0,
                              onAdd: () => cart.add(
                                'produk',
                                product.id,
                                price: product.harga,
                                limit: product.stok,
                              ),
                              onQuantityChanged: (value) =>
                                  cart.setQuantity('produk', product.id, value),
                            )
                        else
                          for (final service in visible)
                            _CashierItemRow(
                              name: service.nama,
                              category: null,
                              description: 'Jasa',
                              price: service.harga,
                              quantity: cart.quantity('jasa', service.id),
                              onAdd: () => cart.add(
                                'jasa',
                                service.id,
                                price: service.harga,
                              ),
                              onQuantityChanged: (value) =>
                                  cart.setQuantity('jasa', service.id, value),
                            ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          if (!cart.isEmpty)
            Positioned(
              left: AppSpacing.pageMargin,
              right: AppSpacing.pageMargin,
              bottom:
                  AppSpacing.navContentHeight +
                  MediaQuery.paddingOf(context).bottom +
                  AppSpacing.sm,
              child: _CartBar(cart: cart, onTap: _openDraft),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingNavBar(
              items: [for (final item in nav) item.label],
              selectedIndex: 3,
              onSelected: (index) {
                final route = nav[index].route;
                if (route != AppRoutes.cashier) {
                  Navigator.pushReplacementNamed(context, route);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CashierData {
  const _CashierData({this.products = const [], this.services = const []});
  final List<Produk> products;
  final List<Jasa> services;
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({
    required this.name,
    required this.plate,
    required this.onTap,
  });

  final String name;
  final String plate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = name.trim().isEmpty ? 'Pelanggan Umum' : name.trim();
    final detail = plate.trim().isEmpty ? null : plate.trim();
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: SizedBox(
          height: AppSpacing.touchMin + AppSpacing.sm,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(AppIcons.person, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    detail == null ? title : '$title · $detail',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body.copyWith(
                      color: name.trim().isEmpty
                          ? AppColors.textMuted
                          : AppColors.textBody,
                    ),
                  ),
                ),
                const Icon(AppIcons.edit, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SegmentedCashier extends StatelessWidget {
  const _SegmentedCashier({required this.products, required this.onChanged});
  final bool products;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: AppButton(
          label: 'Produk',
          variant: products
              ? AppButtonVariant.primary
              : AppButtonVariant.secondary,
          onPressed: () => onChanged(true),
          height: AppSpacing.inputHeight,
        ),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: AppButton(
          label: 'Jasa',
          variant: products
              ? AppButtonVariant.secondary
              : AppButtonVariant.primary,
          onPressed: () => onChanged(false),
          height: AppSpacing.inputHeight,
        ),
      ),
    ],
  );
}

class _CashierItemRow extends StatelessWidget {
  const _CashierItemRow({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.quantity,
    required this.onAdd,
    required this.onQuantityChanged,
    this.stock,
    this.disabled = false,
  });

  final String name;
  final String? category;
  final String description;
  final int price;
  final int quantity;
  final int? stock;
  final VoidCallback onAdd;
  final ValueChanged<int> onQuantityChanged;
  final bool disabled;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Material(
      color: disabled ? AppColors.surfaceRaised : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CategoryIcon(
              category: category,
              service: stock == null,
              size: AppSpacing.circleSmall,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.subheading,
                  ),
                  Text(description, style: AppText.bodySmall),
                  Text(formatRupiah(price), style: AppText.body),
                  if (disabled) const StatusBadge(status: AppStatus.stokHabis),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (quantity > 0)
              QtyStepper(value: quantity, onChanged: onQuantityChanged)
            else
              CircleIconButton(
                icon: AppIcons.addRounded,
                tooltip: 'Tambah',
                primary: true,
                medium: true,
                onPressed: disabled ? null : onAdd,
              ),
          ],
        ),
      ),
    ),
  );
}

class _CartBar extends StatelessWidget {
  const _CartBar({required this.cart, required this.onTap});
  final DraftCartController cart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final total = cart.requests.fold(
      0,
      (sum, item) => sum + cart.price(item.tipe, item.id) * item.jumlah,
    );
    return Material(
      color: AppColors.navy,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(
                AppIcons.roundedShoppingCart,
                color: AppColors.surface,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${cart.itemCount} item · ${formatRupiah(total)}',
                  style: AppText.body.copyWith(color: AppColors.surface),
                ),
              ),
              Text(
                'Lihat Keranjang',
                style: AppText.label.copyWith(color: AppColors.surface),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(AppIcons.chevronRight, color: AppColors.surface),
            ],
          ),
        ),
      ),
    );
  }
}
