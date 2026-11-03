import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: AppSpacing.switchWidth,
    height: AppSpacing.switchHeight,
    child: Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: const WidgetStatePropertyAll(AppColors.surface),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.disabled,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(AppColors.transparent),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  );
}
