import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data2Page for activities
class Data2Page extends StatefulWidget {
  final DateTime selectedDate;

  Data2Page({required this.selectedDate});

  @override
  _Data2PageState createState() => _Data2PageState();
}

class _Data2PageState extends State<Data2Page> {
  List<String> _segment1 = ["Exercise", "Reading", "Meditation", "TV", "Gaming"];
  Map<String, bool> _selectedActivities = {};

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  // Load activities for the selected date
  void _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    for (String activity in _segment1) {
      setState(() {
        _selectedActivities[activity] =
            prefs.getBool('${widget.selectedDate}_$activity') ?? false;
      });
    }
  }

  // Save activities for the selected date
  void _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    for (String activity in _selectedActivities.keys) {
      prefs.setBool('${widget.selectedDate}_$activity', _selectedActivities[activity]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Activities - ${widget.selectedDate.toLocal()}')),
      body: ListView(
        children: [
          Text('Segment 1'),
          ..._segment1.map((activity) {
            return CheckboxListTile(
              title: Text(activity),
              value: _selectedActivities[activity] ?? false,
              onChanged: (bool? value) {
                setState(() {
                  _selectedActivities[activity] = value!;
                });
              },
            );
          }).toList(),
        ],
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          _saveActivities();
          Navigator.popUntil(context, ModalRoute.withName('/'));
        },
        child: Text('Add New Data'),
      ),
    );
  }
}
