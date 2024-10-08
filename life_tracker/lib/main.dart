// Copyright yeet that shit - hacker way is the only way

// import packages
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'data_entry_sliders.dart'; // slider page
import 'sql.dart';
import 'google_sheets_sync.dart';
import 'notifications_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';

// run the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // print('opening app');
  runApp(const LifeTracker());
  // print('opening init notif');
  await NotificationsHandler.initNotifications();
  // print('schedule');
  await NotificationsHandler.scheduleNotifications();
  // print('main done');
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
      debugShowCheckedModeBanner: false,
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
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  String? _version; // get current version
  
  @override
  void initState() {
    super.initState();
    _getVersion(); // load app version
    _loadDataStatus();
    _syncWithGoogleSheets();
    
  }
  
  // get version
  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version; // Store the version number
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDataStatus();
  }

  // Load data status from SQL database
  void _loadDataStatus() async {
    final allData = await _dbHelper.getAllData();
    setState(() {
      _dataEntered.clear(); // Clear existing data
      for (var data in allData) {
        final date = DateTime.parse(data['date'] as String);
        _dataEntered[date] = true;
      }
    });
  }

  // sync with gsheets
  void _syncWithGoogleSheets() async {
    await GoogleSheetsSync.syncData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Syncing with Google Sheets...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncWithGoogleSheets,
          ),
        ],
      ),
      body: TableCalendar(
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
          defaultBuilder: (context, date, _) {
            return _buildCalendarDay(date);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Data1Page(selectedDate: _selectedDay),
            ),
          );
          _loadDataStatus();
        },
          child: const Icon(Icons.add), // plus icon for button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: SizedBox(
        height: 50,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'Version: ${_version ?? "Loading..."}', // Show version
              style: const TextStyle(color: Colors.white),
            ),
          )
        ),
      ),
    );
  }
  Widget _buildCalendarDay(DateTime date) {
    final hasData = _dataEntered[date] == true;
    return Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hasData ? Colors.greenAccent : null,
      ),
      child: Text(
        '${date.day}',
        style: TextStyle(
          color: hasData ? Colors.white : null,
        ),
      ),
    );
  }
}
