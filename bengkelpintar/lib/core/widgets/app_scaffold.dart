import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The single shell used by every screen. It keeps edge-to-edge rendering and
/// keyboard resizing in one place; individual surfaces only decide their
/// visual layout.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.backgroundColor = AppColors.background,
    this.extendBody = true,
  });

  final Widget body;
  final Color backgroundColor;
  final bool extendBody;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor,
    extendBody: extendBody,
    resizeToAvoidBottomInset: true,
    body: body,
  );
}

/// Installed at the app root so dialogs, sheets and snackbars share the same
/// cutout-aware viewport even when a legacy screen still owns its Scaffold.
class AppViewport extends StatelessWidget {
  const AppViewport({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      MediaQuery(data: MediaQuery.of(context), child: child);
}

/// Insets that are safe for cutouts, gesture navigation and the keyboard.
abstract final class AppInsets {
  static EdgeInsets horizontal(BuildContext context) {
    final media = MediaQuery.of(context);
    return EdgeInsets.only(
      left: media.padding.left,
      right: media.padding.right,
    );
  }

  static double bottom(BuildContext context, {double extra = 0}) {
    final media = MediaQuery.of(context);
    return math.max(
          math.max(media.padding.bottom, media.viewPadding.bottom),
          media.viewInsets.bottom,
        ) +
        extra;
  }

  static EdgeInsets page(
    BuildContext context, {
    double top = 0,
    double bottom = 0,
  }) {
    final media = MediaQuery.of(context);
    return EdgeInsets.fromLTRB(
      AppSpacing.pageMargin + media.padding.left,
      top,
      AppSpacing.pageMargin + media.padding.right,
      bottom,
    );
  }
}

class AppBottomActionBar extends StatelessWidget {
  const AppBottomActionBar({
    super.key,
    required this.child,
    this.info,
    this.stacked = false,
  });

  final Widget child;
  final Widget? info;
  final bool stacked;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    elevation: 0,
    shadowColor: AppColors.shadowStrong,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageMargin + MediaQuery.paddingOf(context).left,
        AppSpacing.md,
        AppSpacing.pageMargin + MediaQuery.paddingOf(context).right,
        MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => stacked
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (info != null) ...[
                    info!,
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  child,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (info != null) ...[
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: info!,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: info == null
                          ? constraints.maxWidth
                          : constraints.maxWidth * 0.58,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: child,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}

class AppSheetPadding extends StatelessWidget {
  const AppSheetPadding({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => SafeArea(
    left: true,
    right: true,
    top: false,
    bottom: true,
    child: Padding(padding: padding ?? AppSpacing.cardInsets, child: child),
  );
}
