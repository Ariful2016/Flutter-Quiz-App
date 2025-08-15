import 'package:flutter/material.dart';
import 'package:flutter_quiz_app/presentation/providers/quiz_repository_provider.dart';
import 'package:flutter_quiz_app/presentation/screens/home_screen.dart';
import 'package:flutter_quiz_app/presentation/screens/leaderboard_screen.dart';
import 'package:flutter_quiz_app/presentation/screens/quiz_screen.dart';
import 'package:flutter_quiz_app/presentation/screens/results_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/datasources/hive_scores_datasource.dart';
import 'data/datasources/local_questions_datasource.dart';
import 'data/repositories/quiz_repository_impl.dart';
import 'domain/entities/score.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ScoreAdapter());
  await Hive.openBox<Score>(HiveScoresDataSource.boxName);
  await TeXRenderingServer.start();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        quizRepositoryProvider.overrideWithValue(
          QuizRepositoryImpl(
            LocalQuestionsDataSource(),
            HiveScoresDataSource(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Quiz App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        routes: {
          '/quiz': (context) => const QuizScreen(),
          '/results': (context) => const ResultsScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
        },
      ),
    );
  }
}