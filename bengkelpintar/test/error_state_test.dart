import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bengkelpintar/core/theme/app_theme.dart';
import 'package:bengkelpintar/core/widgets/error_state.dart';

void main() {
  testWidgets('ErrorState menampilkan Coba lagi dan menjalankan retry', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ErrorState(onRetry: () => retried = true),
      ),
    );

    expect(find.text('Coba lagi'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    expect(retried, isTrue);
  });
}
