import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/models/debt.dart';
import '../../domain/models/member.dart';
import '../controllers/debt_tracking_controller.dart';

class DebtTrackingPage extends StatelessWidget {
  const DebtTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DebtTrackingController());
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            tooltip: 'Import/Export Data',
            onPressed: () => _showImportExportMenu(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Member',
            onPressed: () => _showAddMemberDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No members added yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _showAddMemberDialog(context, controller),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Member'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.members.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final member = controller.members[index];
            final balance = controller.memberBalances[member.id] ?? 0;
            final debts = controller.memberDebts[member.id] ?? [];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Member header with balance
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                balance >= 0
                                    ? 'Is owed: ${currencyFormat.format(balance)}'
                                    : 'Owes: ${currencyFormat.format(-balance)}',
                                style: TextStyle(
                                  color:
                                      balance >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteMemberDialog(
                            context,
                            controller,
                            member,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Debts list
                  if (debts.isNotEmpty) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Debts',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          ...debts.map((debt) {
                            final isDebtor = controller.isDebtor(
                              debt,
                              member.id,
                            );
                            final otherName = controller.getOtherMemberName(
                              debt,
                              member.id,
                            );

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  isDebtor
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: isDebtor ? Colors.red : Colors.green,
                                ),
                                title: Text(
                                  isDebtor
                                      ? 'Owes ${currencyFormat.format(debt.amount)} to $otherName'
                                      : '$otherName owes ${currencyFormat.format(debt.amount)}',
                                ),
                                subtitle: Text(
                                  debt.description ??
                                      'Added on ${DateFormat.yMMMd().format(debt.createdAt)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _showEditDebtDialog(
                                        context,
                                        controller,
                                        debt,
                                      ),
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                      ),
                                      label: const Text('Paid'),
                                      onPressed: () =>
                                          controller.handleMarkDebtAsPaid(
                                        debt,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'split_bill',
            onPressed: () => Get.toNamed('/split-bill'),
            icon: const Icon(Icons.calculate),
            label: const Text('Split Bill'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'add_debt',
            onPressed: () => _showAddDebtDialog(context, controller),
            icon: const Icon(Icons.add),
            label: const Text('Add Debt'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(
    BuildContext context,
    DebtTrackingController controller,
  ) {
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

  void _showAddDebtDialog(
    BuildContext context,
    DebtTrackingController controller,
  ) {
    Member? fromMember;
    Member? toMember;
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Debt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Member>(
              decoration: const InputDecoration(
                labelText: 'From (Who owes)',
                prefixIcon: Icon(Icons.person_outline),
              ),
              items: controller.members
                  .map(
                    (member) => DropdownMenuItem(
                      value: member,
                      child: Text(member.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => fromMember = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Member>(
              decoration: const InputDecoration(
                labelText: 'To (Who is owed)',
                prefixIcon: Icon(Icons.person),
              ),
              items: controller.members
                  .map(
                    (member) => DropdownMenuItem(
                      value: member,
                      child: Text(member.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => toMember = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
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
              if (fromMember != null &&
                  toMember != null &&
                  amountController.text.isNotEmpty) {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 0) {
                  await controller.addDebt(
                    fromMember!.id,
                    toMember!.id,
                    amount,
                    descriptionController.text.trim(),
                  );
                  Get.back();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDebtDialog(
    BuildContext context,
    DebtTrackingController controller,
    Debt debt,
  ) {
    final amountController = TextEditingController(
      text: debt.amount.toString(),
    );
    final descriptionController = TextEditingController(
      text: debt.description ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Debt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'From: ${controller.members.firstWhere((m) => m.id == debt.fromMemberId).name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'To: ${controller.members.firstWhere((m) => m.id == debt.toMemberId).name}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
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
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                await controller.updateDebt(
                  debt.id,
                  amount,
                  descriptionController.text.trim(),
                );
                Get.back();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteMemberDialog(
    BuildContext context,
    DebtTrackingController controller,
    Member member,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text(
          'Are you sure you want to delete ${member.name}? This will also delete all associated debts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await controller.deleteMember(member.id);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showImportDialog(
    BuildContext context,
    DebtTrackingController controller,
  ) async {
    var isJson = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Import Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select a JSON or CSV file to import:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Format: '),
                  ChoiceChip(
                    label: const Text('JSON'),
                    selected: isJson,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => isJson = true);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('CSV'),
                    selected: !isJson,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => isJson = false);
                      }
                    },
                  ),
                ],
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
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: [if (isJson) 'json' else 'csv'],
                );

                if (result != null) {
                  final file = File(result.files.single.path!);
                  final content = await file.readAsString();

                  try {
                    // Validate the format first
                    if (isJson) {
                      // Try parsing JSON to validate
                      jsonDecode(content);
                    } else {
                      // Try parsing first line of CSV to validate
                      const CsvToListConverter().convert(content);
                    }

                    Get.back();
                    await controller.importData(content, isJson);
                    Get.snackbar(
                      'Success',
                      'Data imported successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.withOpacity(0.1),
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Import Failed',
                      'Invalid ${isJson ? 'JSON' : 'CSV'} format. Please check your file and try again.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.1),
                    );
                  }
                }
              },
              child: const Text('Choose File'),
            ),
          ],
        ),
      ),
    );
  }

  void _showImportExportMenu(
    BuildContext context,
    DebtTrackingController controller,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Export Options'),
              subtitle: Text('Save or share your data'),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Export as CSV'),
              subtitle: const Text('Best for spreadsheet software'),
              onTap: () {
                Get.back();
                controller.exportData(false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Export as JSON'),
              subtitle: const Text('Best for data backup'),
              onTap: () {
                Get.back();
                controller.exportData(true);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Import Data'),
              subtitle: const Text('Import from CSV or JSON file'),
              onTap: () {
                Get.back();
                _showImportDialog(context, controller);
              },
            ),
          ],
        ),
      ),
    );
  }
}
