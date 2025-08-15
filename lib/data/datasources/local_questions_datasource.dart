import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/question.dart';

class LocalQuestionsDataSource {
  Future<List<Question>> getQuestions() async {
    final String response = await rootBundle.loadString('assets/questions.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Question.fromJson(json)).toList();
  }
}