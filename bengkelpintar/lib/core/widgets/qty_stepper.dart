import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'circle_icon_button.dart';

class QtyStepper extends StatelessWidget {
  const QtyStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.minimum = 1,
  });
  final int value;
  final ValueChanged<int> onChanged;
  final int minimum;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleIconButton(
        icon: AppIcons.remove,
        tooltip: 'Kurangi',
        compact: true,
        medium: true,
        onPressed: value <= minimum ? null : () => onChanged(value - 1),
      ),
      SizedBox(
        width: AppSpacing.lg,
        child: Text(
          '$value',
          textAlign: TextAlign.center,
          style: AppText.subheading,
        ),
      ),
      CircleIconButton(
        icon: AppIcons.addRounded,
        tooltip: 'Tambah',
        primary: true,
        compact: true,
        medium: true,
        onPressed: () => onChanged(value + 1),
      ),
    ],
  );
}
