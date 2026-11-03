import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

import 'package:provider/provider.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_horizontal_chip_list.dart';
import '../../core/widgets/app_search_bar.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/error_state.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/role/role_provider.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/widgets/status_badge.dart';
import '../../services/service_interfaces.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.services = false});

  final bool services;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<dynamic>> _future;
  String _query = '';
  String _category = 'Semua';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _reload() {
    _future = widget.services
        ? context.read<JasaService>().listServices(query: _query)
        : context.read<ProdukService>().listProducts(query: _query);
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<RoleProvider?>()?.role ?? UserRole.admin;
    return AppScaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BlueHeader(
            title: 'Katalog',
            type: BlueHeaderType.h4,
            onBack: () => Navigator.maybePop(context),
            action: role == UserRole.admin
                ? CircleIconButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      widget.services
                          ? AppRoutes.serviceForm
                          : AppRoutes.productForm,
                    ).then((_) => setState(_reload)),
                    tooltip: 'Tambah ${widget.services ? 'jasa' : 'produk'}',
                    icon: AppIcons.addRounded,
                    medium: true,
                    onHeader: true,
                  )
                : null,
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingSkeleton();
                }
                if (snapshot.hasError) {
                  return ErrorState(
                    message: 'Katalog belum dapat dimuat.',
                    onRetry: () => setState(_reload),
                  );
                }
                final raw = snapshot.data ?? const <dynamic>[];
                final items = raw.where((item) {
                  if (item.aktif != true) return false;
                  if (widget.services || _category == 'Semua') return true;
                  return item.kategoriNama == _category;
                }).toList();
                return ListView(
                  padding: AppInsets.page(
                    context,
                    top: AppSpacing.contentTopGap,
                    bottom: AppSpacing.xl,
                  ),
                  children: [
                    _SegmentedCatalogControl(
                      services: widget.services,
                      onChanged: (services) => Navigator.pushReplacementNamed(
                        context,
                        services
                            ? AppRoutes.serviceCatalog
                            : AppRoutes.productCatalog,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppSearchBar(
                      hintText: widget.services ? 'Cari jasa' : 'Cari produk',
                      onChanged: (value) => setState(() {
                        _query = value;
                        _reload();
                      }),
                    ),
                    if (!widget.services) ...[
                      const SizedBox(height: AppSpacing.md),
                      _CategoryFilter(
                        selected: _category,
                        items: [
                          'Semua',
                          ...{
                            for (final item in raw)
                              if (item.aktif == true) item.kategoriNama,
                          },
                        ],
                        onChanged: (value) => setState(() => _category = value),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    if (items.isEmpty)
                      EmptyState(
                        title: widget.services
                            ? 'Belum ada jasa'
                            : 'Belum ada produk',
                        message:
                            'Coba kata kunci lain atau tambahkan data baru.',
                      )
                    else
                      for (final item in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _CatalogRow(
                            name: item.nama,
                            price: item.harga,
                            category: widget.services
                                ? null
                                : item.kategoriNama,
                            service: widget.services,
                            quantity: 0,
                            stock: widget.services ? null : item.stok,
                            lowStock:
                                !widget.services &&
                                item.stok <= item.stokMinimum,
                            onTap: () => Navigator.pushNamed(
                              context,
                              widget.services
                                  ? AppRoutes.serviceForm
                                  : AppRoutes.productDetail,
                              arguments: item,
                            ),
                            onAdd: null,
                            onQuantityChanged: (_) {},
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedCatalogControl extends StatelessWidget {
  const _SegmentedCatalogControl({
    required this.services,
    required this.onChanged,
  });
  final bool services;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final entry in [(false, 'Produk'), (true, 'Jasa')])
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: entry.$1 ? 0 : AppSpacing.sm),
            child: OutlinedButton(
              onPressed: () => onChanged(entry.$1),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.formInputHeight),
                backgroundColor: services == entry.$1
                    ? AppColors.primary
                    : AppColors.surface,
                foregroundColor: services == entry.$1
                    ? AppColors.surface
                    : AppColors.textTitle,
                side: BorderSide(
                  color: services == entry.$1
                      ? AppColors.primary
                      : AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(entry.$2),
            ),
          ),
        ),
    ],
  );
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.selected,
    required this.items,
    required this.onChanged,
  });
  final String selected;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => AppHorizontalChipList(
    children: [
      for (final item in items.toSet())
        AppChip(
          label: item,
          selected: item == selected,
          onSelected: (_) => onChanged(item),
        ),
    ],
  );
}

class _CatalogRow extends StatelessWidget {
  const _CatalogRow({
    required this.name,
    required this.price,
    required this.category,
    required this.service,
    required this.quantity,
    required this.stock,
    required this.lowStock,
    required this.onTap,
    required this.onAdd,
    required this.onQuantityChanged,
  });
  final String name;
  final int price;
  final String? category;
  final bool service;
  final int quantity;
  final int? stock;
  final bool lowStock;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      side: const BorderSide(color: AppColors.border),
    ),
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            CategoryIcon(
              category: category,
              service: service,
              size: AppSpacing.catalogIconSize,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.subheading,
                  ),
                  Text(
                    service ? 'Jasa' : '${category ?? 'Produk'} · Stok $stock',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySmall,
                  ),
                  if (lowStock && !service)
                    StatusBadge(status: AppStatus.stokMenipis),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              formatRupiah(price),
              style: AppText.subheading.copyWith(color: AppColors.textTitle),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              AppIcons.chevronRight,
              size: AppSpacing.iconSmall,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    ),
  );
}
