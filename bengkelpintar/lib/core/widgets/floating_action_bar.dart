import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_spacing.dart';
import 'app_button.dart';

class FloatingActionBar extends StatelessWidget {
  const FloatingActionBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = AppIcons.arrowForward,
    this.bottom = true,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool bottom;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.pageMargin,
        AppSpacing.pageMargin,
        AppSpacing.pageMargin + (bottom ? safeBottom : 0),
      ),
      child: AppButton.primary(label: label, onPressed: onPressed, icon: icon),
    );
  }
}
