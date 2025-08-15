
import '../entities/question.dart';
import '../entities/score.dart';

abstract class QuizRepository {
  Future<List<Question>> getQuestions();
  Future<void> addScore(Score score);
  List<Score> getScores();
}