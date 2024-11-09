import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sql.dart';
import 'data_entry_emotions.dart';

class Data1Page extends StatefulWidget {
  final DateTime selectedDate;

  const Data1Page({super.key, required this.selectedDate});

  @override
  _Data1PageState createState() => _Data1PageState();
}

class _Data1PageState extends State<Data1Page> {
  final Map<String, double> _sliderValues = {
    'Mood': 50,
    'Energy': 50,
    'Productivity': 50,
    'Stress': 50,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dbHelper = DatabaseHelper();
    // Standardize the date to midnight UTC
    final standardDate = DateTime.utc(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    ).toIso8601String();
    
    final data = await dbHelper.getDataByDate(standardDate);

    if (data != null) {
      setState(() {
        _sliderValues['Mood'] = (data['mood'] as int?)?.toDouble() ?? 50.0;
        _sliderValues['Energy'] = (data['energy'] as int?)?.toDouble() ?? 50.0;
        _sliderValues['Productivity'] = (data['productivity'] as int?)?.toDouble() ?? 50.0;
        _sliderValues['Stress'] = (data['stress'] as int?)?.toDouble() ?? 50.0;
      });
    }
  }

  Future<void> _saveData() async {
    final dbHelper = DatabaseHelper();
    // Standardize the date to midnight UTC
    final standardDate = DateTime.utc(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    ).toIso8601String(); // Convert to local time and format to "yyyy-MM-dd"
    
    final existingData = await dbHelper.getDataByDate(standardDate) ?? {};

    final newData = {
      'date': standardDate,
      'mood': _sliderValues['Mood']!.round(),
      'energy': _sliderValues['Energy']!.round(),
      'productivity': _sliderValues['Productivity']!.round(),
      'stress': _sliderValues['Stress']!.round(),
    };

    await dbHelper.insertOrUpdateData({...existingData, ...newData});
  }

  Widget _buildSlider(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: _sliderValues[label]!,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (double value) {
            setState(() {
              _sliderValues[label] = value;
            });
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Entry - ${DateFormat.yMMMd().format(widget.selectedDate)}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._sliderValues.keys.map(_buildSlider),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _saveData();
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Data2Page(selectedDate: widget.selectedDate ),
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