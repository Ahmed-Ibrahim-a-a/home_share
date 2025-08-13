import 'package:get/get.dart';

import '../../domain/models/debt.dart';
import '../../domain/models/member.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/member_repository.dart';

class BaseController extends GetxController {
  final _debtRepo = Get.find<DebtRepository>();
  final _memberRepo = Get.find<MemberRepository>();

  final members = <Member>[].obs;
  final debts = <Debt>[].obs;

  Future<void> loadMembers() async {
    members.value = await _memberRepo.getAllMembers();
  }

  Future<void> loadDebts() async {
    debts.value = await _debtRepo.getAllDebts();
  }

  Future<void> addMember(String name,
      {String? email, String? phoneNumber}) async {
    final member = Member(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      phoneNumber: phoneNumber,
    );
    await _memberRepo.addMember(member);
    await loadMembers();
  }

  Future<void> addDebt(String fromMemberId, String toMemberId, double amount,
      String? description) async {
    final debt = Debt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromMemberId: fromMemberId,
      toMemberId: toMemberId,
      amount: amount,
      createdAt: DateTime.now(),
      description: description,
    );
    await _debtRepo.addDebt(debt);
    await loadDebts();
  }

  Future<void> updateDebt(
      String debtId, double amount, String? description) async {
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
      await loadDebts();
    }
  }

  Future<void> markDebtAsPaid(Debt debt) async {
    await _debtRepo.markDebtAsPaid(debt.id);
    await loadDebts();
  }

  Future<void> deleteMember(String memberId) async {
    // Delete all debts associated with this member
    final memberDebts = debts
        .where(
          (debt) =>
              debt.fromMemberId == memberId || debt.toMemberId == memberId,
        )
        .toList();

    for (final debt in memberDebts) {
      await _debtRepo.deleteDebt(debt.id);
    }

    // Delete the member
    await _memberRepo.deleteMember(memberId);

    // Reload data to update the UI
    await loadMembers();
    await loadDebts();
  }
}
