import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'sql.dart';
import 'data_entry_activities.dart';

class Data2Page extends StatefulWidget {
  final DateTime selectedDate;

  const Data2Page({super.key, required this.selectedDate});

  @override
  _Data2PageState createState() => _Data2PageState();
}

class _Data2PageState extends State<Data2Page> {
  final Map<String, List<String>> _emotionCategories = {
    'Positive emotions': ["Calm", "Confident", "Content", "Curious", "Grateful", "Happy", "Hopeful", "Inspired", "Loved", "Optimistic", "Proud", "Relaxed"],
    'Negative emotions': ["Angry", "Anxious", "Bored", "Disappointed", "Frustrated", "Grief", "Guilty", "Insecure", "Jealous", "Lonely", "Nervous", "Overwhelmed", "Sad", "Stressed", "Tired", "Indifferent"],
    'Complex emotions': ["Conflicted", "Nostalgic", "Restless"],
  };
  
  final Map<String, bool> _selectedEmotions = {};

  @override
  void initState() {
    super.initState();
    _loadEmotions();
  }

  Future<void> _loadEmotions() async {
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
        for (final category in _emotionCategories.values) {
          for (final emotion in category) {
            _selectedEmotions[emotion] = data[emotion.replaceAll(' ', '_').toLowerCase()] == 1;
          }
        }
      });
    }
  }

  Future<void> _saveEmotions() async {
    final dbHelper = DatabaseHelper();
    // Standardize the date to midnight UTC
    final standardDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    ).toUtc().toIso8601String().split('T')[0];

    final existingData = await dbHelper.getDataByDate(standardDate) ?? {};

    final newData = {
      'date': standardDate, // use standardized date
      for (final emotion in _selectedEmotions.keys)
        emotion.replaceAll(' ', '_').toLowerCase(): _selectedEmotions[emotion]! ? 1 : 0,
    };

    await dbHelper.insertOrUpdateData({...existingData, ...newData});
  }

  void _toggleEmotion(String emotion) => setState(() => _selectedEmotions[emotion] = !(_selectedEmotions[emotion] ?? false));

  Widget _buildEmotionGrid(List<String> emotions) {
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
      itemCount: emotions.length,
      itemBuilder: (_, index) {
        final emotion = emotions[index];
        final isSelected = _selectedEmotions[emotion] ?? false;

        return ElevatedButton(
          onPressed: () => _toggleEmotion(emotion),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.green : Colors.grey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            minimumSize: const Size(50, 5),
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              emotion,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
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
            for (final category in _emotionCategories.keys) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              _buildEmotionGrid(_emotionCategories[category]!),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () async {
            await _saveEmotions();
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Data3Page(selectedDate: widget.selectedDate),
              ),
            );
          },
          child: const Text('Continue'),
        ),
      ),
    );
  }
}