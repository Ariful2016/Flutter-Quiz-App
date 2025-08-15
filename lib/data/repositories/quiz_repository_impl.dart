import '../../domain/entities/question.dart';
import '../../domain/entities/score.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/hive_scores_datasource.dart';
import '../datasources/local_questions_datasource.dart';

class QuizRepositoryImpl implements QuizRepository {
  final LocalQuestionsDataSource questionsDataSource;
  final HiveScoresDataSource scoresDataSource;

  QuizRepositoryImpl(this.questionsDataSource, this.scoresDataSource);

  @override
  Future<List<Question>> getQuestions() => questionsDataSource.getQuestions();

  @override
  Future<void> addScore(Score score) => scoresDataSource.addScore(score);

  @override
  List<Score> getScores() => scoresDataSource.getScores();
}