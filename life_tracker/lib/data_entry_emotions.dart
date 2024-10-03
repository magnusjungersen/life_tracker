import 'package:flutter/material.dart';
import 'sql.dart';
import 'package:intl/intl.dart';
import 'data_entry_activities.dart'; 

// this page tracks emotions: positive, negative and complex

// Data2Page - Emotions
class Data2Page extends StatefulWidget {
  final DateTime selectedDate;

  const Data2Page({super.key, required this.selectedDate});

  @override
  _Data2PageState createState() => _Data2PageState();
}

class _Data2PageState extends State<Data2Page> {
  // List of emotions categories: positive, negative and complex
  final List<String> _positive = ["Happy", "Grateful", "Inspired", "Confident", "Proud", "Relaxed", "Content", "Curious", "Optimistic", "Loved", "Calm", "Hopeful"];
  final List<String> _negative = ["Tired", "Indifferent", "Bored", "Sad", "Lonely", "Anxious", "Frustrated", "Overwhelmed", "Angry", "Jealous", "Guilty", "Disappointed", "Nervous", "Grief", "Insecure", "Stressed"];
  final List<String> _complex = ["Restless", "Nostalgic", "Conflicted"];

  
  // Map to track selected emotions for all segments
  final Map<String, bool> _selectedEmotions = {};

  @override
  void initState() {
    super.initState();
    _loadEmotions();
  }

  // Load selected emotions from databse
  void _loadEmotions() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    // get previously added data to only overwrite relevant data
    Map<String, dynamic>? data = await dbHelper.getDataByDate(widget.selectedDate.toIso8601String());

    if (data != null) {
      setState(() {
        for (String emotion in _positive + _negative + _complex) {
          _selectedEmotions[emotion] = (data[emotion.replaceAll(' ', '_').toLowerCase()] ?? 0) == 1;
        }
      });
    }
  }

  // Save selected emotions to databse
  void _saveEmotions() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    // First, retrieve existing data for the date
    Map<String, dynamic>? existingData = await dbHelper.getDataByDate(widget.selectedDate.toIso8601String());

    Map<String, dynamic> newData = {
      'date': widget.selectedDate.toIso8601String(),
    };

    // add emotions to data map
    for (String emotion in _selectedEmotions.keys) {
      newData[emotion.replaceAll(' ', '_').toLowerCase()] = _selectedEmotions[emotion]! ? 1 : 0; // remember it's case sensitive
    }

    //merge new data with previous data
    if (existingData != null) {
      // Only update the existing data with the new toggled values
      existingData = Map<String, dynamic>.from(existingData); // create mutable copy
      existingData.addAll(newData);
      newData = existingData;
    } else {
      // If no existing data, just insert the new one
      newData = Map<String, dynamic>.from(newData);
    }


    // Insert or update the data in the database
    await dbHelper.insertOrUpdateData(newData);
  }

  // Toggle the selected state of an emotion
  void _toggleEmotion(String emotion) {
    setState(() {
      _selectedEmotions[emotion] = !(_selectedEmotions[emotion] ?? false);
    });
  }

  // Create a grid of buttons for a segment
  Widget _buildEmotionGrid(List<String> emotions) {
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
      itemCount: emotions.length,
      itemBuilder: (context, index) {
        String emotion = emotions[index];
        bool isSelected = _selectedEmotions[emotion] ?? false;

        return ElevatedButton(
          onPressed: () {
            _toggleEmotion(emotion);
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
                emotion,
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
              child: Text('Positive emotions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildEmotionGrid(_positive),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Negative emotions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildEmotionGrid(_negative),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Complex emotions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            _buildEmotionGrid(_complex),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            _saveEmotions();
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
