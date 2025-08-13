import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'grocery_item.g.dart';

@HiveType(typeId: 2)
class GroceryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  double pricePerItem;

  @HiveField(4)
  String? note;

  @HiveField(5)
  bool isChecked;

  GroceryItem({
    String? id,
    required this.name,
    required this.quantity,
    required this.pricePerItem,
    this.note,
    this.isChecked = false,
  }) : id = id ?? const Uuid().v4();

  double get totalPrice => quantity * pricePerItem;

  GroceryItem copyWith({
    String? name,
    double? quantity,
    double? pricePerItem,
    String? note,
    bool? isChecked,
  }) {
    return GroceryItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      pricePerItem: pricePerItem ?? this.pricePerItem,
      note: note ?? this.note,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'pricePerItem': pricePerItem,
        'note': note,
        'isChecked': isChecked,
      };

  factory GroceryItem.fromJson(Map<String, dynamic> json) => GroceryItem(
        id: json['id'] as String,
        name: json['name'] as String,
        quantity: json['quantity'] as double,
        pricePerItem: json['pricePerItem'] as double,
        note: json['note'] as String?,
        isChecked: json['isChecked'] as bool? ?? false,
      );
}
