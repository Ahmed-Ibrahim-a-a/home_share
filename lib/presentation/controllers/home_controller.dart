import 'package:get/get.dart';

import '../../domain/models/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';

class HomeController extends GetxController {
  final ReceiptRepository _repository = Get.find<ReceiptRepository>();
  final RxList<Receipt> receipts = <Receipt>[].obs;
  final RxMap<String, double> monthlyTotals = <String, double>{}.obs;
  final Rx<DateTime> selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    ever(selectedMonth, (_) => loadMonthData());
    loadMonthData();
  }

  Future<void> loadMonthData() async {
    try {
      final monthReceipts =
          await _repository.getReceiptsByMonth(selectedMonth.value);
      receipts.assignAll(monthReceipts);

      final totals =
          await _repository.getMonthlyTotalsByGroup(selectedMonth.value);
      monthlyTotals.assignAll(totals);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load receipts: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void setSelectedMonth(DateTime month) {
    selectedMonth.value = DateTime(month.year, month.month, 1);
  }

  Future<void> deleteReceipt(String id) async {
    try {
      await _repository.deleteReceipt(id);
      await loadMonthData();
      Get.snackbar(
        'Success',
        'Receipt deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete receipt: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateReceipt(Receipt receipt) async {
    try {
      await _repository.saveReceipt(receipt);
      await loadMonthData();
      Get.snackbar(
        'Success',
        'Receipt updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update receipt: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
