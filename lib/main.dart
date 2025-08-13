import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/repositories/hive_debt_repository.dart';
import 'data/repositories/hive_member_repository.dart';
import 'data/repositories/hive_receipt_repository.dart';
import 'domain/models/debt.dart';
import 'domain/models/grocery_item.dart';
import 'domain/models/group_type.dart';
import 'domain/models/member.dart';
import 'domain/models/receipt.dart';
import 'domain/repositories/debt_repository.dart';
import 'domain/repositories/member_repository.dart';
import 'domain/repositories/receipt_repository.dart';
import 'presentation/pages/debt_tracking_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/split_bill_page.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ReceiptAdapter());
  Hive.registerAdapter(GroceryItemAdapter());
  Hive.registerAdapter(GroupTypeAdapter());
  Hive.registerAdapter(MemberAdapter());
  Hive.registerAdapter(DebtAdapter());

  // Initialize repositories
  final receiptRepo = HiveReceiptRepository();
  final memberRepo = HiveMemberRepository();
  final debtRepo = HiveDebtRepository();

  await Future.wait([
    receiptRepo.initialize(),
    memberRepo.initialize(),
    debtRepo.initialize(),
  ]);

  // Initialize dependencies
  Get.put<ReceiptRepository>(receiptRepo);
  Get.put<MemberRepository>(memberRepo);
  Get.put<DebtRepository>(debtRepo);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GroupGroceries+',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(name: '/split-bill', page: () => const SplitBillPage()),
        GetPage(name: '/debt-tracking', page: () => const DebtTrackingPage()),
      ],
      defaultTransition: Transition.cupertino,
    );
  }
}
