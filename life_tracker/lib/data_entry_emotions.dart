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

  // Load selected emotions from SharedPreferences
  void _loadEmotions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (String emotion in _positive + _negative + _complex) {
        _selectedEmotions[emotion] = prefs.getBool('${widget.selectedDate}_$emotion') ?? false;
      }
    });
  }

  // Save selected emotions to SharedPreferences
  void _saveEmotions() async {
    final prefs = await SharedPreferences.getInstance();
    for (String emotion in _selectedEmotions.keys) {
      prefs.setBool('${widget.selectedDate}_$emotion', _selectedEmotions[emotion]!);
    }
  }

  // Toggle the selected state of an emotion
  void _toggleEmotion(String emotion) {
    setState(() {
      _selectedEmotions[emotion] = !_selectedEmotions[emotion]!;
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
            // Navigator.popUntil(context, ModalRoute.withName('/'));
          },
          child: const Text('Continue'),
        ),
      ),
    );
  }
}
