import '../entities/question.dart';
import '../repositories/quiz_repository.dart';

class GetQuestionsUseCase {
  final QuizRepository repository;

  GetQuestionsUseCase(this.repository);

  Future<List<Question>> call() => repository.getQuestions();
}