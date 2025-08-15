import '../entities/score.dart';
import '../repositories/quiz_repository.dart';

class AddScoreUseCase {
  final QuizRepository repository;

  AddScoreUseCase(this.repository);

  Future<void> call(Score score) => repository.addScore(score);
}