import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../services/learning_service.dart';
import 'review_mistakes_screen.dart';

class ResultScreen extends StatefulWidget {
  final LessonSubmitResultDto result;
  final double accuracy;
  final int timeSpentSeconds;
  final String lessonId;
  final int lessonOrder;
  final String lessonTitle;

  const ResultScreen({
    super.key,
    required this.result,
    required this.accuracy,
    required this.timeSpentSeconds,
    required this.lessonId,
    required this.lessonOrder,
    required this.lessonTitle,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
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
    final timeMinutes = widget.timeSpentSeconds <= 0
        ? 0
        : (widget.timeSpentSeconds / 60).ceil();
    final lessonLabel = widget.lessonOrder > 0
        ? '${widget.lessonTitle}: Module ${widget.lessonOrder.toString().padLeft(2, '0')}'
        : widget.lessonTitle;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              children: [
                _TopBar(onClose: _goHome),
                const SizedBox(height: 40),
                ScaleTransition(scale: _scaleAnimation, child: const _Badge()),
                const SizedBox(height: 16),
                const Text(
                  'Lesson Complete',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF070D22),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lessonLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF6B7B96),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _ResultMetric(
                        label: 'ACCURACY',
                        value: widget.accuracy.round().toString(),
                        suffix: '%',
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: _ResultMetric(
                        label: 'TIME',
                        value: timeMinutes.toString(),
                        suffix: 'MIN',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 28),
                const Text(
                  'DAILY STREAK',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 1,
                    color: Color(0xFF93A2B8),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFF071126),
                      size: 36,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.result.currentStreak.toString(),
                      style: const TextStyle(
                        fontSize: 64,
                        height: 0.9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF071126),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _StreakBars(streak: widget.result.currentStreak),
                const SizedBox(height: 14),
                Text(
                  widget.result.ranking.isEmpty
                      ? 'RANKING UPDATED'
                      : "YOU'RE IN THE ${widget.result.ranking.toUpperCase()} THIS WEEK",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0D67FF),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 28),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 24),
                _RewardPanel(result: widget.result, accuracy: widget.accuracy),
                const SizedBox(height: 28),
                SizedBox(
                  height: 88,
                  child: ElevatedButton(
                    onPressed: _goHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D67FF),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        letterSpacing: 5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  height: 76,
                  child: OutlinedButton(
                    onPressed: _reviewLesson,
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'REVIEW MISTAKES',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 17,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _reviewLesson() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewMistakesScreen(lessonId: widget.lessonId),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onClose;

  const _TopBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close, size: 32, color: Color(0xFF070D22)),
        ),
        const Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFF0D67FF), size: 24),
              SizedBox(width: 8),
              Text(
                'SESSION COMPLETE',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Icon(
          Icons.workspace_premium,
          color: Color(0xFF0D67FF),
          size: 54,
        ),
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;

  const _ResultMetric({
    required this.label,
    required this.value,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF93A2B8),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF070D22),
                fontWeight: FontWeight.w900,
              ),
              children: [
                TextSpan(text: value, style: const TextStyle(fontSize: 30)),
                TextSpan(
                  text: suffix == '%' ? suffix : ' $suffix',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF93A2B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBars extends StatelessWidget {
  final int streak;

  const _StreakBars({required this.streak});

  @override
  Widget build(BuildContext context) {
    final filled = math.min(7, streak);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (index) {
        return Container(
          width: 36,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          color: index < filled
              ? const Color(0xFF0D67FF)
              : Colors.grey.shade200,
        );
      }),
    );
  }
}

class _RewardPanel extends StatelessWidget {
  final LessonSubmitResultDto result;
  final double accuracy;

  const _RewardPanel({required this.result, required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final mastery = result.mastery;
    final masteryProgress = mastery == null
        ? (accuracy / 100).clamp(0.0, 1.0).toDouble()
        : (mastery.progressPercent / 100).clamp(0.0, 1.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF070D22),
                  ),
                ),
              ),
              Text(
                '+${result.xpEarned} XP',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF0D67FF),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  mastery == null
                      ? '${result.masteredWords} MASTERED'
                      : '${mastery.title} LV ${mastery.level}',
                  style: const TextStyle(
                    color: Color(0xFF93A2B8),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Text(
                '${(mastery?.progressPercent ?? accuracy).round()}%',
                style: const TextStyle(
                  color: Color(0xFF93A2B8),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: masteryProgress,
            minHeight: 6,
            color: const Color(0xFF0D67FF),
            backgroundColor: Colors.grey.shade100,
          ),
        ],
      ),
    );
  }
}
