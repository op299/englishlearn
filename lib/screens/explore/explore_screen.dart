import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../routes/app_router.dart';
import '../../services/learning_service.dart';

@RoutePage()
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  late final LearningService _learningService;
  late Future<ExploreDto> _exploreFuture;
  Timer? _searchDebounce;
  String? _selectedLevel;

  final List<String> _levels = ['All', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void initState() {
    super.initState();
    _learningService = LearningService();
    _exploreFuture = _loadExplore();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<ExploreDto> _loadExplore() {
    return _learningService.fetchExplore(
      query: _searchController.text,
      level: _selectedLevel,
    );
  }

  void _reloadExplore() {
    setState(() {
      _exploreFuture = _loadExplore();
    });
  }

  void _queueSearch() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), _reloadExplore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          _reloadExplore();
          await _exploreFuture;
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => _queueSearch(),
              decoration: InputDecoration(
                hintText: 'Search vocabulary, grammar, business...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _reloadExplore();
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _levels.map((level) {
                  final selected =
                      (level == 'All' && _selectedLevel == null) ||
                      _selectedLevel == level;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(level),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedLevel = level == 'All' ? null : level;
                          _exploreFuture = _loadExplore();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<ExploreDto>(
              future: _exploreFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return _ErrorPanel(
                    message: snapshot.error.toString(),
                    onRetry: _reloadExplore,
                  );
                }

                final data = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ExploreStats(stats: data.stats, total: data.total),
                    const SizedBox(height: 16),
                    _TopicSection(
                      title: 'Vocabulary',
                      topics: data.vocabularyTopics,
                    ),
                    const SizedBox(height: 16),
                    _TopicSection(title: 'Grammar', topics: data.grammarTopics),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreStats extends StatelessWidget {
  final ExploreStatsDto stats;
  final int total;

  const _ExploreStats({required this.stats, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(label: 'TOPICS', value: total.toString()),
        const SizedBox(width: 10),
        _StatChip(label: 'RETENTION', value: '${stats.retentionRate}%'),
        const SizedBox(width: 10),
        _StatChip(
          label: 'GOAL',
          value:
              '${stats.dailyGoalCompleted}/${stats.dailyGoalTarget == 0 ? 3 : stats.dailyGoalTarget}',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicSection extends StatelessWidget {
  final String title;
  final List<TopicDto> topics;

  const _TopicSection({required this.title, required this.topics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        if (topics.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No topics available')),
          )
        else
          GridView.builder(
            itemCount: topics.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              return _TopicCard(topic: topics[index]);
            },
          ),
      ],
    );
  }
}

class _TopicCard extends StatelessWidget {
  final TopicDto topic;

  const _TopicCard({required this.topic});

  @override
  Widget build(BuildContext context) {
    final progress = (topic.progressPercent / 100).clamp(0.0, 1.0).toDouble();
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () {
          context.router.push(
            LessonsListRoute(topicId: topic.id, topicTitle: topic.title),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    topic.category == 'Grammar'
                        ? Icons.school_outlined
                        : Icons.menu_book_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  const Spacer(),
                  Text(
                    topic.level,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                topic.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${topic.completedLessons}/${topic.lessonCount} lessons',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
