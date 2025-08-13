import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/grocery_item.dart';
import '../../domain/models/receipt.dart';
import '../../domain/repositories/receipt_repository.dart';

class PreviousItemsDialog extends StatefulWidget {
  const PreviousItemsDialog({super.key});

  @override
  State<PreviousItemsDialog> createState() => _PreviousItemsDialogState();
}

class _PreviousItemsDialogState extends State<PreviousItemsDialog> {
  final _repository = Get.find<ReceiptRepository>();
  List<Receipt> _receipts = [];
  final Map<String, bool> _selectedItems = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }

  Future<void> _loadReceipts() async {
    try {
      final receipts = await _repository.getAllReceipts();
      setState(() {
        _receipts = receipts;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load previous receipts',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Items from Previous Receipts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _receipts.length,
                itemBuilder: (context, index) {
                  final receipt = _receipts[index];
                  return ExpansionTile(
                    title: Text(
                      '${receipt.groupType.displayName} - ${receipt.items.length} items',
                    ),
                    subtitle: Text(
                      'Total: \$${receipt.totalCost.toStringAsFixed(2)}',
                    ),
                    children: receipt.items.map((item) {
                      final itemKey = '${item.id}_${receipt.id}';
                      return CheckboxListTile(
                        value: _selectedItems[itemKey] ?? false,
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.quantity}x @ \$${item.pricePerItem.toStringAsFixed(2)}',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedItems[itemKey] = value ?? false;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final selectedItems = <GroceryItem>[];
                    for (final receipt in _receipts) {
                      for (final item in receipt.items) {
                        final itemKey = '${item.id}_${receipt.id}';
                        if (_selectedItems[itemKey] == true) {
                          selectedItems.add(GroceryItem(
                            name: item.name,
                            quantity: item.quantity,
                            pricePerItem: item.pricePerItem,
                            note: item.note,
                          ));
                        }
                      }
                    }
                    Get.back(result: selectedItems);
                  },
                  child: const Text('Add Selected'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
