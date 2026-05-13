import 'package:flutter/material.dart';
import '../../services/learning_service.dart';

class ResultScreen extends StatefulWidget {
  final LessonSubmitResultDto result;

  const ResultScreen({super.key, required this.result});

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
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
    final isPass = widget.result.accuracy >= 0.7;
    final accuracyPercentage = (widget.result.accuracy * 100).toStringAsFixed(
      1,
    );

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isPass
                    ? [
                        Colors.green.withOpacity(0.1),
                        Colors.blue.withOpacity(0.1),
                      ]
                    : [
                        Colors.red.withOpacity(0.1),
                        Colors.orange.withOpacity(0.1),
                      ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPass ? Colors.green : Colors.orange,
                    ),
                    child: Center(
                      child: Icon(
                        isPass ? Icons.check_rounded : Icons.close_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Text(
                    isPass ? 'Great Job!' : 'Try Again',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Text(
                    isPass
                        ? 'You passed this lesson!'
                        : 'Keep practicing to improve!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 32),
                _buildResultCard(context, accuracyPercentage),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).popUntil((route) {
                              return route.isFirst;
                            });
                          },
                          child: const Text('Back to Home'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.result.nextLesson != null)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to next lesson
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next Lesson'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, String accuracyPercentage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildResultRow(
            context,
            'Accuracy',
            '$accuracyPercentage%',
            Icons.tablet,
          ),
          const Divider(height: 20),
          _buildResultRow(
            context,
            'XP Earned',
            '+${widget.result.xpEarned}',
            Icons.star,
            color: Colors.amber,
          ),
          const Divider(height: 20),
          _buildResultRow(
            context,
            'Total XP',
            widget.result.newTotalXp.toString(),
            Icons.trending_up,
            color: Colors.green,
          ),
          const Divider(height: 20),
          _buildResultRow(
            context,
            'Status',
            widget.result.isCompleted ? 'Completed' : 'Incomplete',
            Icons.flag,
            color: widget.result.isCompleted ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color color = Colors.blue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
