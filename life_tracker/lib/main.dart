// Copyright yeet that shit - hacker way is the only way

// import packages
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'data_entry_sliders.dart'; // slider page
import 'package:gsheets/gsheets.dart'; // for google sheets integration
import 'dart:convert'; // For JSON decoding
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> syncDataIfOnline() async {
  var connectivityResult = await (Connectivity().checkConnectivity());

  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    // Online, sync the unsynced data to Google Sheets
    await syncUnsyncedData();
  } else {
    // Offline, store data locally
    await storeDataLocally();
  }
}

Future<void> storeDataLocally() async {
  final prefs = await SharedPreferences.getInstance();
  // Store unsynced data
  prefs.setString('unsynced_data', 'Mood data');
}

Future<void> syncUnsyncedData() async {
  final prefs = await SharedPreferences.getInstance();
  final unsyncedData = prefs.getString('unsynced_data');
  if (unsyncedData != null) {
    // Send data to Google Sheets
    final file = File('path/to/credentials.json');
    final credentials = await file.readAsString();
    final gsheets = GSheets(credentials);
    final spreadsheetId = '1_chI4kqpjmfQwTl5WKnhgx4XY2SBJUTZuKWgOWeyWeU';
    final sheet = await gsheets.spreadsheet(spreadsheetId);
    final worksheet = sheet.worksheetByTitle('LifeTracker');

    // Add the unsynced data to Google Sheets
    await worksheet!.values.appendRow([unsyncedData]);

    // Clear the locally stored unsynced data
    prefs.remove('unsynced_data');
  }
}

// Actually run the app
void main() {
  runApp(const MyApp());
}

// setup the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, 
        brightness: Brightness.dark, 
      ),
      home: const CalendarPage(),  // Set the CalendarPage as the initial screen
    );
  }
}

// Calendar page
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

// Pages
// Main (calendar overview)
// Enter data: Sliders -> Emotions -> Activities -> saves and updates data and returns to Main

class _CalendarPageState extends State<CalendarPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  final Map<DateTime, bool> _dataEntered = {};

  @override
  void initState() {
    super.initState();
    _loadDataStatus();
  }

  // Load data status from SharedPreferences
  void _loadDataStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (String key in prefs.getKeys()) {
        // Parse the stored date strings and mark the date as having data
        DateTime date = DateTime.parse(key.split('_')[0]);
        _dataEntered[date] = true;
      }
    });
  }

  // Save data status when new data is added
  void _saveDataStatus(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('${date.toIso8601String()}_hasData', true);
    setState(() {
      _dataEntered[date] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar Overview')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            focusedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              // This builder visually marks the days with data
              defaultBuilder: (context, date, focusedDay) {
                if (_dataEntered[date] == true) {
                  // Return a visually different day (e.g., with a colored background or icon)
                  return Container(
                    margin: const EdgeInsets.all(6.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent, // Highlight dates with data
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else {
                  // Default look for days without data
                  return Center(
                    child: Text('${date.day}'),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Data1Page(selectedDate: _selectedDay, onSave: _saveDataStatus),
            ),
          );
        },
          child: const Icon(Icons.add), // plus icon for button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

