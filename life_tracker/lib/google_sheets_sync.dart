import 'package:flutter/services.dart' show rootBundle;
import 'package:gsheets/gsheets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sql.dart';

class GoogleSheetsSync {
  static const _spreadsheetId = '1_chI4kqpjmfQwTl5WKnhgx4XY2SBJUTZuKWgOWeyWeU'; // spreadsheet ID
  static const _worksheetTitle = 'LifeTracker'; // worksheet title

  static Future<void> syncData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection. Skipping sync.');
      return;
    }

    try {
      final credentialsJson = await rootBundle.loadString('assets/credentials.json');
      final gsheets = GSheets(credentialsJson);
      final ss = await gsheets.spreadsheet(_spreadsheetId);
      final sheet = await ss.worksheetByTitle(_worksheetTitle);

      if (sheet == null) {
        throw Exception('Worksheet not found');
      }

      final dbHelper = DatabaseHelper();
      final allData = await dbHelper.getAllData();

      // Assuming the first row is headers
      final headers = allData.first.keys.toList();
      await sheet.values.insertRow(1, headers);

      // Start from row 2 to skip headers
      for (var i = 0; i < allData.length; i++) {
        final row = allData[i].values.toList();
        await sheet.values.insertRow(i + 2, row);
      }

      // print('Data synced successfully');
    } catch (e) {
      // print('Error syncing data: $e');
    }
  }
}