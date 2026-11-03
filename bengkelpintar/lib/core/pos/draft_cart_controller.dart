import 'package:flutter/foundation.dart';

import '../../data/models/transaksi.dart';

/// UI-only selection shared by Katalog, pemilih item, and Draft.
/// It deliberately does not replace or modify the transaction service.
class DraftCartController extends ChangeNotifier {
  final Map<String, ItemTransaksiRequest> _items = {};
  final Map<String, int> _prices = {};

  List<ItemTransaksiRequest> get requests => List.unmodifiable(_items.values);

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.jumlah);

  int quantity(String type, int id) => _items['$type:$id']?.jumlah ?? 0;

  int price(String type, int id) => _prices['$type:$id'] ?? 0;

  void add(String type, int id, {int amount = 1, int? price}) {
    final key = '$type:$id';
    final current = _items[key];
    _items[key] = ItemTransaksiRequest(
      tipe: type,
      id: id,
      jumlah: (current?.jumlah ?? 0) + amount,
    );
    if (price != null) _prices[key] = price;
    notifyListeners();
  }

  void setQuantity(String type, int id, int quantity) {
    final key = '$type:$id';
    if (quantity < 1) {
      _items.remove(key);
    } else {
      _items[key] = ItemTransaksiRequest(tipe: type, id: id, jumlah: quantity);
    }
    notifyListeners();
  }

  void remove(String type, int id) {
    _items.remove('$type:$id');
    notifyListeners();
  }

  void replace(Iterable<ItemTransaksiRequest> requests) {
    _items
      ..clear()
      ..addEntries(
        requests.map((item) => MapEntry('${item.tipe}:${item.id}', item)),
      );
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    _prices.clear();
    notifyListeners();
  }
}
