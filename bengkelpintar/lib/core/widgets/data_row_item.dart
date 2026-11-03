import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';

class DataRowItem extends StatelessWidget {
  const DataRowItem({
    super.key,
    required this.label,
    required this.value,
    this.total = false,
  });
  final String label;
  final String value;
  final bool total;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: AppColors.border,
          style: total ? BorderStyle.none : BorderStyle.solid,
          width: AppSpacing.borderWidth,
        ),
      ),
    ),
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: total ? AppText.heading : AppText.body),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: total ? AppText.heading : AppText.subheading,
            ),
          ),
        ),
      ],
    ),
  );
}
