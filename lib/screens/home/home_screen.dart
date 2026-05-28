import 'dart:async';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../routes/app_router.dart';
import '../../services/app_refresh_service.dart';
import '../../services/user_service.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final UserService _userService;
  _HomeData? _cachedData;
  bool _isLoading = true;
  Object? _error;
  late final VoidCallback _refreshListener;
  Timer? _dayChangeTimer;
  String? _loadedDayKey;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    WidgetsBinding.instance.addObserver(this);
    _refreshListener = () {
      if (!mounted) return;
      _reloadHomeData();
    };
    AppRefreshService.dashboardRefresh.addListener(_refreshListener);
    _loadHomeData();
    _scheduleDayChangeRefresh();
  }

  Future<void> _loadHomeData() async {
    _loadedDayKey = _dateKey(DateTime.now());
    _scheduleDayChangeRefresh();
    try {
      final dashboard = await _userService.fetchDashboard();
      final profile = await _userService.fetchProfile();
      if (!mounted) return;
      setState(() {
        _cachedData = _HomeData(dashboard: dashboard, profile: profile);
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e;
      });
    }
  }

  Future<void> _reloadHomeData() async {
    _loadedDayKey = _dateKey(DateTime.now());
    _scheduleDayChangeRefresh();
    try {
      final dashboard = await _userService.fetchDashboard();
      final profile = await _userService.fetchProfile();
      if (!mounted) return;
      setState(() {
        _cachedData = _HomeData(dashboard: dashboard, profile: profile);
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
      });
    }
  }

  Future<void> _refresh() async {
    await _reloadHomeData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final todayKey = _dateKey(DateTime.now());
    if (_loadedDayKey != todayKey) {
      _reloadHomeData();
    } else {
      _scheduleDayChangeRefresh();
    }
  }

  @override
  void dispose() {
    _dayChangeTimer?.cancel();
    AppRefreshService.dashboardRefresh.removeListener(_refreshListener);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _scheduleDayChangeRefresh() {
    _dayChangeTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _dayChangeTimer = Timer(
      nextDay.difference(now) + const Duration(seconds: 1),
      () {
        if (!mounted) return;
        _reloadHomeData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(const ExploreRoute());
        },
        backgroundColor: colorScheme.primary,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
      body: SafeArea(
        child: _isLoading && _cachedData == null
            ? const _HomeSkeleton()
            : _error != null && _cachedData == null
            ? _ErrorState(message: _error.toString(), onRetry: _refresh)
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final data = _cachedData!;
    final missionsLoading = _isLoading && _cachedData != null;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        children: [
          _DailyGoalCard(dashboard: data.dashboard),
          const SizedBox(height: 24),
          _SectionHeader(title: "TODAY'S MISSION", trailing: _todayLabel()),
          const SizedBox(height: 14),
          if (missionsLoading)
            ...List.generate(
              3,
              (i) => const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: _MissionSkeleton(),
              ),
            )
          else if (data.dashboard.missions.isEmpty)
            _EmptyPanel(
              title: 'No mission available',
              subtitle: 'No lessons were returned for today.',
            )
          else
            ...data.dashboard.missions.map(
              (mission) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _MissionCard(
                  mission: mission,
                  onTap: () {
                    if (mission.lessonId.isEmpty) return;
                    context.router.push(
                      QuizRoute(
                        lessonId: mission.lessonId,
                        lessonOrder: mission.lessonOrder,
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.speed,
                  value: _compactNumber(
                    data.dashboard.wordsMastered > 0
                        ? data.dashboard.wordsMastered
                        : data.profile.wordsMastered,
                  ),
                  label: 'WORDS MET',
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _MetricTile(
                  icon: Icons.local_fire_department,
                  value: data.dashboard.streak.toString(),
                  label: 'DAY STREAK',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final DashboardDto dashboard;

  const _DailyGoalCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final goalXp = math.max(1, dashboard.dailyGoalMinutes * 30);
    final todayXp = dashboard.dailyGoal.todayXp > 0
        ? dashboard.dailyGoal.todayXp
        : dashboard.todayXp;
    final progress = (todayXp / goalXp).clamp(0.0, 1.0).toDouble();
    final percent = (progress * 100).round();
    final completedUnits = dashboard.dailyGoal.targetLessons > 0
        ? dashboard.dailyGoal.completedLessons.toInt()
        : dashboard.missions.where((m) => m.isCompleted).length;
    final targetUnits = dashboard.dailyGoal.targetLessons > 0
        ? dashboard.dailyGoal.targetLessons
        : dashboard.missions.length;

    return _OutlinedPanel(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY GOAL',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percent% Complete',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$todayXp/$goalXp XP earned',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  '$completedUnits/$targetUnits',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              trailing,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(height: 1, color: colorScheme.outline),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  final DashboardMissionDto mission;
  final VoidCallback onTap;

  const _MissionCard({required this.mission, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalQuestions = math.max(1, mission.totalQuestions);
    final completedQuestions = mission.completedQuestions;
    final progress = mission.progressPercent > 0
        ? (mission.progressPercent / 100).clamp(0.0, 1.0).toDouble()
        : (completedQuestions / totalQuestions).clamp(0.0, 1.0).toDouble();
    final isPrimary = mission.category == 'Vocabulary';

    return InkWell(
      onTap: onTap,
      child: _OutlinedPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? colorScheme.primary
                        : colorScheme.surface,
                    border: isPrimary
                        ? null
                        : Border.all(color: colorScheme.onSurface),
                  ),
                  child: Icon(
                    isPrimary ? Icons.menu_book : Icons.school,
                    color: isPrimary
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  color: isPrimary
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceVariant,
                  child: Text(
                    (mission.label.isEmpty ? mission.category : mission.label)
                        .toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: isPrimary
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              mission.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mission.description.isEmpty
                  ? '${mission.level} lesson ${mission.lessonOrder} - ${mission.xpReward} XP'
                  : mission.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                height: 1.3,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceVariant,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$completedQuestions/$totalQuestions',
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return _OutlinedPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.onSurface, size: 20),
          const SizedBox(height: 14),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              height: 1,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
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

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      children: [
        _box(height: 24, margin: const EdgeInsets.only(top: 24, bottom: 28)),
        _box(height: 98),
        const SizedBox(height: 34),
        _box(height: 24, margin: const EdgeInsets.only(bottom: 22)),
        ...List.generate(3, (_) => const _MissionSkeleton()),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _box(
                height: 120,
                margin: const EdgeInsets.only(right: 18),
              ),
            ),
            Expanded(child: _box(height: 120)),
          ],
        ),
      ],
    );
  }

  Widget _box({double? height, EdgeInsetsGeometry? margin}) {
    return Container(
      width: double.infinity,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _MissionSkeleton extends StatelessWidget {
  const _MissionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 64, height: 64, color: Colors.grey.shade200),
              const Spacer(),
              Container(width: 80, height: 28, color: Colors.grey.shade200),
            ],
          ),
          const SizedBox(height: 28),
          Container(width: 200, height: 24, color: Colors.grey.shade200),
          const SizedBox(height: 8),
          Container(height: 18, color: Colors.grey.shade200),
          const SizedBox(height: 28),
          Container(height: 6, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}

class _HomeData {
  final DashboardDto dashboard;
  final UserProfileDto profile;

  _HomeData({required this.dashboard, required this.profile});
}

String _initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return 'LR';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _todayLabel() {
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  final now = DateTime.now();
  return '${months[now.month - 1]} ${now.day}';
}

String _compactNumber(int value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}m';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.toString();
}

String _dateKey(DateTime value) {
  return '${value.year}-${value.month}-${value.day}';
}
