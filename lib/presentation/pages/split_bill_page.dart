import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/split_bill_controller.dart';

class SplitBillPage extends StatelessWidget {
  const SplitBillPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplitBillController());
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddMemberDialog(context, controller),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Amount Input
            TextField(
              decoration: const InputDecoration(
                labelText: 'Total Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                controller.totalAmount.value = double.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 24),

            // Split Type Selection
            Text(
              'Split Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Obx(() => SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'equal',
                      label: Text('Equal Split'),
                      icon: Icon(Icons.balance),
                    ),
                    ButtonSegment(
                      value: 'custom',
                      label: Text('Custom Split'),
                      icon: Icon(Icons.tune),
                    ),
                  ],
                  selected: {controller.splitType.value},
                  onSelectionChanged: (Set<String> newSelection) {
                    controller.splitType.value = newSelection.first;
                  },
                )),
            const SizedBox(height: 24),

            // Member Selection
            Text(
              'Select Members',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.members.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No members added yet. Add members using the + button above.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Column(
                children: controller.members
                    .map((member) => CheckboxListTile(
                          title: Text(member.name),
                          subtitle: Text(member.email ?? ''),
                          value: controller.selectedMembers.contains(member),
                          onChanged: (_) =>
                              controller.toggleMemberSelection(member),
                        ))
                    .toList(),
              );
            }),

            // Custom Amount Inputs (shown only for custom split)
            Obx(() {
              if (controller.splitType.value == 'custom') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Custom Amounts',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...controller.selectedMembers.map(
                      (member) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: member.name,
                            prefixIcon: const Icon(Icons.person),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            controller.setCustomAmount(
                                member.id, double.tryParse(value) ?? 0);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 32),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await controller.calculateAndSaveSplit();
                  _showResultsDialog(context, controller);
                },
                child: const Text('Calculate Split'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResultsDialog(
      BuildContext context, SplitBillController controller) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Split Results'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Total: ${currencyFormat.format(controller.totalAmount.value)}'),
              const SizedBox(height: 16),
              ...controller.debts.map(
                (debt) => Card(
                  child: ListTile(
                    title: Text(
                      '${controller.members.firstWhere((m) => m.id == debt.fromMemberId).name} owes ${currencyFormat.format(debt.amount)}',
                    ),
                    subtitle: Text(
                      'to ${controller.members.firstWhere((m) => m.id == debt.toMemberId).name}',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Save debts to database
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Debts have been recorded',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(
      BuildContext context, SplitBillController controller) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone (Optional)',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await controller.addMember(
                  name,
                  email: emailController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                );
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
