import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/models/receipt.dart';
import '../controllers/home_controller.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports & Analysis',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Monthly Spending Card
              _buildSectionCard(
                context,
                title: 'Monthly Spending',
                child: Obx(() {
                  final totals = controller.monthlyTotals;
                  if (totals.isEmpty) {
                    return const Center(
                      child: Text('No spending data available'),
                    );
                  }

                  double total = 0;
                  for (final value in totals.values) {
                    total += value;
                  }

                  return Column(
                    children: [
                      Text(
                        currencyFormat.format(total),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      ...totals.entries.map((entry) {
                        final percentage = (entry.value / total * 100).round();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text(currencyFormat.format(entry.value)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: entry.value / total,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                              ),
                              Text(
                                '$percentage%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Per Person Analysis
              _buildSectionCard(
                context,
                title: 'Per Person Analysis',
                child: Obx(() {
                  final receipts = controller.receipts;
                  if (receipts.isEmpty) {
                    return const Center(
                      child: Text('No data available'),
                    );
                  }

                  final perPersonTotal = receipts.fold<double>(
                    0,
                    (sum, receipt) => sum + receipt.costPerPerson,
                  );

                  return Column(
                    children: [
                      Text(
                        'Average per person',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(perPersonTotal / receipts.length),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Actions
              _buildSectionCard(
                context,
                title: 'Actions',
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.file_download),
                      title: const Text('Export Expense Report'),
                      onTap: () => _exportReport(controller.receipts),
                    ),
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Manage Categories'),
                      onTap: () {
                        // TODO: Implement category management
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('Manage Group Members'),
                      onTap: () {
                        // TODO: Implement group management
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }

  Future<void> _exportReport(List<Receipt> receipts) async {
    // TODO: Implement report export
    Get.snackbar(
      'Coming Soon',
      'Report export functionality will be available soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
