import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/blue_header.dart';
import '../../core/widgets/list_card.dart';

class DataMasterScreen extends StatelessWidget {
  const DataMasterScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        BlueHeader(
          title: 'Data Gejala dan Kerusakan',
          type: BlueHeaderType.h2,
          onBack: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: ListView(
            padding: AppSpacing.pageInsets,
            children: [
              const Card(
                child: Padding(
                  padding: AppSpacing.cardInsets,
                  child: Text(
                    'Mengubah daftar ini memerlukan pelatihan ulang model.',
                    style: AppText.poppinsBody,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListCard(
                title: 'Daftar Gejala',
                subtitle: 'Kelola gejala aktif dan nonaktif',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.symptomList),
              ),
              ListCard(
                title: 'Daftar Kerusakan',
                subtitle: 'Kelola kelas kerusakan dan penautan POS',
                onTap: () => Navigator.pushNamed(context, AppRoutes.damageList),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
