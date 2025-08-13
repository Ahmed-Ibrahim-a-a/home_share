import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/models/receipt.dart';
import '../controllers/home_controller.dart';

class ReceiptDetailsPage extends StatelessWidget {
  final Receipt receipt;
  final _receiptRx = Rx<Receipt?>(null);

  ReceiptDetailsPage({
    super.key,
    required this.receipt,
  }) {
    _receiptRx.value = receipt;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MM/dd/yyyy hh:mm a');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Obx(() {
              final currentReceipt = _receiptRx.value!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Receipt Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Items Table
                            DataTable(
                              columnSpacing: 16,
                              columns: const [
                                DataColumn(label: Text('name')),
                                DataColumn(
                                  label: Text('count'),
                                  numeric: true,
                                ),
                                DataColumn(
                                  label: Text('price'),
                                  numeric: true,
                                ),
                              ],
                              rows: currentReceipt.items.map((item) {
                                return DataRow(cells: [
                                  DataCell(Text(item.name)),
                                  DataCell(Text(item.quantity.toString())),
                                  DataCell(Text(
                                      currencyFormat.format(item.totalPrice))),
                                ]);
                              }).toList(),
                            ),

                            // Discount and Total
                            if (currentReceipt.discount != null) ...[
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Discount'),
                                  Text(
                                    '-${currencyFormat.format(currentReceipt.discount)}',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                            ],
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  currencyFormat
                                      .format(currentReceipt.totalCost),
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),

                            // Receipt Info
                            const Divider(height: 32),
                            Text(
                              'Order No: #${currentReceipt.id.substring(0, 13)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'On Date: ${dateFormat.format(currentReceipt.purchaseDate)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),

                            // Social Links
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('feedback'),
                                const SizedBox(width: 8),
                                _SocialButton(
                                  icon: Icons.telegram,
                                  color: Colors.blue,
                                  onTap: () => _shareReceipt('telegram'),
                                ),
                                _SocialButton(
                                  icon: Icons.chat,
                                  color: Colors.green,
                                  onTap: () => _shareReceipt('whatsapp'),
                                ),
                                _SocialButton(
                                  icon: Icons.messenger,
                                  color: Colors.blue,
                                  onTap: () => _shareReceipt('messenger'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Paid Users Section
                    const SizedBox(height: 24),
                    Text(
                      'Paid Users',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          for (int i = 0;
                              i < currentReceipt.numberOfPeople;
                              i++)
                            _PaidUserTile(
                              name: currentReceipt.getUserName(i),
                              isPaid:
                                  currentReceipt.paidUsers['Person ${i + 1}'] ??
                                      false,
                              onToggle: (value) => _togglePaidStatus(i, value),
                              onNameEdit: () => _showNameEditDialog(context, i),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Back Button
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton.small(
                onPressed: () => Get.back(),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePaidStatus(int index, bool isPaid) async {
    final controller = Get.find<HomeController>();
    final currentReceipt = _receiptRx.value!;
    final updatedPaidUsers = Map<String, bool>.from(currentReceipt.paidUsers);
    updatedPaidUsers['Person ${index + 1}'] = isPaid;

    final updatedReceipt = currentReceipt.copyWith(paidUsers: updatedPaidUsers);
    await controller.updateReceipt(updatedReceipt);
    _receiptRx.value = updatedReceipt;
  }

  Future<void> _showNameEditDialog(BuildContext context, int index) async {
    final currentReceipt = _receiptRx.value!;
    final currentName = currentReceipt.getUserName(index);
    String newName = currentName;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: TextEditingController(text: currentName),
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => newName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true && newName.isNotEmpty) {
      final controller = Get.find<HomeController>();
      final updatedReceipt = currentReceipt.updateUserName(index, newName);
      await controller.updateReceipt(updatedReceipt);
      _receiptRx.value = updatedReceipt;
    }
  }

  Future<void> _shareReceipt(String platform) async {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MM/dd/yyyy hh:mm a');
    final currentReceipt = _receiptRx.value!;

    final itemsList = currentReceipt.items.map((item) {
      return '${item.name}: ${item.quantity}x @ ${currencyFormat.format(item.pricePerItem)}';
    }).join('\n');

    final message = '''
🧾 Receipt Details
${currentReceipt.groupType.displayName} - ${currentReceipt.numberOfPeople} people

Items:
$itemsList

${currentReceipt.discount != null ? 'Discount: -${currencyFormat.format(currentReceipt.discount)}\n' : ''}
Total: ${currencyFormat.format(currentReceipt.totalCost)}
Per Person: ${currencyFormat.format(currentReceipt.costPerPerson)}

Order #${currentReceipt.id.substring(0, 13)}
Date: ${dateFormat.format(currentReceipt.purchaseDate)}
''';

    await Share.share(message, subject: 'Receipt Details');
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: color,
      onPressed: onTap,
    );
  }
}

class _PaidUserTile extends StatelessWidget {
  final String name;
  final bool isPaid;
  final ValueChanged<bool> onToggle;
  final VoidCallback onNameEdit;

  const _PaidUserTile({
    required this.name,
    required this.isPaid,
    required this.onToggle,
    required this.onNameEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      trailing: Switch(
        value: isPaid,
        onChanged: onToggle,
      ),
      onTap: onNameEdit,
    );
  }
}
