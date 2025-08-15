import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> categories = [
    'Geography',
    'Math',
    'Science',
    'Literature',
  ];

  void _showCategoryDialog(BuildContext context) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Category'),
          children: categories
              .map((cat) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, cat),
                    child: Text(cat),
                  ))
              .toList(),
        );
      },
    );
    if (selected != null) {
      Navigator.pushNamed(context, '/quiz', arguments: {'category': selected});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _showCategoryDialog(context),
              child: const Text('Start Quiz'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
              child: const Text('Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}