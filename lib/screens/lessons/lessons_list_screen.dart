import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../routes/app_router.dart';
import '../../services/learning_service.dart';

@RoutePage()
class LessonsListScreen extends StatefulWidget {
  @PathParam('topicId')
  final String topicId;
  @PathParam('topicTitle')
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
                  const Icon(Icons.error_outline, size: 48, color: null),
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
                ? Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.2)
                : Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.2),
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
            Icon(
              Icons.star,
              size: 16,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 4),
            Text('${lesson.xpReward} XP'),
            const SizedBox(width: 16),
            if (lesson.completed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
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
          context.router.push(
            QuizRoute(lessonId: lesson.id, lessonOrder: lesson.order),
          );
        },
      ),
    );
  }
}
