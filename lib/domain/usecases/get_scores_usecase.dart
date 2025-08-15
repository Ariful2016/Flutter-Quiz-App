import '../entities/score.dart';
import '../repositories/quiz_repository.dart';

class GetScoresUseCase {
  final QuizRepository repository;

  GetScoresUseCase(this.repository);

  List<Score> call() => repository.getScores();
}