import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../routes/app_router.dart';
import '../../services/app_refresh_service.dart';
import '../../services/user_service.dart';
import '../lessons/review_mistakes_screen.dart';

@RoutePage()
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final UserService _userService;
  late Future<_ProgressData> _progressFuture;
  late final VoidCallback _refreshListener;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _refreshListener = () {
      if (!mounted) return;
      _reloadProgressData();
    };
    AppRefreshService.progressRefresh.addListener(_refreshListener);
    _progressFuture = _loadProgressData();
  }

  Future<_ProgressData> _loadProgressData() async {
    final profileFuture = _userService.fetchProfile();
    final summaryFuture = _userService.fetchProgressSummary();
    final reviewFuture = _userService.fetchReviewLessons();

    final review = await reviewFuture;

    return _ProgressData(
      profile: await profileFuture,
      summary: await summaryFuture,
      reviewItems: review.lessons
          .take(4)
          .map((lesson) => _ReviewItem(lesson))
          .toList(),
      reviewTotal: review.total,
    );
  }

  Future<void> _refresh() async {
    _reloadProgressData();
    await _progressFuture;
  }

  void _reloadProgressData() {
    setState(() {
      _progressFuture = _loadProgressData();
    });
  }

  @override
  void dispose() {
    AppRefreshService.progressRefresh.removeListener(_refreshListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FutureBuilder<_ProgressData>(
          future: _progressFuture,
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

            final data = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'WORDS MASTERED',
                    style: TextStyle(
                      letterSpacing: 3,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          _formatNumber(data.summary.wordsMastered),
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                height: 0.9,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+${data.summary.wordsMasteredSinceYesterday} since yesterday',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ActivityPanel(summary: data.summary, profile: data.profile),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.bolt,
                          value: data.summary.streak.toString(),
                          label: 'DAY STREAK',
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.track_changes,
                          value: '${data.summary.accuracy.round()}%',
                          label: 'MASTERY',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'REVIEW QUEUE',
                          style: TextStyle(
                            letterSpacing: 3,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReviewMistakesScreen(),
                            ),
                          );
                        },
                        child: Text(
                          '${data.reviewTotal}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (data.reviewItems.isEmpty)
                    const _EmptyPanel(
                      title: 'No review lessons',
                      subtitle: 'Lessons below 70% accuracy will appear here.',
                    )
                  else
                    _ReviewList(items: data.reviewItems),
                  if (data.summary.recentMilestones.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'MILESTONES',
                      style: TextStyle(
                        letterSpacing: 3,
                        fontSize: 13,
                        color: Color(0xFF55555B),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MilestoneList(items: data.summary.recentMilestones),
                  ],
                  const SizedBox(height: 28),
                  _DailyGoalPanel(summary: data.summary),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  final ProgressSummaryDto summary;
  final UserProfileDto profile;

  const _ActivityPanel({required this.summary, required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tier = _tierProgress(profile.totalXp);
    final activity = summary.activity.take(7).toList();
    return _OutlinedPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Activity',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                (summary.ranking.isEmpty ? profile.tier : summary.ranking)
                    .toUpperCase(),
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _ActivityNumber(label: "TODAY'S XP", value: summary.todayXp),
              const SizedBox(width: 20),
              _ActivityNumber(label: 'TOTAL XP', value: profile.totalXp),
            ],
          ),
          if (activity.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: activity
                  .map((day) => _ActivityBar(day: day, maxXp: _maxXp(activity)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: tier.progress,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceVariant,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            tier.label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityNumber extends StatelessWidget {
  final String label;
  final int value;

  const _ActivityNumber({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatNumber(value),
            style: textTheme.displaySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityBar extends StatelessWidget {
  final ActivityDayDto day;
  final int maxXp;

  const _ActivityBar({required this.day, required this.maxXp});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final height = maxXp <= 0 ? 8.0 : 8 + (day.xp / maxXp * 52);
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 18,
            height: height,
            color: day.xp > 0
                ? colorScheme.primary
                : colorScheme.surfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            day.weekday.isEmpty ? '-' : day.weekday.substring(0, 1),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return _OutlinedPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 26),
          const SizedBox(height: 16),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              height: 1,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  final List<_ReviewItem> items;

  const _ReviewList({required this.items});

  @override
  Widget build(BuildContext context) {
    return _OutlinedPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _ReviewRow(item: items[i]),
            if (i != items.length - 1)
              Divider(height: 1, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final _ReviewItem item;

  const _ReviewRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final title = item.review.topicTitle.isNotEmpty
        ? item.review.topicTitle
        : item.review.lessonId;
    final order = item.review.lessonOrder;

    return InkWell(
      onTap: () {
        context.router.push(
          QuizRoute(
            lessonId: item.review.lessonId,
            lessonOrder: math.max(1, order),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(width: 10, height: 10, color: colorScheme.primary),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order > 0 ? '$title - Lesson $order' : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.review.accuracy.round()}% accuracy',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _MilestoneList extends StatelessWidget {
  final List<MilestoneDto> items;

  const _MilestoneList({required this.items});

  @override
  Widget build(BuildContext context) {
    return _OutlinedPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _MilestoneRow(item: items[i]),
            if (i != items.length - 1)
              Divider(height: 1, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  final MilestoneDto item;

  const _MilestoneRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            item.isHighlighted ? Icons.workspace_premium : Icons.check_circle,
            color: colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

class _DailyGoalPanel extends StatelessWidget {
  final ProgressSummaryDto summary;

  const _DailyGoalPanel({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final goalXp = math.max(1, summary.dailyGoalMinutes * 30);
    final progress = (summary.todayXp / goalXp).clamp(0.0, 1.0).toDouble();
    return _OutlinedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Daily Goal',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                '${summary.todayXp} / $goalXp XP',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            '${summary.todayCompletedLessons} / ${math.max(1, summary.dailyGoalTargetLessons)} lessons completed',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _OutlinedPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyPanel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return _OutlinedPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _ProgressData {
  final UserProfileDto profile;
  final ProgressSummaryDto summary;
  final List<_ReviewItem> reviewItems;
  final int reviewTotal;

  _ProgressData({
    required this.profile,
    required this.summary,
    required this.reviewItems,
    required this.reviewTotal,
  });
}

class _ReviewItem {
  final ReviewLessonDto review;

  _ReviewItem(this.review);
}

class _TierProgress {
  final double progress;
  final String label;

  _TierProgress({required this.progress, required this.label});
}

_TierProgress _tierProgress(int totalXp) {
  if (totalXp >= 15000) {
    return _TierProgress(progress: 1, label: 'Advanced tier reached');
  }

  final floor = totalXp < 5000 ? 0 : 5000;
  final next = totalXp < 5000 ? 5000 : 15000;
  final progress = ((totalXp - floor) / (next - floor))
      .clamp(0.0, 1.0)
      .toDouble();
  return _TierProgress(
    progress: progress,
    label: '${next - totalXp} XP to next tier',
  );
}

int _maxXp(List<ActivityDayDto> activity) {
  var maxXp = 0;
  for (final day in activity) {
    if (day.xp > maxXp) maxXp = day.xp;
  }
  return maxXp;
}

String _initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return 'LR';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _formatNumber(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final fromEnd = text.length - i;
    buffer.write(text[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
  }
  return buffer.toString();
}
