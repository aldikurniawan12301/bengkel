import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.compact = false,
  });
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final contentHeight = AppSpacing.navContentHeight;
    return SizedBox(
      width: double.infinity,
      height: contentHeight + safeBottom,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusNav),
          ),
          boxShadow: [],
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: safeBottom),
          child: SizedBox(
            height: contentHeight,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(child: _item(i)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(int index) {
    final isDiagnosis = items[index].toLowerCase() == 'diagnosis';
    final selected = index == selectedIndex;
    if (isDiagnosis) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -AppSpacing.lg,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                width: AppSpacing.productIcon,
                height: AppSpacing.productIcon,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: AppSpacing.sm,
                  ),
                ),
                child: Icon(
                  AppIcons.stethoscope,
                  color: AppColors.primary,
                  size: AppSpacing.icon,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: AppSpacing.navActivePadding,
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Text(
                items[index],
                textAlign: TextAlign.center,
                style: AppText.bodySmall.copyWith(color: AppColors.surface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }
    return InkWell(
      onTap: () => onSelected(index),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(AppSpacing.navActivePadding),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : AppColors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              _iconFor(index),
              color: selected ? AppColors.primary : AppColors.primaryMuted,
              size: AppSpacing.icon,
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.navActivePadding,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  items[index],
                  style: AppText.bodySmall.copyWith(
                    color: selected
                        ? AppColors.primarySoft
                        : AppColors.primaryMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(int index) => switch (items[index].toLowerCase()) {
    'beranda' => AppIcons.home,
    'riwayat' => AppIcons.history,
    'transaksi' => AppIcons.receiptLong,
    'kasir' => AppIcons.pointOfSale,
    'draft' => AppIcons.description,
    'katalog' => AppIcons.inventory,
    'profil' => AppIcons.person,
    _ => AppIcons.roundedCircle,
  };
}
