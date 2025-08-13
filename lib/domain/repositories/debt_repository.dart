import '../models/debt.dart';

abstract class DebtRepository {
  Future<void> initialize();
  Future<List<Debt>> getAllDebts();
  Future<List<Debt>> getDebtsForMember(String memberId);
  Future<Debt?> getDebtById(String id);
  Future<void> addDebt(Debt debt);
  Future<void> updateDebt(Debt debt);
  Future<void> deleteDebt(String id);
  Future<void> markDebtAsPaid(String id);
}
