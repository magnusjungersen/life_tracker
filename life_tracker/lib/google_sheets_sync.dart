import 'package:flutter/services.dart' show rootBundle;
import 'package:gsheets/gsheets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sql.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class GoogleSheetsSync {
  static Future<Map<String, String>> _loadConfig() async {
    // Load the config.json file
    final configJson = await rootBundle.loadString('assets/config.json');
    final configData = json.decode(configJson);

    // Choose between debug or release based on kDebugMode
    if (kDebugMode) {
      return {
        'spreadsheetID': configData['debug']['spreadsheetID'],
        'worksheetTitle': configData['debug']['worksheetTitle'],
      };
    } else {
      return {
        'spreadsheetID': configData['release']['spreadsheetID'],
        'worksheetTitle': configData['release']['worksheetTitle'],
      };
    }
  }

  static Future<void> syncData() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // print('No internet connection. Skipping sync.');
      return;
    }

    try {
      final credentialsJson = await rootBundle.loadString('assets/credentials.json');

      final gsheets = GSheets(credentialsJson);

      // Load config depending on whether debug or release
      final config = await _loadConfig();
      final spreadsheetID = config['spreadsheetID']!;
      final worksheetTitle = config['worksheetTitle']!;

      final ss = await gsheets.spreadsheet(spreadsheetID);
      final sheet = await ss.worksheetByTitle(worksheetTitle);

      if (sheet == null) {
        throw Exception('Worksheet not found');
      }

      final dbHelper = DatabaseHelper();
      final allData = await dbHelper.getAllData();

      // print('allData');

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