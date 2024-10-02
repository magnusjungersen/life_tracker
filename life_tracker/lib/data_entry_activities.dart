import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart'; // for scaling text properly
import 'package:intl/intl.dart';
import 'sql.dart';

class Data3Page extends StatefulWidget {
  final DateTime selectedDate;

  const Data3Page({super.key, required this.selectedDate});

  @override
  _Data3PageState createState() => _Data3PageState();
}

class _Data3PageState extends State<Data3Page> {
  // list all activities for buttons
  final List<String> _freetime = ["Movies", "Read", "Intellectual content", "Gaming", "Working on projects"];
  final List<String> _social = ["Family", "Friends", "Party", "Meeting new people", "Concert", "Festival", "Alone time", "Organization"];
  final List<String> _habits = ["Meditation", "Read before going to bed", "No screen before going to bed"];
  final List<String> _weather = ["Sunny", "Cloudy", "Rain", "Snow", "Heat", "Storm", "Wind"];
  final List<String> _work = ["Class", "Study", "Exam", "Conference", "Give talk", "Research", "Meetings", "Management", "Admin", "Deep work"];
  final List<String> _chores = ["Cleaning", "Cooking food", "Other practical stuff"];
  final List<String> _health = ["Exercise", "Sport", "Walk", "Wellness (e.g., spa)", "Swim", "Sick (being ill)", "Sore (after workout)", "Pain", "Drugs", "Masturbation", "Nap", "Sex"];
  final List<String> _other = ["Impactful positive event", "Impactful negative event", "Travel", "Dont have own room"];
  
  // Map to track selected activities for all segments
  final Map<String, bool> _selectedActivities = {};

  int _selectedWork = 1;
  int _selectedFood = 1;
  int _selectedSleep = 1;
  int _selectedAlcohol = 1;
  int _selectedCaffeine = 1;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  // Load selected activities from SharedPreferences
  void _loadActivities() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    Map<String, dynamic>? data = await dbHelper.getDataByDate(widget.selectedDate.toIso8601String());

    setState(() {
      for (String activity in _freetime + _social + _habits + _weather + _work + _chores + _health + _other) {
        _selectedActivities[activity] = data?[activity] == 1 ? true : false;
      }
      _selectedWork = data?['work'] ?? 1;
      _selectedFood = data?['food'] ?? 1;
      _selectedSleep = data?['sleep'] ?? 1;
      _selectedAlcohol = data?['alcohol'] ?? 1;
      _selectedCaffeine = data?['caffeine'] ?? 1;
    });
  }


  // Save selected activities to SharedPreferences
  // Save selected activities to the SQL database
  void _saveActivities() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    Map<String, dynamic> data = {
      'date': widget.selectedDate.toIso8601String(),
      'work': _selectedWork,
      'food': _selectedFood,
      'sleep': _selectedSleep,
      'alcohol': _selectedAlcohol,
      'caffeine': _selectedCaffeine,
    };

    // Add activities to data map
    for (String activity in _selectedActivities.keys) {
      data[activity] = _selectedActivities[activity]! ? 1 : 0;
    }

    // Insert or update the data in the database
    await dbHelper.insertOrUpdateData(data);
  }

  // Toggle the selected state of an activity
  void _toggleActivity(String activity) {
    setState(() {
      _selectedActivities[activity] = !_selectedActivities[activity]!;
    });
  }

  // Create a grid of buttons for a segment
  Widget _buildActivityGrid(List<String> activities) {
  return GridView.builder(
    shrinkWrap: true,  // Ensures it doesn't overflow
    physics: const NeverScrollableScrollPhysics(), // Avoid scrolling inside grid
    padding: const EdgeInsets.all(5.0),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,  // 4 columns
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2, 
    ),
    itemCount: activities.length,
    itemBuilder: (context, index) {
      String activity = activities[index];
      bool isSelected = _selectedActivities[activity] ?? false;

      return ElevatedButton(
        onPressed: () {
          _toggleActivity(activity);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.green : Colors.grey,  // Updated property
          foregroundColor: Colors.white,  // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), // rounding of border
          ), 
          minimumSize: const Size(50, 5), // set minimum size
          padding: const EdgeInsets.symmetric(horizontal: 10.0), // padding
        ),
        child: AutoSizeText(
          activity,
          textAlign: TextAlign.center,
          maxLines: 3,  // Allow up to 3 lines of text
          style: const TextStyle(fontSize: 14),  // Adjust initial font size
          minFontSize: 10,  // Minimum font size when scaling
          overflow: TextOverflow.ellipsis,  // Add ellipsis (...) if the text overflows
        ),
      );
    },
  );
}
  
  // Build radio button for some categor
  Widget _buildRadioButton(String title, List<String> options, int selectedValue, Function(int?) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Align(
        alignment: Alignment.center, // Center align the category title
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // category font size
          textAlign: TextAlign.center, // Ensures text is centered
        ),
      ),
      const SizedBox(height: 8), // Add some space between title and buttons
      Wrap(
        alignment: WrapAlignment.end, // Left align the buttons
        spacing: 8.0, // Spacing between buttons
        runSpacing: 4.0, // Vertical spacing between rows of buttons
        children: List.generate(options.length, (index) {
          return ElevatedButton(
            onPressed: () {
              onChanged(index + 1); // Pass the selected value when button is pressed
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: (selectedValue == index + 1) ? Colors.green : Colors.grey,  // Change color based on selection
              foregroundColor: Colors.white,  // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),  // Rounded corners for buttons
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Padding inside buttons
            ),
            child: Text(
              options[index],
              style: const TextStyle(fontSize: 12), // button text font size
            ),
          );
        }),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Entry - ${DateFormat.yMMMd().format(widget.selectedDate)}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Free time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildActivityGrid(_freetime),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Social', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildActivityGrid(_social),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Habits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildActivityGrid(_habits),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Weather', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildActivityGrid(_weather),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildRadioButton('Work effort', ['None', 'Low', 'Average', 'Good', 'Intense'], _selectedWork, (int? value) {
              setState(() {
                _selectedWork = value!;
              });
            }), 
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Work activities', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            _buildActivityGrid(_work),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Chores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildActivityGrid(_chores),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Health', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildActivityGrid(_health),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Other', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildActivityGrid(_other),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Other Aspects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildRadioButton('Food Quality', ['Poor', 'Average', 'Good'], _selectedFood, (int? value) {
              setState(() {
                _selectedFood = value!;
              });
            }),
            _buildRadioButton('Sleep Quality', ['Poor', 'Average', 'Good'], _selectedSleep, (int? value) {
              setState(() {
                _selectedSleep = value!;
              });
            }),
            _buildRadioButton('Alcohol Consumption', ['None', 'Little', 'Medium', 'Much'], _selectedAlcohol, (int? value) {
              setState(() {
                _selectedAlcohol = value!;
              });
            }),
            _buildRadioButton('Caffeine Consumption', ['None', 'Little', 'Medium', 'Much'], _selectedCaffeine, (int? value) {
              setState(() {
                _selectedCaffeine = value!;
              });
            }),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            _saveActivities();
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          child: const Text('Add New Data'),
        ),
      ),
    );
  }
}
