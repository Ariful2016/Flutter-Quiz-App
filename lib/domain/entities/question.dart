import 'dart:convert';

List<Question> questionsFromJson(String str) => List<Question>.from(json.decode(str).map((x) => Question.fromJson(x)));

class Question {
  final String question;
  final List<String> options;
  final int answerIndex;
  final String category;

  Question({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      answerIndex: json['answer_index'],
      category: json['category'],
    );
  }
}