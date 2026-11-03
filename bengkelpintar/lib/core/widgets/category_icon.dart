import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    this.category,
    this.service = false,
    this.size,
  });

  final String? category;
  final bool service;
  final double? size;

  @override
  Widget build(BuildContext context) => Container(
    width: size ?? (service ? 44 : AppSpacing.productIcon),
    height: size ?? (service ? 44 : AppSpacing.productIcon),
    decoration: BoxDecoration(
      color: AppColors.primarySoft,
      shape: service ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: service ? null : BorderRadius.circular(AppSpacing.radiusMd),
    ),
    child: Icon(
      service ? AppIcons.handymanRounded : _iconFor(category),
      color: AppColors.primary,
      size: service ? AppSpacing.iconSmall : AppSpacing.icon,
    ),
  );

  IconData _iconFor(String? value) {
    final normalized = (value ?? '').toLowerCase();
    if (normalized.contains('pengapian') || normalized.contains('busi')) {
      return AppIcons.flare;
    }
    if (normalized.contains('pelumas') || normalized.contains('oli')) {
      return AppIcons.roundedWaterDrop;
    }
    if (normalized.contains('rem')) return AppIcons.albumRounded;
    if (normalized.contains('transmisi')) return AppIcons.roundedSettings;
    if (normalized.contains('listrik') || normalized.contains('aki')) {
      return AppIcons.bolt;
    }
    if (normalized.contains('filter')) return AppIcons.roundedFilterAlt;
    return AppIcons.roundedInventory;
  }
}
