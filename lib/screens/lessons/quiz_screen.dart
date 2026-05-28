import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../routes/app_router.dart';
import '../../services/app_refresh_service.dart';
import '../../services/learning_service.dart';
import '../../services/result_data_service.dart';

@RoutePage()
class QuizScreen extends StatefulWidget {
  @PathParam('lessonId')
  final String lessonId;
  @PathParam('lessonOrder')
  final int lessonOrder;

  const QuizScreen({
    super.key,
    required this.lessonId,
    required this.lessonOrder,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final LearningService _learningService;
  late Future<LessonDetailDto> _lessonDetailFuture;
  final Map<String, String> _selectedAnswers = {};
  final Map<String, List<String>> _shuffledOptions = {};
  bool _isSubmitting = false;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _learningService = LearningService();
    _lessonDetailFuture = _learningService
        .fetchLessonDetail(widget.lessonId)
        .then((lesson) {
          // Shuffle options once when lesson is loaded
          for (var question in lesson.questions) {
            final options = [question.correctAnswer, ...question.distractors];
            options.shuffle();
            _shuffledOptions[question.id] = options;
          }
          return lesson;
        });
    _startTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit Quiz?'),
                content: const Text('Your progress will not be saved.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Continue'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Exit'),
                  ),
                ],
              ),
            ) ??
            false;
        if (shouldPop && context.mounted) {
          context.maybePop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lesson ${widget.lessonOrder}'),
          elevation: 0,
        ),
        body: FutureBuilder<LessonDetailDto>(
          future: _lessonDetailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: null),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _lessonDetailFuture = _learningService
                            .fetchLessonDetail(widget.lessonId);
                      }),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final lessonDetail = snapshot.data!;
            final questions = lessonDetail.questions;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ...List.generate(
                          questions.length,
                          (index) => _buildQuestionCard(
                            context,
                            questions[index],
                            index + 1,
                            questions.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _isSubmitting ||
                              _selectedAnswers.length != questions.length
                          ? null
                          : () => _submitLesson(lessonDetail),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit Answers'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    QuestionDto question,
    int questionNumber,
    int totalQuestions,
  ) {
    // Use pre-shuffled options to avoid re-shuffling on rebuild
    final options =
        _shuffledOptions[question.id] ??
        [question.correctAnswer, ...question.distractors];

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question $questionNumber of $totalQuestions',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                if (question.imageUrl != null)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        question.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Word: ${question.word}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Context: "${question.contextSentence}"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'What does it mean?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...options.map((option) {
              final isSelected = _selectedAnswers[question.id] == option;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAnswers[question.id] = option;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(option)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _submitLesson(LessonDetailDto lessonDetail) async {
    setState(() => _isSubmitting = true);

    try {
      final timeSpent = DateTime.now().difference(_startTime).inSeconds;
      final submittedTimeSpent = timeSpent <= 0 ? 1 : timeSpent;

      // Calculate accuracy
      int correctCount = 0;
      final answers = lessonDetail.questions.map((question) {
        final userAnswer = _selectedAnswers[question.id] ?? '';
        final isCorrect = userAnswer == question.correctAnswer;
        if (isCorrect) correctCount++;
        return AnswerPayloadDto(
          questionId: question.id,
          selectedAnswer: userAnswer,
          isCorrect: isCorrect,
        );
      }).toList();

      final accuracy = lessonDetail.questions.isEmpty
          ? '0.0'
          : (correctCount / lessonDetail.questions.length * 100)
                .toStringAsFixed(1);

      final result = await _learningService.submitLesson(
        lessonId: widget.lessonId,
        answers: answers,
        timeSpentSeconds: submittedTimeSpent,
        accuracy: double.parse(accuracy),
      );
      AppRefreshService.notifyLearningDataChanged();

      if (mounted) {
        // Store result data in service for ResultScreen to retrieve
        final service = ResultDataService();
        service.result = result;
        service.accuracy = double.parse(accuracy);
        service.timeSpentSeconds = submittedTimeSpent;
        service.lessonId = widget.lessonId;
        service.lessonTitle = lessonDetail.topicTitle.isEmpty
            ? 'Lesson ${widget.lessonOrder}'
            : lessonDetail.topicTitle;

        // Navigate using auto_route
        final lessonOrder = lessonDetail.order == 0
            ? widget.lessonOrder
            : lessonDetail.order;
        context.router.push(
          ResultRoute(lessonId: widget.lessonId, lessonOrder: lessonOrder),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isSubmitting = false);
      }
    }
  }
}
