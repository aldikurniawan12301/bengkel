import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppText {
  static const display = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textTitle,
    letterSpacing: -0.6,
  );
  static const displayOnPrimary = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );
  static const title = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textTitle,
    letterSpacing: -0.2,
  );
  static const heading = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textTitle,
    letterSpacing: -0.1,
  );
  static const subheading = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textTitle,
  );
  static const homeDiagnosisTitle = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textTitle,
  );
  static const transactionAmount = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textTitle,
  );
  static const body = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
  );
  static const bodySmall = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
  static const label = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textTitle,
  );
  static const button = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
  );
  static const overline = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.primary,
  );
  static const statNumber = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );

  static const splashTitle = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 38,
    height: 1.12,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
    letterSpacing: -1.2,
  );

  static const splashTagline = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.surface,
  );

  static const splashSubtitle = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 13,
    height: 1.8,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryMuted,
  );

  static const metric = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 22,
    height: 1.05,
    fontWeight: FontWeight.w700,
    color: AppColors.textTitle,
    letterSpacing: -0.4,
  );

  static const overlineOnPrimary = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: AppColors.lightBlue,
  );

  // Stitch explicitly uses Poppins on draft, transaction, data-master,
  // report, profile, and selected diagnosis card values.
  static const poppinsTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textTitle,
  );
  static const poppinsHeading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textTitle,
  );
  static const poppinsBody = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    color: AppColors.textBody,
  );

  static const poppinsDisplay = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textTitle,
  );
}
