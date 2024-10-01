import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data_entry_emotions.dart'; // emotions page
import 'package:intl/intl.dart';

// Data1Page - sliders for energy and wellbeing data
class Data1Page extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onSave;

  const Data1Page({super.key, required this.selectedDate, required this.onSave});

  @override
  _Data1PageState createState() => _Data1PageState();
}

class _Data1PageState extends State<Data1Page> {
  double _energy = 5;
  double _wellbeing = 5;
  double _sleepsub = 2; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data for the selected date
  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _energy = prefs.getDouble('${widget.selectedDate}_energy') ?? 5;
      _wellbeing = prefs.getDouble('${widget.selectedDate}_wellbeing') ?? 5;
      _sleepsub = prefs.getDouble('${widget.selectedDate}_sleepsub') ?? 2;
    });
  }

  // Save data for the selected date
  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('${widget.selectedDate}_energy', _energy);
    prefs.setDouble('${widget.selectedDate}_wellbeing', _wellbeing);
    prefs.setDouble('${widget.selectedDate}_sleepsub', _sleepsub);
    widget.onSave(widget.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Entry - ${DateFormat.yMMMd().format(widget.selectedDate)}')),
      body: Column(
        children: [
          const Text('Energy Level'),
          Slider(
            value: _energy,
            min: 0,
            max: 49,
            divisions: 49,
            // label: _energy.round().toString(),
            onChanged: (double value) {
              setState(() {
                _energy = value;
              });
            },
          ),
          const Text('Wellbeing Level'),
          Slider(
            value: _wellbeing,
            min: 1,
            max: 49,
            divisions: 49,
            // label: _wellbeing.round().toString(),
            onChanged: (double value) {
              setState(() {
                _wellbeing = value;
              });
            },
          ),
          const Text('Sleep (subjective)'),
          Slider(
            value: _sleepsub,
            min: 0,
            max: 49,
            divisions: 49,
            // label: _sleepsub.round().toString(),
            onChanged: (double value) {
            setState(() {
                _sleepsub = value;
              });
            }, 
          ), 
          ElevatedButton(
            onPressed: () {
              _saveData();  // Save data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Data2Page(selectedDate: widget.selectedDate),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}