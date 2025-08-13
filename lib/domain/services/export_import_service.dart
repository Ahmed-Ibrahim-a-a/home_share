import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../models/debt.dart';
import '../models/member.dart';

class ExportImportService {
  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  // Export to JSON
  static String exportToJson(List<Member> members, List<Debt> debts) {
    final data = {
      'members': members
          .map((m) => {
                'id': m.id,
                'name': m.name,
                'email': m.email,
                'phoneNumber': m.phoneNumber,
              })
          .toList(),
      'debts': debts
          .map((d) => {
                'id': d.id,
                'fromMemberId': d.fromMemberId,
                'toMemberId': d.toMemberId,
                'amount': d.amount,
                'description': d.description,
                'createdAt': _dateFormat.format(d.createdAt),
                'isPaid': d.isPaid,
              })
          .toList(),
    };

    return jsonEncode(data);
  }

  // Import from JSON string
  static ({List<Member> members, List<Debt> debts}) importFromJson(
      String jsonStr) {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    final members = (data['members'] as List)
        .map((m) => Member(
              id: m['id'],
              name: m['name'],
              email: m['email'],
              phoneNumber: m['phoneNumber'],
            ))
        .toList();

    final debts = (data['debts'] as List)
        .map((d) => Debt(
              id: d['id'],
              fromMemberId: d['fromMemberId'],
              toMemberId: d['toMemberId'],
              amount: (d['amount'] as num).toDouble(),
              description: d['description'],
              createdAt: _dateFormat.parse(d['createdAt']),
              isPaid: d['isPaid'] as bool,
            ))
        .toList();

    return (members: members, debts: debts);
  }

  // Import from JSON file
  static Future<({List<Member> members, List<Debt> debts})> importFromJsonFile(
      File file) async {
    final jsonStr = await file.readAsString();
    return importFromJson(jsonStr);
  }

  // Export to CSV
  static String exportToCsv(List<Member> members, List<Debt> debts) {
    final List<List<dynamic>> csvData = [];

    // Add members section
    csvData.add(['MEMBERS']);
    csvData.add(['ID', 'Name', 'Email', 'Phone Number']);
    for (final member in members) {
      csvData.add([
        member.id,
        member.name,
        member.email ?? '',
        member.phoneNumber ?? '',
      ]);
    }

    // Add empty row as separator
    csvData.add([]);

    // Add debts section
    csvData.add(['DEBTS']);
    csvData.add([
      'ID',
      'From Member ID',
      'To Member ID',
      'Amount',
      'Description',
      'Created At',
      'Is Paid'
    ]);
    for (final debt in debts) {
      csvData.add([
        debt.id,
        debt.fromMemberId,
        debt.toMemberId,
        debt.amount,
        debt.description ?? '',
        _dateFormat.format(debt.createdAt),
        debt.isPaid ? 'Yes' : 'No',
      ]);
    }

    return const ListToCsvConverter().convert(csvData);
  }

  // Import from CSV string
  static ({List<Member> members, List<Debt> debts}) importFromCsv(
      String csvStr) {
    final rows = const CsvToListConverter().convert(csvStr);
    final members = <Member>[];
    final debts = <Debt>[];

    var currentSection = '';
    var headerRow = 0;

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row[0].toString().isEmpty) continue;

      // Check for section headers
      if (row[0] == 'MEMBERS') {
        currentSection = 'MEMBERS';
        headerRow = i + 1;
        continue;
      } else if (row[0] == 'DEBTS') {
        currentSection = 'DEBTS';
        headerRow = i + 1;
        continue;
      }

      // Skip header rows
      if (i == headerRow) continue;

      // Parse data based on current section
      if (currentSection == 'MEMBERS') {
        members.add(Member(
          id: row[0].toString(),
          name: row[1].toString(),
          email: row[2].toString().isNotEmpty ? row[2].toString() : null,
          phoneNumber: row[3].toString().isNotEmpty ? row[3].toString() : null,
        ));
      } else if (currentSection == 'DEBTS') {
        debts.add(Debt(
          id: row[0].toString(),
          fromMemberId: row[1].toString(),
          toMemberId: row[2].toString(),
          amount: double.parse(row[3].toString()),
          description: row[4].toString().isNotEmpty ? row[4].toString() : null,
          createdAt: _dateFormat.parse(row[5].toString()),
          isPaid: row[6].toString().toLowerCase() == 'yes',
        ));
      }
    }

    return (members: members, debts: debts);
  }

  // Import from CSV file
  static Future<({List<Member> members, List<Debt> debts})> importFromCsvFile(
      File file) async {
    final csvStr = await file.readAsString();
    return importFromCsv(csvStr);
  }

  // Export to file methods
  static Future<void> exportToJsonFile(
      List<Member> members, List<Debt> debts, File file) async {
    final jsonStr = exportToJson(members, debts);
    await file.writeAsString(jsonStr);
  }

  static Future<void> exportToCsvFile(
      List<Member> members, List<Debt> debts, File file) async {
    final csvStr = exportToCsv(members, debts);
    await file.writeAsString(csvStr);
  }
}
