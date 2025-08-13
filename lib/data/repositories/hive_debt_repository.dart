import 'package:hive/hive.dart';

import '../../domain/models/debt.dart';
import '../../domain/repositories/debt_repository.dart';

class HiveDebtRepository implements DebtRepository {
  static const String _boxName = 'debts';
  late Box<Debt> _box;

  @override
  Future<void> initialize() async {
    _box = await Hive.openBox<Debt>(_boxName);
  }

  @override
  Future<List<Debt>> getAllDebts() async {
    return _box.values.toList();
  }

  @override
  Future<List<Debt>> getDebtsForMember(String memberId) async {
    return _box.values
        .where((debt) =>
            debt.fromMemberId == memberId || debt.toMemberId == memberId)
        .toList();
  }

  @override
  Future<Debt?> getDebtById(String id) async {
    return _box.get(id);
  }

  @override
  Future<void> addDebt(Debt debt) async {
    await _box.put(debt.id, debt);
  }

  @override
  Future<void> updateDebt(Debt debt) async {
    await _box.put(debt.id, debt);
  }

  @override
  Future<void> deleteDebt(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> markDebtAsPaid(String id) async {
    final debt = await getDebtById(id);
    if (debt != null) {
      final updatedDebt = Debt(
        id: debt.id,
        fromMemberId: debt.fromMemberId,
        toMemberId: debt.toMemberId,
        amount: debt.amount,
        createdAt: debt.createdAt,
        description: debt.description,
        isPaid: true,
      );
      await updateDebt(updatedDebt);
    }
  }
}
