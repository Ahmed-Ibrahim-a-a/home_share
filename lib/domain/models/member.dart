import 'package:hive/hive.dart';

part 'member.g.dart';

@HiveType(typeId: 4)
class Member {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? phoneNumber;

  Member({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
  });
}
