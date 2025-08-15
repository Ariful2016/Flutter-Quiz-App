import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/score.dart';
import '../../domain/usecases/get_scores_usecase.dart';
import '../providers/quiz_repository_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(quizRepositoryProvider);
    final useCase = GetScoresUseCase(repository);
    final List<Score> scores = useCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard'), centerTitle: true),
      body: scores.isEmpty
          ? const Center(child: Text('No scores yet'))
          : ListView.builder(
              itemCount: scores.length,
              itemBuilder: (context, index) {
                final score = scores[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('#${index + 1}'),
                    ),
                    title: Text(score.playerName),
                    trailing: Text(
                      score.score.toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                );
              },
            ),
    );
  }
}