import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/grocery_item.dart';
import '../../domain/models/group_type.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../controllers/active_receipt_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/grocery_item_form.dart';
import '../widgets/previous_items_dialog.dart';

class NewReceiptPage extends StatelessWidget {
  const NewReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActiveReceiptController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'New Expense',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                final receipt = controller.activeReceipt;
                if (receipt == null) {
                  return Center(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showGroupSetupDialog(context, controller),
                      icon: const Icon(Icons.add),
                      label: const Text('Start New Receipt'),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Group Info Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                receipt.groupType.displayName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${receipt.numberOfPeople} people',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Text(
                            'Per person: \$${receipt.costPerPerson.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),

                    // Items List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                _showPreviousItemsDialog(context, controller),
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Items'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.items.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final item = controller.items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              leading: Checkbox(
                                value: item.isChecked,
                                onChanged: (value) =>
                                    controller.toggleItemCheck(item.id),
                              ),
                              title: Text(item.name),
                              subtitle: Text(
                                '${item.quantity}x @ \$${item.pricePerItem.toStringAsFixed(2)}',
                              ),
                              trailing: Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () => _showEditItemDialog(
                                  context, controller, item),
                            ),
                          );
                        },
                      ),
                    ),

                    // Total and Save
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '\$${receipt.totalCost.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _saveReceipt(controller),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                              child: const Text('Save Receipt'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.activeReceipt == null) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => _showAddItemDialog(context, controller),
          child: const Icon(Icons.add),
        );
      }),
    );
  }

  Future<void> _showGroupSetupDialog(
    BuildContext context,
    ActiveReceiptController controller,
  ) async {
    int numberOfPeople = 2;
    GroupType selectedType = GroupType.groceries;
    String? paidBy;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Group Setup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<GroupType>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Group Type',
                border: OutlineInputBorder(),
              ),
              items: GroupType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) selectedType = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Number of People',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              initialValue: '2',
              onChanged: (value) {
                numberOfPeople = int.tryParse(value) ?? 2;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Paid By (Optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                paidBy = value.isEmpty ? null : value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.startNewReceipt(
                numberOfPeople: numberOfPeople,
                groupType: selectedType,
                paidBy: paidBy,
              );
              Get.back();
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddItemDialog(
    BuildContext context,
    ActiveReceiptController controller,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GroceryItemForm(
          onSave: (item) {
            controller.addItem(item);
            Get.back();
          },
        ),
      ),
    );
  }

  Future<void> _showEditItemDialog(
    BuildContext context,
    ActiveReceiptController controller,
    GroceryItem item,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GroceryItemForm(
          item: item,
          onSave: (updatedItem) {
            controller.updateItem(updatedItem);
            Get.back();
          },
        ),
      ),
    );
  }

  Future<void> _saveReceipt(ActiveReceiptController controller) async {
    try {
      final receipt = controller.activeReceipt;
      if (receipt == null) return;

      final repository = Get.find<ReceiptRepository>();
      await repository.saveReceipt(receipt);

      // Refresh the home controller
      final homeController = Get.find<HomeController>();
      await homeController.loadMonthData();

      Get.back();
      Get.snackbar(
        'Success',
        'Receipt saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save receipt: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _showPreviousItemsDialog(
    BuildContext context,
    ActiveReceiptController controller,
  ) async {
    final selectedItems = await showDialog<List<GroceryItem>>(
      context: context,
      builder: (context) => const PreviousItemsDialog(),
    );

    if (selectedItems != null && selectedItems.isNotEmpty) {
      for (final item in selectedItems) {
        controller.addItem(item);
      }
      Get.snackbar(
        'Success',
        'Added ${selectedItems.length} items to receipt',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
