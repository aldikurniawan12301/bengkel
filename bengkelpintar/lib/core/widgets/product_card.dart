import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import '../utils/formatters.dart';
import 'status_badge.dart';
import 'category_icon.dart';
import 'qty_stepper.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    this.category,
    this.stock,
    this.stockStatus = AppStatus.stokAman,
    this.quantity = 0,
    this.onAdd,
    this.onQuantityChanged,
    this.onTap,
  });
  final String name;
  final num price;
  final String? category;
  final int? stock;
  final AppStatus stockStatus;
  final int quantity;
  final VoidCallback? onAdd;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showStockBadge = stockStatus != AppStatus.stokAman;
    return Material(
      clipBehavior: Clip.antiAlias,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.cardPadding,
              vertical: AppSpacing.md,
            ),
            child: _gridCard(showStockBadge, constraints.maxWidth),
          ),
        ),
      ),
    );
  }

  Widget _details() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.subheading,
      ),
      Text(formatRupiah(price), style: AppText.body),
    ],
  );

  Widget _gridCard(bool showStockBadge, double width) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: AppSpacing.inputHeight / 3,
        child: showStockBadge
            ? Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(status: stockStatus),
              )
            : null,
      ),
      const SizedBox(height: AppSpacing.xs),
      Align(
        alignment: Alignment.center,
        child: CategoryIcon(
          category: category,
          size: width < AppSpacing.homeStatIconBox * 4
              ? AppSpacing.circleButton
              : AppSpacing.productIcon,
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      _details(),
      const SizedBox(height: AppSpacing.sm),
      const Divider(height: AppSpacing.sm),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (stock != null)
            Expanded(
              child: Text(
                'Stok $stock',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.bodySmall,
              ),
            ),
          quantity == 0
              ? _addButton(compact: true)
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: QtyStepper(
                    value: quantity,
                    onChanged: onQuantityChanged ?? (_) {},
                  ),
                ),
        ],
      ),
    ],
  );

  Widget _addButton({bool compact = false}) => SizedBox(
    width: compact ? AppSpacing.circleSmall : AppSpacing.touchMin,
    height: compact ? AppSpacing.circleSmall : AppSpacing.touchMin,
    child: IconButton(
      onPressed: onAdd,
      tooltip: 'Tambah ke draft',
      icon: const Icon(AppIcons.addRounded),
      color: AppColors.surface,
      style: IconButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        backgroundColor: AppColors.primary,
      ),
    ),
  );
}
