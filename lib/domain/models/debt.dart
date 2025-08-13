import 'package:hive/hive.dart';

part 'debt.g.dart';

@HiveType(typeId: 5)
class Debt {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fromMemberId;

  @HiveField(2)
  final String toMemberId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final bool isPaid;

  Debt({
    required this.id,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amount,
    required this.createdAt,
    this.description,
    this.isPaid = false,
  });
}
