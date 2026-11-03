import 'package:flutter/foundation.dart';

import '../../data/models/transaksi.dart';

/// UI-only selection shared by Katalog, pemilih item, and Draft.
/// It deliberately does not replace or modify the transaction service.
class DraftCartController extends ChangeNotifier {
  final Map<String, ItemTransaksiRequest> _items = {};
  final Map<String, int> _prices = {};
  final Map<String, int> _limits = {};
  String customerName = '';
  String plateNumber = '';
  int? diagnosisId;

  void setCustomer({required String name, required String plate}) {
    customerName = name;
    plateNumber = plate;
    notifyListeners();
  }

  void setItemPrice(String type, int id, int price) {
    _prices['$type:$id'] = price;
  }

  List<ItemTransaksiRequest> get requests => List.unmodifiable(_items.values);

  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.jumlah);

  int quantity(String type, int id) => _items['$type:$id']?.jumlah ?? 0;

  int price(String type, int id) => _prices['$type:$id'] ?? 0;

  void setLimit(String type, int id, int limit) {
    _limits['$type:$id'] = limit;
    final current = quantity(type, id);
    if (current > limit) setQuantity(type, id, limit);
  }

  void add(String type, int id, {int amount = 1, int? price, int? limit}) {
    final key = '$type:$id';
    if (limit != null) _limits[key] = limit;
    final maximum = _limits[key];
    final next = (quantity(type, id) + amount).clamp(0, maximum ?? 1 << 30);
    if (next == 0) return;
    _items[key] = ItemTransaksiRequest(tipe: type, id: id, jumlah: next);
    if (price != null) _prices[key] = price;
    notifyListeners();
  }

  void setQuantity(String type, int id, int quantity) {
    final key = '$type:$id';
    final maximum = _limits[key];
    final next = quantity.clamp(0, maximum ?? 1 << 30);
    if (next < 1) {
      _items.remove(key);
    } else {
      _items[key] = ItemTransaksiRequest(tipe: type, id: id, jumlah: next);
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
    if (_items.isEmpty && customerName.isEmpty && plateNumber.isEmpty) return;
    _items.clear();
    _prices.clear();
    _limits.clear();
    customerName = '';
    plateNumber = '';
    notifyListeners();
  }
}
