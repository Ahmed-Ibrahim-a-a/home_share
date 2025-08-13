import '../models/group_type.dart';
import '../models/receipt.dart';

abstract class ReceiptRepository {
  Future<List<Receipt>> getAllReceipts();
  Future<List<Receipt>> getReceiptsByMonth(DateTime month);
  Future<List<Receipt>> getReceiptsByGroupType(GroupType groupType);
  Future<Receipt?> getReceiptById(String id);
  Future<void> saveReceipt(Receipt receipt);
  Future<void> deleteReceipt(String id);
  Future<Map<String, double>> getMonthlyTotalsByGroup(DateTime month);
}
