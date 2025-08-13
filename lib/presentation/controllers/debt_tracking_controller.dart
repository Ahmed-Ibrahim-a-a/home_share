import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/models/debt.dart';
import '../../domain/models/member.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/member_repository.dart';
import '../../domain/services/export_import_service.dart';
import 'base_controller.dart';

class DebtTrackingController extends BaseController {
  final _debtRepo = Get.find<DebtRepository>();
  final _memberRepo = Get.find<MemberRepository>();

  // Computed values for each member
  final memberBalances = <String, double>{}.obs;
  final memberDebts = <String, List<Debt>>{}.obs;

  @override
  final debts = <Debt>[].obs;
  @override
  final members = <Member>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
    // Listen to changes in debts and members to update computed values
    ever(debts, (_) => updateComputedValues());
    ever(members, (_) => updateComputedValues());
  }

  Future<void> loadData() async {
    await loadMembers();
    await loadDebts();
    updateComputedValues();
  }

  void updateComputedValues() {
    for (final member in members) {
      final totalOwed = getTotalOwed(member.id);
      final totalOwes = getTotalOwes(member.id);
      memberBalances[member.id] = totalOwed - totalOwes;
      memberDebts[member.id] = getDebtsForMember(member.id);
    }
    update(); // Force UI update
  }

  @override
  Future<void> loadMembers() async {
    members.value = await _memberRepo.getAllMembers();
  }

  @override
  Future<void> loadDebts() async {
    debts.value = await _debtRepo.getAllDebts();
  }

  List<Debt> getDebtsForMember(String memberId) {
    return debts
        .where((debt) =>
            (debt.toMemberId == memberId || debt.fromMemberId == memberId) &&
            !debt.isPaid)
        .toList();
  }

  double getTotalOwed(String memberId) {
    return debts
        .where((debt) => debt.toMemberId == memberId && !debt.isPaid)
        .fold(0, (sum, debt) => sum + debt.amount);
  }

  double getTotalOwes(String memberId) {
    return debts
        .where((debt) => debt.fromMemberId == memberId && !debt.isPaid)
        .fold(0, (sum, debt) => sum + debt.amount);
  }

  Future<void> handleMarkDebtAsPaid(Debt debt) async {
    await markDebtAsPaid(debt);
    await loadData(); // Reload all data and update computed values
  }

  String getOtherMemberName(Debt debt, String currentMemberId) {
    final otherId = debt.fromMemberId == currentMemberId
        ? debt.toMemberId
        : debt.fromMemberId;
    return members.firstWhere((m) => m.id == otherId).name;
  }

  bool isDebtor(Debt debt, String memberId) {
    return debt.fromMemberId == memberId;
  }

  @override
  Future<void> markDebtAsPaid(Debt debt) async {
    await _debtRepo.markDebtAsPaid(debt.id);
    await loadData(); // Reload to get updated data
  }

  @override
  Future<void> addMember(String name,
      {String? email, String? phoneNumber}) async {
    final member = Member(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phoneNumber: phoneNumber,
    );
    await _memberRepo.addMember(member);
    await loadData();
  }

  @override
  Future<void> addDebt(
    String fromMemberId,
    String toMemberId,
    double amount,
    String? description,
  ) async {
    final debt = Debt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromMemberId: fromMemberId,
      toMemberId: toMemberId,
      amount: amount,
      createdAt: DateTime.now(),
      description: description,
    );
    await _debtRepo.addDebt(debt);
    await loadData();
  }

  @override
  Future<void> updateDebt(
    String debtId,
    double amount,
    String? description,
  ) async {
    final existingDebt = await _debtRepo.getDebtById(debtId);
    if (existingDebt != null) {
      final updatedDebt = Debt(
        id: existingDebt.id,
        fromMemberId: existingDebt.fromMemberId,
        toMemberId: existingDebt.toMemberId,
        amount: amount,
        createdAt: existingDebt.createdAt,
        description: description,
        isPaid: existingDebt.isPaid,
      );
      await _debtRepo.updateDebt(updatedDebt);
      await loadData();
    }
  }

  Future<void> exportData(bool asJson) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'home_share_export_${DateTime.now().millisecondsSinceEpoch}${asJson ? '.json' : '.csv'}';
      final file = File('${tempDir.path}/$fileName');

      // Generate export data
      final content = asJson
          ? ExportImportService.exportToJson(members, debts)
          : ExportImportService.exportToCsv(members, debts);

      // Write to temporary file
      await file.writeAsString(content);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'HomeShare ${asJson ? 'JSON' : 'CSV'} Export',
      );
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        'Failed to export data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> importData(String content, bool isJson) async {
    try {
      final data = isJson
          ? ExportImportService.importFromJson(content)
          : ExportImportService.importFromCsv(content);

      // Import members first
      for (final member in data.members) {
        await _memberRepo.addMember(member);
      }

      // Then import debts
      for (final debt in data.debts) {
        await _debtRepo.addDebt(debt);
      }

      // Reload data
      await loadData();

      Get.snackbar(
        'Import Successful',
        'Successfully imported ${data.members.length} members and ${data.debts.length} debts',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Import Failed',
        'Failed to import data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
