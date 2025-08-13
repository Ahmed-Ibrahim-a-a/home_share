import 'package:get/get.dart';

import '../../domain/models/grocery_item.dart';
import '../../domain/models/group_type.dart';
import '../../domain/models/receipt.dart';

class ActiveReceiptController extends GetxController {
  final Rx<Receipt?> _activeReceipt = Rx<Receipt?>(null);
  Receipt? get activeReceipt => _activeReceipt.value;

  // Observable list of items for real-time updates
  final RxList<GroceryItem> _items = <GroceryItem>[].obs;
  List<GroceryItem> get items => _items;

  void startNewReceipt({
    required int numberOfPeople,
    required GroupType groupType,
    String? paidBy,
  }) {
    _activeReceipt.value = Receipt(
      items: [],
      numberOfPeople: numberOfPeople,
      groupType: groupType,
      paidBy: paidBy,
    );
    _items.clear();
  }

  void addItem(GroceryItem item) {
    _items.add(item);
    _updateReceipt();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _updateReceipt();
  }

  void updateItem(GroceryItem updatedItem) {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      _updateReceipt();
    }
  }

  void toggleItemCheck(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _items[index];
      _items[index] = item.copyWith(isChecked: !item.isChecked);
      _updateReceipt();
    }
  }

  void _updateReceipt() {
    if (_activeReceipt.value != null) {
      _activeReceipt.value = _activeReceipt.value!.copyWith(
        items: _items.toList(),
      );
    }
  }

  void clearActiveReceipt() {
    _activeReceipt.value = null;
    _items.clear();
  }
}
