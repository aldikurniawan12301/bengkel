import 'dart:async';

import 'mock_failure.dart';

Future<void> mockDelay() async {
  await Future<void>.delayed(const Duration(milliseconds: 300));
  MockFailureController.ensureAvailable();
}
