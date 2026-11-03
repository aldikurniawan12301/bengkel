import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppHorizontalChipList extends StatelessWidget {
  const AppHorizontalChipList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    return Transform.translate(
      offset: Offset(-(AppSpacing.pageMargin + media.left), 0),
      child: SizedBox(
        width: width,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            left: AppSpacing.pageMargin + media.left,
            right: AppSpacing.pageMargin + media.right,
          ),
          child: Row(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(width: AppSpacing.sm),
                children[index],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
