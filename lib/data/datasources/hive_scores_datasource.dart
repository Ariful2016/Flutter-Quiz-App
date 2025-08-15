import 'package:hive/hive.dart';
import '../../domain/entities/score.dart';

class HiveScoresDataSource {
  static const String boxName = 'leaderboard';

  Box<Score> get box => Hive.box<Score>(boxName);

  Future<void> addScore(Score score) async {
    await box.add(score);
  }

  List<Score> getScores() {
    return box.values.toList()..sort((a, b) => b.score.compareTo(a.score));
  }
}