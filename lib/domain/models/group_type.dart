import 'package:hive/hive.dart';

part 'group_type.g.dart';

@HiveType(typeId: 3)
enum GroupType {
  @HiveField(0)
  groceries,
  @HiveField(1)
  utilities,
  @HiveField(2)
  rent,
  @HiveField(3)
  other;

  String get displayName {
    switch (this) {
      case GroupType.groceries:
        return 'Groceries';
      case GroupType.utilities:
        return 'Utilities';
      case GroupType.rent:
        return 'Rent';
      case GroupType.other:
        return 'Other';
    }
  }
}
