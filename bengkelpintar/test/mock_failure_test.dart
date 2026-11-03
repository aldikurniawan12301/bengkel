import 'package:flutter_test/flutter_test.dart';

import 'package:bengkelpintar/services/mock_failure.dart';
import 'package:bengkelpintar/services/mock_services.dart';
import 'package:bengkelpintar/services/mock_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'failure global membuat service gagal lalu pulih setelah dimatikan',
    () async {
      final store = await MockStore.load();
      final admin = store.users.firstWhere((user) => user.peran == 'admin');
      final failure = MockFailureController();
      MockFailureController.global = failure;
      final service = MockProdukService(store, () => admin);

      try {
        failure.setEnabled(true);
        await expectLater(
          service.listProducts(),
          throwsA(isA<MockServerUnavailableException>()),
        );

        failure.setEnabled(false);
        expect((await service.listProducts()).isNotEmpty, isTrue);
      } finally {
        MockFailureController.global = null;
      }
    },
  );
}
