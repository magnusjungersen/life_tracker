import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Data2Page extends StatefulWidget {
  final DateTime selectedDate;

  const Data2Page({super.key, required this.selectedDate});

  @override
  _Data2PageState createState() => _Data2PageState();
}

class _Data2PageState extends State<Data2Page> {
  // Activities for 3 segments
  final List<String> _segment1 = ["Exercise", "Reading", "Meditation", "TV", "Gaming"];
  final List<String> _segment2 = ["Cooking", "Music", "Walking", "Yoga", "Art"];
  final List<String> _segment3 = ["Socializing", "Work", "Shopping", "Cleaning", "Sleeping", "other"];
  
  // Map to track selected activities for all segments
  final Map<String, bool> _selectedActivities = {};

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  // Load selected activities from SharedPreferences
  void _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (String activity in _segment1 + _segment2 + _segment3) {
        _selectedActivities[activity] = prefs.getBool('${widget.selectedDate}_$activity') ?? false;
      }
    });
  }

  // Save selected activities to SharedPreferences
  void _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    for (String activity in _selectedActivities.keys) {
      prefs.setBool('${widget.selectedDate}_$activity', _selectedActivities[activity]!);
    }
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
              borderRadius: BorderRadius.circular(5.0) // rounding of border
            ), 
            minimumSize: const Size(50, 5), // set minimum size
            padding: const EdgeInsets.symmetric(horizontal: 10.0), // padding
          ),
          child: FittedBox(
            fit: BoxFit.contain, 
              child: Text(
                activity,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10),
              )
          ),
        );
      },
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
              child: Text('Segment 1', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildActivityGrid(_segment1),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Segment 2', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildActivityGrid(_segment2),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Segment 3', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildActivityGrid(_segment3),
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
          child: const Text('Continue'),
        ),
      ),
    );
  }
}
