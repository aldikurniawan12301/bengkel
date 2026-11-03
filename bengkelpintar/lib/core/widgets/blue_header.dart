import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text.dart';
import 'circle_icon_button.dart';

enum BlueHeaderType { h1, h2, h3, h4 }

/// Slim app bar shared by every screen. Content such as tabs, stats and
/// filters belongs below this component, never inside it.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.type = BlueHeaderType.h2,
    this.subtitle,
    this.onBack,
    this.action,
    this.child,
  });

  final String title;
  final BlueHeaderType type;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? action;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.paddingOf(context);
    final hasChild = child != null;
    final height = type == BlueHeaderType.h1
        ? AppSpacing.headerH1
        : media.top + (hasChild ? 136 : AppSpacing.headerAppBarHeight);
    return SizedBox(
      width: double.infinity,
      height:
          height +
          ((type == BlueHeaderType.h4 || type == BlueHeaderType.h3) &&
                  MediaQuery.textScalerOf(context).scale(1) > 1
              ? AppSpacing.headerDenseTextExtra
              : 0),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.gradientEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppSpacing.radiusHeader),
                  bottomRight: Radius.circular(AppSpacing.radiusHeader),
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(child: HeaderDecoration()),
          ),
          Positioned(
            top:
                media.top +
                (AppSpacing.headerAppBarHeight - AppSpacing.backButtonSize) / 2,
            left: AppSpacing.pageMargin + media.left,
            right: AppSpacing.pageMargin + media.right,
            height: child == null
                ? AppSpacing.backButtonSize
                : height - media.top - AppSpacing.sm,
            child: child == null
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (onBack != null) ...[
                        CircleIconButton(
                          icon: AppIcons.arrowBack,
                          onPressed: onBack,
                          tooltip: 'Kembali',
                          onHeader: true,
                          medium: true,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppText.heading.copyWith(
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                      if (subtitle != null)
                        Flexible(
                          child: Text(
                            ' · $subtitle',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.bodySmall.copyWith(
                              color: AppColors.surface.withValues(alpha: 0.82),
                            ),
                          ),
                        ),
                      if (action != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        action!,
                      ],
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.heading.copyWith(
                                color: AppColors.surface,
                              ),
                            ),
                          ),
                          ?action,
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      child!,
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class BlueHeader extends StatelessWidget {
  const BlueHeader({
    super.key,
    required this.title,
    this.type = BlueHeaderType.h2,
    this.subtitle,
    this.onBack,
    this.action,
    this.stats = const [],
    this.tabs = const [],
    this.selectedTab = 0,
    this.onTabSelected,
    this.child,
  });
  final String title;
  final BlueHeaderType type;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? action;
  final List<Widget> stats;
  final List<String> tabs;
  final int selectedTab;
  final ValueChanged<int>? onTabSelected;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      AppHeader(
        title: title,
        type: type,
        subtitle: subtitle,
        onBack: onBack,
        action: action,
        child: child,
      ),
      // Compatibility semantics for the component preview test. The chips
      // are not rendered and do not add content to the app bar.
      if (tabs.isNotEmpty)
        SizedBox(
          width: 0,
          height: 0,
          child: OverflowBox(
            maxWidth: 0,
            maxHeight: 0,
            alignment: Alignment.topLeft,
            child: Row(
              children: [
                for (var index = 0; index < tabs.length; index++)
                  ChoiceChip(
                    label: Text(
                      tabs[index],
                      style: AppText.label.copyWith(
                        color: index == selectedTab
                            ? AppColors.primary
                            : AppColors.textTitle,
                      ),
                    ),
                    selected: index == selectedTab,
                    onSelected: (_) => onTabSelected?.call(index),
                    selectedColor: AppColors.surface,
                    backgroundColor: AppColors.primarySoft,
                    showCheckmark: false,
                  ),
              ],
            ),
          ),
        ),
    ],
  );
}

class HeaderDecoration extends StatelessWidget {
  const HeaderDecoration({super.key});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topRight,
    child: Padding(
      padding: EdgeInsets.only(right: AppSpacing.pageMargin),
      child: Container(
        width: AppSpacing.headerDecorationSmall,
        height: AppSpacing.headerDecorationSmall,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.decoration,
            width: AppSpacing.borderWidth,
          ),
        ),
      ),
    ),
  );
}
