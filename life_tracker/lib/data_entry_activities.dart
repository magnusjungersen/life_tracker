import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'sql.dart';

class Data3Page extends StatefulWidget {
  final DateTime selectedDate;

  const Data3Page({super.key, required this.selectedDate});

  @override
  _Data3PageState createState() => _Data3PageState();
}

class _Data3PageState extends State<Data3Page> {
  final Map<String, List<String>> _activityCategories = {
    'Free time': ["Movies", "Read", "Intellectual content", "Gaming", "Working on projects"],
    'Social': ["Family", "Friends", "Party", "Meeting new people", "Concert", "Festival", "Alone time", "Organization"],
    'Habits': ["Meditation", "Read before going to bed", "No screen before going to bed"],
    'Weather': ["Sunny", "Cloudy", "Rain", "Snow", "Heat", "Storm", "Wind"],
    'Work': ["Class", "Study", "Exam", "Conference", "Give talk", "Research", "Meetings", "Management", "Admin", "Deep work"],
    'Chores': ["Cleaning", "Cooking food", "Other practical stuff"],
    'Health': ["Exercise", "Sport", "Walk", "Wellness", "Swim", "Sick", "Sore", "Pain", "Drugs", "Masturbation", "Nap", "Sex"],
    'Other': ["Positive event", "Negative event", "Travel", "Dont have own room"],
  };
  
  final Map<String, bool> _selectedActivities = {};
  final Map<String, int> _ratings = {
    'work': 1,
    'food': 2,
    'sleep': 2,
    'alcohol': 1,
    'caffeine': 1,
  };

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final dbHelper = DatabaseHelper();
    // Standardize the date to midnight UTC
    final standardDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    ).toUtc().toIso8601String().split('T')[0];

    final data = await dbHelper.getDataByDate(standardDate);
    
    if (data != null) {
      setState(() {
        for (final category in _activityCategories.values) {
          for (final activity in category) {
            _selectedActivities[activity] = data[activity.replaceAll(' ', '_').toLowerCase()] == 1;
          }
        }
        _ratings.forEach((key, _) => _ratings[key] = data[key] ?? _ratings[key]!);
      });
    }
  }

  Future<void> _saveActivities() async {
    final dbHelper = DatabaseHelper();
    // Standardize the date to midnight UTC
    final standardDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    ).toUtc().toIso8601String().split('T')[0];

    final existingData = await dbHelper.getDataByDate(standardDate) ?? {};

    final newData = {
      'date': standardDate,
      ..._ratings,
      for (final activity in _selectedActivities.keys)
        activity.replaceAll(' ', '_').toLowerCase(): _selectedActivities[activity]! ? 1 : 0,
    };

    await dbHelper.insertOrUpdateData({...existingData, ...newData});
  }

  void _toggleActivity(String activity) => setState(() => _selectedActivities[activity] = !(_selectedActivities[activity] ?? false));

  Widget _buildActivityGrid(List<String> activities) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(5.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2,
      ),
      itemCount: activities.length,
      itemBuilder: (_, index) {
        final activity = activities[index];
        final isSelected = _selectedActivities[activity] ?? false;

        return ElevatedButton(
          onPressed: () => _toggleActivity(activity),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            minimumSize: const Size(50, 5),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
          ),
          child: AutoSizeText(
            activity,
            textAlign: TextAlign.center,
            maxLines: 3,
            style: const TextStyle(fontSize: 14),
            minFontSize: 10,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
  
  Widget _buildRadioButton(String title, List<String> options, String ratingKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8.0,
          runSpacing: 4.0,
          children: List.generate(options.length, (index) {
            return ElevatedButton(
              onPressed: () => setState(() => _ratings[ratingKey] = index + 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: (_ratings[ratingKey] == index + 1) ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              child: Text(options[index], style: const TextStyle(fontSize: 12)),
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
            for (final category in _activityCategories.keys) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildActivityGrid(_activityCategories[category]!),
            ],
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Other Aspects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildRadioButton('Work effort', ['None', 'Low', 'Average', 'Good', 'Intense'], 'work'),
            _buildRadioButton('Food Quality', ['Poor', 'Average', 'Good'], 'food'),
            _buildRadioButton('Sleep Quality', ['Poor', 'Average', 'Good'], 'sleep'),
            _buildRadioButton('Alcohol Consumption', ['None', 'Little', 'Medium', 'Much'], 'alcohol'),
            _buildRadioButton('Caffeine Consumption', ['None', 'Little', 'Medium', 'Much'], 'caffeine'),
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