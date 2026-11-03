import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'app_scaffold.dart';

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.label,
    this.hint = 'Pilih',
  });
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final field = InkWell(
      onTap: onChanged == null
          ? null
          : () async {
              final selected = await showModalBottomSheet<T>(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusXl),
                  ),
                ),
                builder: (context) => AppSheetPadding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: AppSpacing.xxl,
                          height: AppSpacing.xs,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(label ?? hint, style: AppText.heading),
                        const SizedBox(height: AppSpacing.sm),
                        ...items
                            .where((item) => item.value != null)
                            .map(
                              (item) => ListTile(
                                title: item.child,
                                trailing: item.value == value
                                    ? const Icon(
                                        AppIcons.check,
                                        color: AppColors.primary,
                                      )
                                    : null,
                                onTap: () => Navigator.pop(context, item.value),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              );
              if (selected != null) onChanged!(selected);
            },
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppText.bodySmall,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: value == null
                  ? Text(
                      hint,
                      style: AppText.body.copyWith(color: AppColors.textMuted),
                    )
                  : items.firstWhere((item) => item.value == value).child,
            ),
            const Icon(
              AppIcons.keyboardArrowDownRounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
    return field;
  }
}
