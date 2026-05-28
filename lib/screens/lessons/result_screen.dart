import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../services/learning_service.dart';
import '../../services/result_data_service.dart';
import 'review_mistakes_screen.dart';

@RoutePage()
class ResultScreen extends StatefulWidget {
  @PathParam('lessonId')
  final String lessonId;
  @PathParam('lessonOrder')
  final int lessonOrder;

  const ResultScreen({
    super.key,
    required this.lessonId,
    required this.lessonOrder,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late final LessonSubmitResultDto _result;
  late final double _accuracy;
  late final int _timeSpentSeconds;
  late final String _lessonTitle;

  @override
  void initState() {
    super.initState();

    // Retrieve result data from service
    final service = ResultDataService();
    _result = service.result!;
    _accuracy = service.accuracy!;
    _timeSpentSeconds = service.timeSpentSeconds!;
    _lessonTitle = service.lessonTitle!;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeMinutes = _timeSpentSeconds <= 0
        ? 0
        : (_timeSpentSeconds / 60).ceil();
    final lessonLabel = widget.lessonOrder > 0
        ? '$_lessonTitle: Module ${widget.lessonOrder.toString().padLeft(2, '0')}'
        : _lessonTitle;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lesson Complete'),
          leading: IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              // Pop back through the navigation stack to return to home
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton.icon(
              onPressed: _reviewLesson,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Review'),
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _opacityAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: _Badge(accuracy: _accuracy),
                ),
                const SizedBox(height: 12),
                Text(
                  lessonLabel,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ResultMetric(
                        label: 'Accuracy',
                        value: _accuracy.round().toString(),
                        suffix: '%',
                        colorScheme: colorScheme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResultMetric(
                        label: 'Time',
                        value: timeMinutes.toString(),
                        suffix: 'min',
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _StreakSection(
                  currentStreak: _result.currentStreak,
                  ranking: _result.ranking,
                  colorScheme: colorScheme,
                  theme: theme,
                ),
                const SizedBox(height: 20),
                _RewardPanel(
                  result: _result,
                  accuracy: _accuracy,
                  colorScheme: colorScheme,
                  theme: theme,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    // Pop ResultScreen and return to previous screen
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Continue'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _reviewLesson,
                  icon: const Icon(Icons.replay, size: 20),
                  label: const Text('Review Mistakes'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reviewLesson() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewMistakesScreen(lessonId: widget.lessonId),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final double accuracy;

  const _Badge({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isGood = accuracy >= 80;

    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isGood
              ? colorScheme.primaryContainer
              : colorScheme.errorContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isGood ? Icons.workspace_premium : Icons.emoji_events,
          color: isGood ? colorScheme.primary : colorScheme.error,
          size: 40,
        ),
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final ColorScheme colorScheme;

  const _ResultMetric({
    required this.label,
    required this.value,
    required this.suffix,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakSection extends StatelessWidget {
  final int currentStreak;
  final String ranking;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _StreakSection({
    required this.currentStreak,
    required this.ranking,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                '$currentStreak',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  height: 0.9,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'day streak',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              final filled = index < math.min(7, currentStreak);
              return Container(
                width: 32,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: filled
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          if (ranking.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              "You're in the $ranking this week!",
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardPanel extends StatelessWidget {
  final LessonSubmitResultDto result;
  final double accuracy;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _RewardPanel({
    required this.result,
    required this.accuracy,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final mastery = result.mastery;
    final masteryProgress = mastery == null
        ? (accuracy / 100).clamp(0.0, 1.0).toDouble()
        : (mastery.progressPercent / 100).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  mastery?.title.isNotEmpty == true
                      ? mastery!.title
                      : 'Vocabulary Master',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${result.xpEarned} XP',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  mastery == null
                      ? '${result.masteredWords} words mastered'
                      : '${mastery.title} Lv ${mastery.level}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${(masteryProgress * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: masteryProgress,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}
