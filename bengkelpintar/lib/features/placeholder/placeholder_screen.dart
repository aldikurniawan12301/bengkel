import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/list_card.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BlueHeader(
            title: AppRoutes.titleFor(routeName),
            type: BlueHeaderType.h2,
            onBack: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.pageMargin),
              child: Center(
                child: ListCard(
                  title: 'Layar tujuan siap dibuka',
                  subtitle: 'Isi layar ini dikerjakan pada tugas berikutnya.',
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(
                      AppIcons.construction,
                      color: AppColors.primary,
                    ),
                  ),
                  footer: Text('Rute: $routeName', style: AppText.bodySmall),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
