import 'package:get/get.dart';

import '../../domain/models/debt.dart';
import '../../domain/models/member.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../domain/repositories/member_repository.dart';

class SplitBillController extends GetxController {
  final _debtRepo = Get.find<DebtRepository>();
  final _memberRepo = Get.find<MemberRepository>();

  final members = <Member>[].obs;
  final debts = <Debt>[].obs;
  final totalAmount = 0.0.obs;
  final selectedMembers = <Member>[].obs;
  final customAmounts = <String, double>{}.obs;
  final splitType = 'equal'.obs;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  Future<void> loadMembers() async {
    members.value = await _memberRepo.getAllMembers();
  }

  void toggleMemberSelection(Member member) {
    if (selectedMembers.contains(member)) {
      selectedMembers.remove(member);
    } else {
      selectedMembers.add(member);
    }
  }

  void setCustomAmount(String memberId, double amount) {
    customAmounts[memberId] = amount;
  }

  Future<void> calculateAndSaveSplit() async {
    if (selectedMembers.isEmpty) return;

    final perPersonAmount = totalAmount.value / selectedMembers.length;
    final now = DateTime.now();
    final payer = selectedMembers[0]; // First selected member is the payer

    // Clear previous calculations
    debts.clear();

    if (splitType.value == 'equal') {
      // Equal split
      for (var member in selectedMembers) {
        if (member.id != payer.id) {
          final debt = Debt(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fromMemberId: member.id,
            toMemberId: payer.id,
            amount: perPersonAmount,
            createdAt: now,
            description: 'Equal split',
          );
          debts.add(debt);
          await _debtRepo.addDebt(debt);
        }
      }
    } else {
      // Custom split
      for (var member in selectedMembers) {
        final customAmount = customAmounts[member.id] ?? 0;
        if (customAmount > 0 && member.id != payer.id) {
          final debt = Debt(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fromMemberId: member.id,
            toMemberId: payer.id,
            amount: customAmount,
            createdAt: now,
            description: 'Custom split',
          );
          debts.add(debt);
          await _debtRepo.addDebt(debt);
        }
      }
    }
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
}
