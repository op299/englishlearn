import 'package:flutter/material.dart';
import '../../services/learning_service.dart';
import '../lessons/lessons_list_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final LearningService _learningService;
  late Future<List<TopicDto>> _topicsFuture;
  String? _selectedLevel;

  // Map display labels to CEFR levels
  final Map<String, String> levelMapping = {
    'All': '',
    'Beginner': 'A1',
    'Intermediate': 'B1',
    'Advanced': 'C1',
  };

  @override
  void initState() {
    super.initState();
    _learningService = LearningService();
    _topicsFuture = _learningService.fetchTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search vocabulary...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Filter by Level',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Beginner', 'Intermediate', 'Advanced'].map(
                    (level) {
                      final isSelected =
                          _selectedLevel == null && level == 'All' ||
                          _selectedLevel == levelMapping[level];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(level),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedLevel = level == 'All'
                                  ? null
                                  : levelMapping[level];
                              _topicsFuture = _learningService.fetchTopics(
                                level: _selectedLevel,
                              );
                            });
                          },
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Available Topics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<TopicDto>>(
                future: _topicsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => setState(() {
                              _topicsFuture = _learningService.fetchTopics(
                                level: _selectedLevel,
                              );
                            }),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final topics = snapshot.data ?? [];

                  if (topics.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('No topics available'),
                      ),
                    );
                  }

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: topics
                        .map((topic) => _buildTopicCard(context, topic))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, TopicDto topic) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  LessonsListScreen(topicId: topic.id, topicTitle: topic.title),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.book, size: 28, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                topic.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              topic.level,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
