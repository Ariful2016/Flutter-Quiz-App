import 'package:hive/hive.dart';

part 'score.g.dart';

@HiveType(typeId: 0)
class Score extends HiveObject {
  @HiveField(0)
  String playerName;

  @HiveField(1)
  int score;

  Score({required this.playerName, required this.score});
}