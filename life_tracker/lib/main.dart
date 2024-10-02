// Copyright yeet that shit - hacker way is the only way

// import packages
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'data_entry_sliders.dart'; // slider page
import 'sql.dart';

// run the app
void main() {
  runApp(const LifeTracker());
}

// setup the app
class LifeTracker extends StatelessWidget {
  const LifeTracker({super.key});

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
  final Map<DateTime, bool> _dataEntered = {};  // Map to store if data is entered for a date

  @override
  void initState() {
    super.initState();
    _loadDataStatus();
  }

  // Load data status from SQL database
  void _loadDataStatus() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final data = await dbHelper.getDataByDate(_selectedDay.toIso8601String());

    setState(() {
      if (data != null) {
        _dataEntered[_selectedDay] = true;
      }
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
              builder: (context) => Data1Page(selectedDate: _selectedDay),
            ),
          );
        },
          child: const Icon(Icons.add), // plus icon for button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
