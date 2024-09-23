import 'package:flutter/material.dart';

class SafetyTips extends StatelessWidget {
  final List<String> safetyTips = [
    "1. Find a well-lit area and stay visible.",
    "2. Avoid isolated places; stay where people can see you.",
    "3. Keep your phone handy and charged.",
    "4. Try to stay calm and focus on your surroundings.",
    "5. If possible, move to a public space or near others.",
    "6. Keep any personal alarms or defense tools within reach.",
    "7. Trust your instincts; if something feels wrong, seek help immediately."
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'While You Wait for Help:',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: List.generate(
            safetyTips.length,
            (index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: const Icon(Icons.security, color: Colors.pinkAccent),
                  title: Text(
                    safetyTips[index],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
