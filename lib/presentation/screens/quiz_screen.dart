import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _questionAnimationController;
  late Animation<double> _questionAnimation;

  @override
  void initState() {
    super.initState();
    _questionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _questionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _questionAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _questionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final selectedCategory = args != null ? args['category'] as String? : null;
    final questionsAsync = ref.watch(questionsProvider);

    return questionsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Error: $err'))),
      data: (questions) {
        if (selectedCategory == null) {
          return Scaffold(
              appBar: AppBar(title: const Text('Quiz'), centerTitle: true),
              body: const Center(child: Text('No category selected')));
        }

        final quizState = ref.watch(quizProvider(selectedCategory));
        final quizNotifier = ref.read(quizProvider(selectedCategory).notifier);

        if (quizState.total == 0) {
          return Scaffold(
              appBar: AppBar(title: const Text('Quiz'), centerTitle: true),
              body: Center(child: Text('No questions available for $selectedCategory')));
        }

        // Trigger animation when question changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_questionAnimationController.status == AnimationStatus.dismissed) {
            _questionAnimationController.forward();
          }
        });

        return Scaffold(
          appBar: AppBar(
            title: const Text('Quiz'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(constraints.maxWidth * 0.05),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey(quizState.currentIndex), // Key for animation
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress bar
                        LinearProgressIndicator(
                          value:
                          (quizState.currentIndex + 1) / quizState.total,
                          backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Question number
                        Text(
                          'Question ${quizState.currentIndex + 1}/${quizState.total}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 20),

                        // Timer
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            padding: const EdgeInsets.all(12),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: quizState.timeLeft / 15.0,
                                  strokeWidth: 8,
                                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    quizState.timeLeft <= 5 
                                        ? Colors.red 
                                        : quizState.timeLeft <= 10 
                                            ? Colors.orange 
                                            : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  '${quizState.timeLeft}s',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: quizState.timeLeft <= 5 
                                        ? Colors.red 
                                        : quizState.timeLeft <= 10 
                                            ? Colors.orange 
                                            : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Question card
                        _buildQuestionContainer(context, quizState.currentQuestion.question),
                        const SizedBox(height: 20),

                        // Options
                        ...quizState.currentQuestion.options
                            .asMap()
                            .entries
                            .map((entry) {
                          final int idx = entry.key;
                          final String option = entry.value;
                          final bool isSelected = quizState.selectedIndex == idx;
                          final bool isCorrectOption = idx == quizState.currentQuestion.answerIndex;
                          final bool isTimeUp = quizState.selectedIndex == -1;
                          Color? bgColor;
                          Color? textColor;
                          if (quizState.selectedIndex != null || isTimeUp) {
                            if (isSelected) {
                              bgColor = quizState.isCorrect == true ? Colors.green : Colors.red;
                              textColor = Colors.white;
                            } else if (isCorrectOption) {
                              bgColor = Colors.green;
                              textColor = Colors.white;
                            }
                          }
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              color: bgColor ?? Theme.of(context).colorScheme.surface,
                              child: InkWell(
                                onTap: (quizState.selectedIndex == null && !isTimeUp)
                                    ? () => quizNotifier.selectAnswer(idx)
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _optionIndexCircle(context, idx, textColor),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildContent(
                                          option,
                                          context,
                                          textColorOverride: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),

                        // Next / Finish button
                        if (quizState.selectedIndex != null || quizState.selectedIndex == -1)
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // Reset animation for next question
                                _questionAnimationController.reset();
                                if (quizState.currentIndex <
                                    quizState.total - 1) {
                                  quizNotifier.nextQuestion();
                                } else {
                                  final finalScore =
                                  quizNotifier.getFinalScore();
                                  Navigator.pushNamed(
                                    context,
                                    '/results',
                                    arguments: {
                                      'score': finalScore,
                                      'total': quizState.total
                                    },
                                  );
                                }
                              },
                              child: Text(
                                quizState.currentIndex <
                                    quizState.total - 1
                                    ? 'Next'
                                    : 'Finish',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Helper: detect if the string contains block TeX ($$ ... $$)
  bool _hasBlockTeX(String text) {
    return text.contains(r'$$');
  }

  Widget _buildContent(String value, BuildContext context, {Color? textColorOverride}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textStyle = theme.textTheme.titleMedium?.copyWith(
      color: textColorOverride ?? theme.colorScheme.onSurface,
    );

    // If no block TeX, render as normal text
    if (!_hasBlockTeX(value)) {
      return Text(value, style: textStyle);
    }

    // Split into Text and TeXView widgets rendered in order
    final RegExp block = RegExp(r"\$\$([\s\S]*?)\$\$");
    final List<Widget> segments = [];
    int lastIndex = 0;
    for (final match in block.allMatches(value)) {
      if (match.start > lastIndex) {
        final plain = value.substring(lastIndex, match.start);
        if (plain.trim().isNotEmpty) {
          segments.add(Text(plain, style: textStyle));
        }
      }
      final tex = match.group(0) ?? '';
      segments.add(
        TeXWidget(
          key: ValueKey<String>('tex-${tex.hashCode}'),
          math: tex,
          displayFormulaWidgetBuilder: (context, displayFormula) {
            return TeX2SVG(
              math: displayFormula,
              formulaWidgetBuilder: (context, svg) {
                return SvgPicture.string(
                  svg,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : Colors.black,
                    BlendMode.srcIn,
                  ),
                  height: 32,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                );
              },
            );
          },
          inlineFormulaWidgetBuilder: (context, inlineFormula) {
            return TeX2SVG(
              math: inlineFormula,
              formulaWidgetBuilder: (context, svg) {
                return SvgPicture.string(
                  svg,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : Colors.black,
                    BlendMode.srcIn,
                  ),
                  height: 20,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                );
              },
            );
          },
          textWidgetBuilder: (context, text) {
            return TextSpan(
              text: text,
              style: textStyle,
            );
          },
        ),
      );
      lastIndex = match.end;
    }
    if (lastIndex < value.length) {
      final tail = value.substring(lastIndex);
      if (tail.trim().isNotEmpty) {
        segments.add(Text(tail, style: textStyle));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments,
    );
  }

  Widget _buildQuestionContainer(BuildContext context, String questionText) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF23272F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildContent(questionText, context),
    );
  }

  Widget _buildOptionContainer(
      BuildContext context, String optionText, bool isSelected, bool isCorrect, bool isDisabled, VoidCallback? onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isDisabled) {
      if (isSelected) {
        bgColor = isCorrect ? Colors.green : Colors.red;
        borderColor = bgColor;
        textColor = Colors.white;
      } else if (isCorrect) {
        bgColor = Colors.green;
        borderColor = bgColor;
        textColor = Colors.white;
      } else {
        bgColor = isDark ? const Color(0xFF23272F) : Colors.white;
        borderColor = isDark ? Colors.white12 : Colors.black12;
        textColor = isDark ? Colors.white70 : Colors.black87;
      }
    } else if (isSelected) {
      bgColor = theme.colorScheme.primary.withOpacity(0.15);
      borderColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.primary;
    } else {
      bgColor = isDark ? const Color(0xFF23272F) : Colors.white;
      borderColor = isDark ? Colors.white12 : Colors.black12;
      textColor = isDark ? Colors.white70 : Colors.black87;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isDisabled ? null : onTap,
        child: _buildContent(optionText, context, textColorOverride: textColor),
      ),
    );
  }

  // Helper: leading A/B/C/D circle
  Widget _optionIndexCircle(BuildContext context, int idx, Color? textColorOverride) {
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (textColorOverride != null) ? textColorOverride.withOpacity(0.2) : Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      alignment: Alignment.center,
      child: Text(
        letters[idx % letters.length],
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: textColorOverride ?? Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Minimal HTML escape for text segments
  String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}
