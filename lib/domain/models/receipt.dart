import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'grocery_item.dart';
import 'group_type.dart';

part 'receipt.g.dart';

@HiveType(typeId: 1)
class Receipt {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime purchaseDate;

  @HiveField(2)
  final List<GroceryItem> items;

  @HiveField(3)
  final GroupType groupType;

  @HiveField(4)
  final int numberOfPeople;

  @HiveField(5)
  final String? paidBy;

  @HiveField(6)
  final Map<String, bool> paidUsers;

  @HiveField(7)
  final double? discount;

  @HiveField(8)
  final Map<String, String> userNames;

  Receipt({
    String? id,
    DateTime? purchaseDate,
    required this.items,
    required this.groupType,
    required this.numberOfPeople,
    this.paidBy,
    Map<String, bool>? paidUsers,
    this.discount,
    Map<String, String>? userNames,
  })  : id = id ?? const Uuid().v4(),
        purchaseDate = purchaseDate ?? DateTime.now(),
        paidUsers = paidUsers ?? {},
        userNames = userNames ?? {};

  double get totalCost {
    final itemsTotal = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    return discount != null ? itemsTotal - discount! : itemsTotal;
  }

  double get costPerPerson => totalCost / numberOfPeople;

  Receipt copyWith({
    String? id,
    DateTime? purchaseDate,
    List<GroceryItem>? items,
    GroupType? groupType,
    int? numberOfPeople,
    String? paidBy,
    Map<String, bool>? paidUsers,
    double? discount,
    Map<String, String>? userNames,
  }) {
    return Receipt(
      id: id ?? this.id,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      items: items ?? this.items,
      groupType: groupType ?? this.groupType,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      paidBy: paidBy ?? this.paidBy,
      paidUsers: paidUsers ?? Map.from(this.paidUsers),
      discount: discount ?? this.discount,
      userNames: userNames ?? Map.from(this.userNames),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((item) => item.toJson()).toList(),
        'numberOfPeople': numberOfPeople,
        'groupType': groupType.name,
        'paidBy': paidBy,
        'purchaseDate': purchaseDate.toIso8601String(),
      };

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
        id: json['id'] as String,
        items: (json['items'] as List)
            .map((item) => GroceryItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        numberOfPeople: json['numberOfPeople'] as int,
        groupType:
            GroupType.values.firstWhere((e) => e.name == json['groupType']),
        paidBy: json['paidBy'] as String?,
        purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      );

  // Method to create a duplicate receipt for a new month
  Receipt duplicateForNewMonth({
    required int newNumberOfPeople,
    String? newPaidBy,
  }) {
    return Receipt(
      items: items
          .map((item) => GroceryItem(
                name: item.name,
                quantity: item.quantity,
                pricePerItem: item.pricePerItem,
                note: item.note,
                isChecked: false,
              ))
          .toList(),
      numberOfPeople: newNumberOfPeople,
      groupType: groupType,
      paidBy: newPaidBy,
    );
  }

  String getUserName(int index) {
    final defaultName = 'Person ${index + 1}';
    return userNames['user_$index'] ?? defaultName;
  }

  Receipt updateUserName(int index, String name) {
    final updatedNames = Map<String, String>.from(userNames);
    updatedNames['user_$index'] = name;
    return copyWith(userNames: updatedNames);
  }
}
