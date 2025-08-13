import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/models/receipt.dart';
import '../controllers/home_controller.dart';
import 'debt_tracking_page.dart';
import 'new_receipt_page.dart';
import 'receipt_details_page.dart';
import 'reports_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    final currentIndex = 0.obs;

    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) => currentIndex.value = index,
        children: [
          _ExpensesPage(),
          const ReportsPage(),
          const DebtTrackingPage(),
        ],
      ),
      bottomNavigationBar: Obx(() => NavigationBar(
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.receipt_outlined),
                selectedIcon: Icon(Icons.receipt),
                label: 'Expenses',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_outlined),
                selectedIcon: Icon(Icons.account_balance),
                label: 'Debts',
              ),
            ],
            selectedIndex: currentIndex.value,
            onDestinationSelected: (index) {
              currentIndex.value = index;
              pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          )),
    );
  }
}

class _ExpensesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  final date = controller.selectedMonth.value;
                  return DropdownButton<DateTime>(
                    value: date,
                    items: [
                      for (var i = 0; i < 12; i++)
                        DropdownMenuItem(
                          value: DateTime(
                            date.year,
                            date.month - i,
                            1,
                          ),
                          child: Text(
                            DateFormat.yMMMM().format(
                              DateTime(date.year, date.month - i),
                            ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.setSelectedMonth(
                          DateTime(value.year, value.month, 1),
                        );
                      }
                    },
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down),
                  );
                }),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        // TODO: Implement notifications
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => Get.to(() => const NewReceiptPage()),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Monthly Summary
          Obx(() {
            final totals = controller.monthlyTotals;
            if (totals.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...totals.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text(
                            currencyFormat.format(entry.value),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Receipts List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Recent Expenses',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final receipts = controller.receipts;
              if (receipts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No expenses yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: receipts.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final receipt = receipts[index];
                  return ReceiptCard(
                    receipt: receipt,
                    onTap: () =>
                        Get.to(() => ReceiptDetailsPage(receipt: receipt)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;

  const ReceiptCard({
    super.key,
    required this.receipt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.MMMd();

    return Dismissible(
      key: Key(receipt.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Receipt'),
          content: const Text('Are you sure you want to delete this receipt?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        final controller = Get.find<HomeController>();
        controller.deleteReceipt(receipt.id);
      },
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receipt.groupType.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${receipt.items.length} items • ${dateFormat.format(receipt.purchaseDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(receipt.totalCost),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'pp: ${currencyFormat.format(receipt.costPerPerson)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
