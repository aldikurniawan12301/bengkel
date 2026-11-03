import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    super.key,
    this.height = AppSpacing.inputHeight,
    this.width,
  });
  final double height;
  final double? width;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        gradient: LinearGradient(
          begin: Alignment(-1 + _controller.value * 2, 0),
          end: Alignment(1 + _controller.value * 2, 0),
          colors: const [
            AppColors.primarySoft,
            AppColors.surface,
            AppColors.primarySoft,
          ],
        ),
      ),
    ),
  );
}
