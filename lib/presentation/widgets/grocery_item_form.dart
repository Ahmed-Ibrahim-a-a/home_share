import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/grocery_item.dart';
import 'package:uuid/uuid.dart';

class GroceryItemForm extends StatefulWidget {
  final GroceryItem? item;
  final Function(GroceryItem) onSave;

  const GroceryItemForm({
    super.key,
    this.item,
    required this.onSave,
  });

  @override
  State<GroceryItemForm> createState() => _GroceryItemFormState();
}

class _GroceryItemFormState extends State<GroceryItemForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString() ?? '1',
    );
    _priceController = TextEditingController(
      text: widget.item?.pricePerItem.toString() ?? '',
    );
    _noteController = TextEditingController(text: widget.item?.note ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      return;
    }

    final item = GroceryItem(
      id: widget.item?.id ?? const Uuid().v4(),
      name: _nameController.text,
      quantity: double.tryParse(_quantityController.text) ?? 1,
      pricePerItem: double.tryParse(_priceController.text) ?? 0,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isChecked: widget.item?.isChecked ?? false,
    );

    widget.onSave(item);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Item Name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price per Item',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _handleSave,
            child: Text(widget.item == null ? 'Add Item' : 'Update Item'),
          ),
        ],
      ),
    );
  }
} 