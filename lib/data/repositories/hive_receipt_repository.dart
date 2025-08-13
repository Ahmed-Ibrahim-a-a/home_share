import 'package:hive/hive.dart';

import '../../domain/models/group_type.dart';
import '../../domain/models/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';

class HiveReceiptRepository implements ReceiptRepository {
  Box<Receipt>? _receiptsBox;

  Future<void> initialize() async {
    _receiptsBox = await Hive.openBox<Receipt>('receipts');
  }

  @override
  Future<List<Receipt>> getAllReceipts() async {
    final box = _receiptsBox;
    if (box == null || !box.isOpen) {
      await initialize();
    }
    return _receiptsBox?.values.toList() ?? [];
  }

  @override
  Future<List<Receipt>> getReceiptsByMonth(DateTime month) async {
    final box = _receiptsBox;
    if (box == null || !box.isOpen) {
      await initialize();
    }

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    return _receiptsBox?.values.where((receipt) {
          return receipt.purchaseDate
                  .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              receipt.purchaseDate
                  .isBefore(endOfMonth.add(const Duration(days: 1)));
        }).toList() ??
        [];
  }

  @override
  Future<List<Receipt>> getReceiptsByGroupType(GroupType groupType) async {
    await _ensureInitialized();
    return _receiptsBox?.values
            .where((receipt) => receipt.groupType == groupType)
            .toList() ??
        [];
  }

  @override
  Future<Receipt?> getReceiptById(String id) async {
    await _ensureInitialized();
    try {
      return _receiptsBox?.values.firstWhere((receipt) => receipt.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveReceipt(Receipt receipt) async {
    final box = _receiptsBox;
    if (box == null || !box.isOpen) {
      await initialize();
    }
    await _receiptsBox?.put(receipt.id, receipt);
  }

  @override
  Future<void> deleteReceipt(String id) async {
    final box = _receiptsBox;
    if (box == null || !box.isOpen) {
      await initialize();
    }
    await _receiptsBox?.delete(id);
  }

  @override
  Future<Map<String, double>> getMonthlyTotalsByGroup(DateTime month) async {
    final receipts = await getReceiptsByMonth(month);
    final totals = <String, double>{};

    for (final receipt in receipts) {
      final groupName = receipt.groupType.displayName;
      totals[groupName] = (totals[groupName] ?? 0) + receipt.totalCost;
    }

    return totals;
  }

  Future<void> _ensureInitialized() async {
    if (!Hive.isBoxOpen('receipts')) {
      _receiptsBox = await Hive.openBox<Receipt>('receipts');
    }
  }
}
