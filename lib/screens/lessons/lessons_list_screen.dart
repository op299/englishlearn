import 'package:flutter/material.dart';
import '../../services/learning_service.dart';
import 'quiz_screen.dart';

class LessonsListScreen extends StatefulWidget {
  final String topicId;
  final String topicTitle;

  const LessonsListScreen({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  State<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  late final LearningService _learningService;
  late Future<List<LessonDto>> _lessonsFuture;

  @override
  void initState() {
    super.initState();
    _learningService = LearningService();
    _lessonsFuture = _learningService.fetchLessonsByTopic(widget.topicId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicTitle), elevation: 0),
      body: FutureBuilder<List<LessonDto>>(
        future: _lessonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _lessonsFuture = _learningService.fetchLessonsByTopic(
                        widget.topicId,
                      );
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final lessons = snapshot.data ?? [];

          if (lessons.isEmpty) {
            return const Center(child: Text('No lessons available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return _buildLessonCard(context, lesson);
            },
          );
        },
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, LessonDto lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: lesson.completed
                ? Colors.green.withOpacity(0.2)
                : Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              'L${lesson.order}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        title: Text('Lesson ${lesson.order}'),
        subtitle: Row(
          children: [
            Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text('${lesson.xpReward} XP'),
            const SizedBox(width: 16),
            if (lesson.completed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  QuizScreen(lessonId: lesson.id, lessonOrder: lesson.order),
            ),
          );
        },
      ),
    );
  }
}
