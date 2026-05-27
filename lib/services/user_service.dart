import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'auth_service.dart';

class UserService {
  final AuthService _authService;

  UserService({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<DashboardDto> fetchDashboard() async {
    final response = await _authService.sendAuthenticatedRequest(
      (headers) =>
          http.get(Uri.parse(ApiService.dashboardEndpoint), headers: headers),
    );

    if (response.statusCode != 200) {
      throw _handleError(response, 'Failed to load dashboard');
    }

    return DashboardDto.fromJson(jsonDecode(response.body));
  }

  Future<UserProfileDto> fetchProfile() async {
    final response = await _authService.sendAuthenticatedRequest(
      (headers) =>
          http.get(Uri.parse(ApiService.profileEndpoint), headers: headers),
    );

    if (response.statusCode != 200) {
      throw _handleError(response, 'Failed to load profile');
    }

    return UserProfileDto.fromJson(jsonDecode(response.body));
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? currentLevel,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;
    if (currentLevel != null) body['current_level'] = currentLevel;

    if (body.isEmpty) return;

    final response = await _authService.sendAuthenticatedRequest(
      (headers) => http.patch(
        Uri.parse(ApiService.profileEndpoint),
        headers: headers,
        body: jsonEncode(body),
      ),
    );

    if (response.statusCode != 200) {
      throw _handleError(response, 'Failed to update profile');
    }
  }

  Future<void> updateSettings({
    int? dailyGoalMinutes,
    String? theme,
    bool? highContrastBorders,
    bool? notificationsEnabled,
    String? currentLevel,
  }) async {
    final body = <String, dynamic>{};
    if (dailyGoalMinutes != null) {
      body['daily_goal_minutes'] = dailyGoalMinutes;
    }
    if (theme != null) {
      body['theme'] = theme;
    }
    if (highContrastBorders != null) {
      body['high_contrast_borders'] = highContrastBorders;
    }
    if (notificationsEnabled != null) {
      body['notifications_enabled'] = notificationsEnabled;
    }
    if (currentLevel != null) {
      body['current_level'] = currentLevel;
    }
    if (body.isEmpty) return;

    final response = await _authService.sendAuthenticatedRequest(
      (headers) => http.patch(
        Uri.parse(ApiService.settingsEndpoint),
        headers: headers,
        body: jsonEncode(body),
      ),
    );

    if (response.statusCode != 200) {
      throw _handleError(response, 'Failed to update settings');
    }
  }

  Future<ReviewListDto> fetchReviewLessons() async {
    final response = await _authService.sendAuthenticatedRequest(
      (headers) =>
          http.get(Uri.parse(ApiService.reviewEndpoint), headers: headers),
    );

    if (response.statusCode != 200) {
      throw _handleError(response, 'Failed to load review lessons');
    }

    return ReviewListDto.fromJson(jsonDecode(response.body));
  }

  Future<ProgressSummaryDto> fetchProgressSummary() async {
    final response = await _authService.sendAuthenticatedRequest(
      (headers) => http.get(
        Uri.parse(ApiService.progressSummaryEndpoint),
        headers: headers,
      ),
    );

    if (response.statusCode != 200) {
      throw _handleError(response, 'Failed to load progress summary');
    }

    return ProgressSummaryDto.fromJson(jsonDecode(response.body));
  }

  Future<ReviewMistakeListDto> fetchReviewMistakes({int limit = 50}) async {
    final uri = Uri.parse(
      ApiService.reviewMistakesEndpoint,
    ).replace(queryParameters: {'limit': limit.toString()});
    final response = await _authService.sendAuthenticatedRequest(
      (headers) => http.get(uri, headers: headers),
    );

    if (response.statusCode != 200) {
      throw _handleError(response, 'Failed to load review mistakes');
    }

    return ReviewMistakeListDto.fromJson(jsonDecode(response.body));
  }

  Exception _handleError(http.Response response, String fallback) {
    try {
      final errorBody = jsonDecode(response.body);
      final detail = errorBody['detail'];
      if (detail != null) return Exception(detail.toString());
    } catch (_) {}

    return Exception('$fallback: ${response.statusCode}');
  }
}

class DashboardDto {
  final int streak;
  final int todayXp;
  final int totalXp;
  final int dailyGoalMinutes;
  final String tier;
  final String? message;
  final int wordsMastered;
  final double accuracy;
  final int retentionRate;
  final DashboardDailyGoalDto dailyGoal;
  final List<DashboardMissionDto> missions;

  DashboardDto({
    required this.streak,
    required this.todayXp,
    required this.totalXp,
    required this.dailyGoalMinutes,
    required this.tier,
    this.message,
    required this.wordsMastered,
    required this.accuracy,
    required this.retentionRate,
    required this.dailyGoal,
    required this.missions,
  });

  factory DashboardDto.fromJson(Map<String, dynamic> json) {
    final dailyGoalJson = json['daily_goal'] is Map
        ? (json['daily_goal'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    final dailyGoalMinutes = _asInt(
      json['daily_goal_minutes'] ?? dailyGoalJson['minutes'],
    );
    final fallbackGoal = DashboardDailyGoalDto(
      minutes: dailyGoalMinutes,
      targetXp: dailyGoalMinutes * 30,
      todayXp: _asInt(json['today_xp']),
      percent: 0,
      completedLessons: 0,
      targetLessons: 0,
    );
    final missionsJson = (json['missions'] as List?) ?? [];
    return DashboardDto(
      streak: _asInt(json['streak']),
      todayXp: _asInt(json['today_xp']),
      totalXp: _asInt(json['total_xp']),
      dailyGoalMinutes: dailyGoalMinutes,
      tier: (json['tier'] ?? '').toString(),
      message: json['message']?.toString(),
      wordsMastered: _asInt(json['words_mastered']),
      accuracy: _asDouble(json['accuracy']),
      retentionRate: _asInt(json['retention_rate']),
      dailyGoal: dailyGoalJson.isNotEmpty
          ? DashboardDailyGoalDto.fromJson(dailyGoalJson)
          : fallbackGoal,
      missions: missionsJson
          .map(
            (mission) =>
                DashboardMissionDto.fromJson(mission as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class DashboardDailyGoalDto {
  final int minutes;
  final int targetXp;
  final int todayXp;
  final double percent;
  final int completedLessons;
  final int targetLessons;

  DashboardDailyGoalDto({
    required this.minutes,
    required this.targetXp,
    required this.todayXp,
    required this.percent,
    required this.completedLessons,
    required this.targetLessons,
  });

  factory DashboardDailyGoalDto.fromJson(Map<String, dynamic> json) {
    final minutes = _asInt(json['minutes']);
    final todayXp = _asInt(json['today_xp']);
    return DashboardDailyGoalDto(
      minutes: minutes,
      targetXp: minutes * 30,
      todayXp: todayXp,
      percent: _asDouble(json['percent']),
      completedLessons: _asInt(json['completed_lessons']),
      targetLessons: _asInt(json['target_lessons']),
    );
  }
}

class DashboardMissionDto {
  final String lessonId;
  final String topicId;
  final String title;
  final String description;
  final String category;
  final String level;
  final int lessonOrder;
  final int xpReward;
  final int completedQuestions;
  final int totalQuestions;
  final double progressPercent;
  final bool isCompleted;
  final String label;

  DashboardMissionDto({
    required this.lessonId,
    required this.topicId,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.lessonOrder,
    required this.xpReward,
    required this.completedQuestions,
    required this.totalQuestions,
    required this.progressPercent,
    required this.isCompleted,
    required this.label,
  });

  factory DashboardMissionDto.fromJson(Map<String, dynamic> json) {
    return DashboardMissionDto(
      lessonId: (json['lesson_id'] ?? '').toString(),
      topicId: (json['topic_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      lessonOrder: _asInt(json['lesson_order']),
      xpReward: _asInt(json['xp_reward']),
      completedQuestions: _asInt(json['completed_questions']),
      totalQuestions: _asInt(json['total_questions']),
      progressPercent: _asDouble(json['progress_percent']),
      isCompleted: json['is_completed'] == true,
      label: (json['label'] ?? '').toString(),
    );
  }
}

class UserProfileDto {
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String currentLevel;
  final int totalXp;
  final int streak;
  final int wordsMastered;
  final int totalWords;
  final double masteryRatio;
  final String tier;

  UserProfileDto({
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.currentLevel,
    required this.totalXp,
    required this.streak,
    required this.wordsMastered,
    required this.totalWords,
    required this.masteryRatio,
    required this.tier,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      email: (json['email'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      avatarUrl: json['avatar_url']?.toString(),
      currentLevel: (json['current_level'] ?? 'A1').toString(),
      totalXp: _asInt(json['total_xp']),
      streak: _asInt(json['streak']),
      wordsMastered: _asInt(json['words_mastered']),
      totalWords: _asInt(json['total_words']),
      masteryRatio: _asDouble(json['mastery_ratio']),
      tier: (json['tier'] ?? '').toString(),
    );
  }
}

class ReviewListDto {
  final int total;
  final List<ReviewLessonDto> lessons;

  ReviewListDto({required this.total, required this.lessons});

  factory ReviewListDto.fromJson(Map<String, dynamic> json) {
    final lessonsJson = (json['lessons'] as List?) ?? [];
    return ReviewListDto(
      total: _asInt(json['total']),
      lessons: lessonsJson
          .map(
            (lesson) =>
                ReviewLessonDto.fromJson(lesson as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class ReviewLessonDto {
  final String lessonId;
  final String topicTitle;
  final int lessonOrder;
  final int xpReward;
  final double accuracy;
  final bool needsReview;

  ReviewLessonDto({
    required this.lessonId,
    required this.topicTitle,
    required this.lessonOrder,
    required this.xpReward,
    required this.accuracy,
    required this.needsReview,
  });

  factory ReviewLessonDto.fromJson(Map<String, dynamic> json) {
    return ReviewLessonDto(
      lessonId: (json['lesson_id'] ?? '').toString(),
      topicTitle: (json['topic_title'] ?? '').toString(),
      lessonOrder: _asInt(json['lesson_order']),
      xpReward: _asInt(json['xp_reward']),
      accuracy: _asDouble(json['accuracy']),
      needsReview: json['needs_review'] == true,
    );
  }
}

class ProgressSummaryDto {
  final int wordsMastered;
  final int wordsMasteredSinceYesterday;
  final List<ActivityDayDto> activity;
  final int streak;
  final double accuracy;
  final int retentionRate;
  final List<MilestoneDto> recentMilestones;
  final int dailyGoalMinutes;
  final int dailyGoalXp;
  final int todayXp;
  final double dailyGoalPercent;
  final int todayCompletedLessons;
  final int dailyGoalTargetLessons;
  final String ranking;

  ProgressSummaryDto({
    required this.wordsMastered,
    required this.wordsMasteredSinceYesterday,
    required this.activity,
    required this.streak,
    required this.accuracy,
    required this.retentionRate,
    required this.recentMilestones,
    required this.dailyGoalMinutes,
    required this.dailyGoalXp,
    required this.todayXp,
    required this.dailyGoalPercent,
    required this.todayCompletedLessons,
    required this.dailyGoalTargetLessons,
    required this.ranking,
  });

  factory ProgressSummaryDto.fromJson(Map<String, dynamic> json) {
    final activityJson = (json['activity'] as List?) ?? [];
    final milestonesJson = (json['recent_milestones'] as List?) ?? [];
    return ProgressSummaryDto(
      wordsMastered: _asInt(json['words_mastered']),
      wordsMasteredSinceYesterday: _asInt(
        json['words_mastered_since_yesterday'],
      ),
      activity: activityJson
          .map((day) => ActivityDayDto.fromJson(day as Map<String, dynamic>))
          .toList(),
      streak: _asInt(json['streak']),
      accuracy: _asDouble(json['accuracy']),
      retentionRate: _asInt(json['retention_rate']),
      recentMilestones: milestonesJson
          .map(
            (milestone) =>
                MilestoneDto.fromJson(milestone as Map<String, dynamic>),
          )
          .toList(),
      dailyGoalMinutes: _asInt(json['daily_goal_minutes']),
      dailyGoalXp: _asInt(json['daily_goal_xp']),
      todayXp: _asInt(json['today_xp']),
      dailyGoalPercent: _asDouble(json['daily_goal_percent']),
      todayCompletedLessons: _asInt(json['today_completed_lessons']),
      dailyGoalTargetLessons: _asInt(json['daily_goal_target_lessons']),
      ranking: (json['ranking'] ?? '').toString(),
    );
  }
}

class ActivityDayDto {
  final String date;
  final String weekday;
  final int completedLessons;
  final int xp;
  final int minutes;

  ActivityDayDto({
    required this.date,
    required this.weekday,
    required this.completedLessons,
    required this.xp,
    required this.minutes,
  });

  factory ActivityDayDto.fromJson(Map<String, dynamic> json) {
    return ActivityDayDto(
      date: (json['date'] ?? '').toString(),
      weekday: (json['weekday'] ?? '').toString(),
      completedLessons: _asInt(json['completed_lessons']),
      xp: _asInt(json['xp']),
      minutes: _asInt(json['minutes']),
    );
  }
}

class MilestoneDto {
  final String title;
  final String description;
  final String occurredAt;
  final bool isHighlighted;

  MilestoneDto({
    required this.title,
    required this.description,
    required this.occurredAt,
    required this.isHighlighted,
  });

  factory MilestoneDto.fromJson(Map<String, dynamic> json) {
    return MilestoneDto(
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      occurredAt: (json['occurred_at'] ?? '').toString(),
      isHighlighted: json['is_highlighted'] == true,
    );
  }
}

class ReviewMistakeListDto {
  final int total;
  final List<ReviewMistakeDto> mistakes;

  ReviewMistakeListDto({required this.total, required this.mistakes});

  factory ReviewMistakeListDto.fromJson(Map<String, dynamic> json) {
    final mistakesJson = (json['mistakes'] as List?) ?? [];
    return ReviewMistakeListDto(
      total: _asInt(json['total']),
      mistakes: mistakesJson
          .map(
            (mistake) =>
                ReviewMistakeDto.fromJson(mistake as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class ReviewMistakeDto {
  final String questionId;
  final String lessonId;
  final String topicTitle;
  final int lessonOrder;
  final String word;
  final String contextSentence;
  final String selectedAnswer;
  final String correctAnswer;
  final List<String> distractors;
  final String answeredAt;

  ReviewMistakeDto({
    required this.questionId,
    required this.lessonId,
    required this.topicTitle,
    required this.lessonOrder,
    required this.word,
    required this.contextSentence,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.distractors,
    required this.answeredAt,
  });

  factory ReviewMistakeDto.fromJson(Map<String, dynamic> json) {
    final distractorsJson = (json['distractors'] as List?) ?? [];
    return ReviewMistakeDto(
      questionId: (json['question_id'] ?? '').toString(),
      lessonId: (json['lesson_id'] ?? '').toString(),
      topicTitle: (json['topic_title'] ?? '').toString(),
      lessonOrder: _asInt(json['lesson_order']),
      word: (json['word'] ?? '').toString(),
      contextSentence: (json['context_sentence'] ?? '').toString(),
      selectedAnswer: (json['selected_answer'] ?? '').toString(),
      correctAnswer: (json['correct_answer'] ?? '').toString(),
      distractors: distractorsJson.map((item) => item.toString()).toList(),
      answeredAt: (json['answered_at'] ?? '').toString(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
