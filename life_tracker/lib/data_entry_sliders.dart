import 'package:flutter/material.dart';
import 'sql.dart';
import 'data_entry_emotions.dart'; // emotions page
import 'package:intl/intl.dart';

// Data1Page - sliders for energy and wellbeing data
class Data1Page extends StatefulWidget {
  final DateTime selectedDate;

  const Data1Page({super.key, required this.selectedDate});

  @override
  _Data1PageState createState() => _Data1PageState();
}

class _Data1PageState extends State<Data1Page> {
  double _energy = 50;
  double _mood = 50;
  double _sleep = 50; 
  double _stress = 50; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data for the selected date
  void _loadData() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    Map<String, dynamic>? data = await dbHelper.getDataByDate(widget.selectedDate.toIso8601String());

    if (data != null) {
      setState(() {
        _energy = (data['energy'] as int?)?.toDouble() ?? 50.0;
        _mood = (data['wellbeing'] as int?)?.toDouble() ?? 50.0;
        _sleep = (data['sleep'] as int?)?.toDouble() ?? 50.0;
        _stress = (data['stress'] as int?)?.toDouble() ?? 50.0;
      });
    }
  }

  // Save data for the selected date
  void _saveData() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    Map<String, dynamic> data = {
      'date': widget.selectedDate.toIso8601String(),
      'energy': _energy.round(),
      'mood': _mood.round(),
      'sleep': _sleep.round(),
      'stress': _stress.round(),
    };

    await dbHelper.insertOrUpdateData(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Entry - ${DateFormat.yMMMd().format(widget.selectedDate)}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mood Level'),
            Slider(
              value: _mood,
              min: 0,
              max: 100,
              divisions: 99,
              // label: _mood.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _mood = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Energy Level'),
            Slider(
              value: _energy,
              min: 0,
              max: 100,
              divisions: 99,
              // label: _energy.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _energy = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Sleep Quality'),
            Slider(
              value: _sleep,
              min: 0,
              max: 100,
              divisions: 99,
              // label: _sleep.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _sleep = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Stress level'),
            Slider(
              value: _stress,
              min: 0,
              max: 100,
              divisions: 100,
              // label: _stress.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _stress = value;
                });
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveData();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Data2Page(selectedDate: widget.selectedDate),
                    ),
                  );
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}