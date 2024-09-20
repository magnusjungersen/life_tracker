// Copyright yeet that shit - hacker way is the only way

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
        brightness: Brightness.dark, 
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
      appBar: AppBar(title: Text('Calendar Overview')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
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
                    decoration: BoxDecoration(
                      color: Colors.greenAccent, // Highlight dates with data
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(color: Colors.white),
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
          child: Icon(Icons.add), // plus icon for button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

