// Copyright yeet

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'data_entry1.dart';

// Actually run the app
void main() {
  runApp(MyApp());
}

// setup the app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Tracker',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: CalendarPage(),  // Set the CalendarPage as the initial screen
    );
  }
}

// Calendar page
class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, bool> _dataEntered = {};

  @override
  void initState() {
    super.initState();
    _loadDataStatus();
  }

  // Load data status from shared preferences
  void _loadDataStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (String key in prefs.getKeys()) {
        _dataEntered[DateTime.parse(key)] = true;
      }
    });
  }

  // Save data status when new data is added
  void _saveDataStatus(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(date.toIso8601String(), true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar Overview')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _selectedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              // Navigate to Data1Page with selectedDate
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Data1Page(selectedDate: _selectedDay, onSave: _saveDataStatus),
                ),
              );
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, _) {
                if (_dataEntered[date] == true) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Icon(
                      Icons.check_circle,
                      size: 16.0,
                      color: Colors.green,
                    ),
                  );
                }
                return null;
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
        child: Icon(Icons.add),
      ),
    );
  }
}

