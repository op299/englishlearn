import 'package:flutter/material.dart';

import '../../services/user_service.dart';
import 'quiz_screen.dart';

class ReviewMistakesScreen extends StatefulWidget {
  final String? lessonId;

  const ReviewMistakesScreen({super.key, this.lessonId});

  @override
  State<ReviewMistakesScreen> createState() => _ReviewMistakesScreenState();
}

class _ReviewMistakesScreenState extends State<ReviewMistakesScreen> {
  late final UserService _userService;
  late Future<List<ReviewMistakeDto>> _mistakesFuture;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _mistakesFuture = _loadMistakes();
  }

  Future<List<ReviewMistakeDto>> _loadMistakes() async {
    final result = await _userService.fetchReviewMistakes();
    final lessonId = widget.lessonId;
    if (lessonId == null || lessonId.isEmpty) {
      return result.mistakes;
    }
    return result.mistakes
        .where((mistake) => mistake.lessonId == lessonId)
        .toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _mistakesFuture = _loadMistakes();
    });
    await _mistakesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Mistakes'), elevation: 0),
      body: FutureBuilder<List<ReviewMistakeDto>>(
        future: _mistakesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final mistakes = snapshot.data ?? [];
          if (mistakes.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.check_circle_outline,
                    size: 56,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No mistakes to review',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: mistakes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _MistakeCard(mistake: mistakes[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  final ReviewMistakeDto mistake;

  const _MistakeCard({required this.mistake});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mistake.topicTitle.isEmpty ? 'Review Lesson' : mistake.topicTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              mistake.word,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              mistake.contextSentence,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            _AnswerLine(
              label: 'Your answer',
              value: mistake.selectedAnswer,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            _AnswerLine(
              label: 'Correct',
              value: mistake.correctAnswer,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(
                        lessonId: mistake.lessonId,
                        lessonOrder: mistake.lessonOrder <= 0
                            ? 1
                            : mistake.lessonOrder,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.replay),
                label: const Text('Practice lesson'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AnswerLine({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(child: Text(value.isEmpty ? '-' : value)),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: null),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
