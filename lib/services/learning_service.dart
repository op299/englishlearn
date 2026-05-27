import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'auth_service.dart';

class LearningService {
  final AuthService _authService;

  LearningService({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<ExploreDto> fetchExplore({String? query, String? level}) async {
    final queryParameters = <String, String>{};
    if (query != null && query.trim().isNotEmpty) {
      queryParameters['q'] = query.trim();
    }
    if (level != null && level.isNotEmpty) {
      queryParameters['level'] = level;
    }

    final uri = Uri.parse(ApiService.learningExploreEndpoint).replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final response = await _authService.sendAuthenticatedRequest(
      (headers) => http.get(uri, headers: headers),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load explore: ${response.statusCode}');
    }

    return ExploreDto.fromJson(jsonDecode(response.body));
  }

  Future<List<TopicDto>> fetchTopics({
    String? level,
    String? category,
    String? query,
  }) async {
    final queryParameters = <String, String>{};
    if (level != null && level.isNotEmpty) queryParameters['level'] = level;
    if (category != null && category.isNotEmpty) {
      queryParameters['category'] = category;
    }
    if (query != null && query.trim().isNotEmpty) {
      queryParameters['q'] = query.trim();
    }

    final uri = Uri.parse(ApiService.learningTopicsEndpoint).replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    final response = await _authService.sendAuthenticatedRequest(
      (headers) => http.get(uri, headers: headers),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load topics: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final list = (body['topics'] as List?) ?? [];
    return list
        .map((topic) => TopicDto.fromJson(topic as Map<String, dynamic>))
        .toList();
  }

  Future<List<LessonDto>> fetchLessonsByTopic(String topicId) async {
    final uri = Uri.parse(
      ApiService.learningLessonsByTopicEndpoint.replaceAll(
        '{topic_id}',
        topicId,
      ),
    );

    final response = await _authService.sendAuthenticatedRequest(
      (headers) => http.get(uri, headers: headers),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load lessons: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final list = (body['lessons'] as List?) ?? [];
    return list
        .map((lesson) => LessonDto.fromJson(lesson as Map<String, dynamic>))
        .toList();
  }

  Future<LessonDetailDto> fetchLessonDetail(String lessonId) async {
    final uri = Uri.parse(
      ApiService.learningLessonDetailEndpoint.replaceAll(
        '{lesson_id}',
        lessonId,
      ),
    );

    final response = await _authService.sendAuthenticatedRequest(
      (headers) => http.get(uri, headers: headers),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load lesson detail: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    return LessonDetailDto.fromJson(body);
  }

  Future<LessonSubmitResultDto> submitLesson({
    required String lessonId,
    required List<AnswerPayloadDto> answers,
    required int timeSpentSeconds,
    required double accuracy,
  }) async {
    final uri = Uri.parse(
      ApiService.lessonSubmitEndpoint.replaceAll('{lesson_id}', lessonId),
    );

    final requestBody = <String, dynamic>{
      'accuracy': accuracy,
      'time_spent': timeSpentSeconds,
    };
    if (answers.isNotEmpty) {
      requestBody['answers'] = answers.map((answer) => answer.toJson()).toList();
    }

    final response = await _authService.sendAuthenticatedRequest(
      (headers) =>
          http.post(uri, headers: headers, body: jsonEncode(requestBody)),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to submit lesson: ${response.statusCode} - ${response.body}',
      );
    }

    final body = jsonDecode(response.body);
    return LessonSubmitResultDto.fromJson(body);
  }
}

class ExploreDto {
  final List<TopicDto> vocabularyTopics;
  final List<TopicDto> grammarTopics;
  final ExploreStatsDto stats;
  final int total;

  ExploreDto({
    required this.vocabularyTopics,
    required this.grammarTopics,
    required this.stats,
    required this.total,
  });

  factory ExploreDto.fromJson(Map<String, dynamic> json) {
    final vocabulary = (json['vocabulary_topics'] as List?) ?? [];
    final grammar = (json['grammar_topics'] as List?) ?? [];
    return ExploreDto(
      vocabularyTopics: vocabulary
          .map((topic) => TopicDto.fromJson(topic as Map<String, dynamic>))
          .toList(),
      grammarTopics: grammar
          .map((topic) => TopicDto.fromJson(topic as Map<String, dynamic>))
          .toList(),
      stats: ExploreStatsDto.fromJson(
        (json['stats'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      total: _asInt(json['total']),
    );
  }

  List<TopicDto> get allTopics => [...vocabularyTopics, ...grammarTopics];
}

class ExploreStatsDto {
  final int retentionRate;
  final int dailyGoalMinutes;
  final int dailyGoalCompleted;
  final int dailyGoalTarget;

  ExploreStatsDto({
    required this.retentionRate,
    required this.dailyGoalMinutes,
    required this.dailyGoalCompleted,
    required this.dailyGoalTarget,
  });

  factory ExploreStatsDto.fromJson(Map<String, dynamic> json) {
    return ExploreStatsDto(
      retentionRate: _asInt(json['retention_rate']),
      dailyGoalMinutes: _asInt(json['daily_goal_minutes']),
      dailyGoalCompleted: _asInt(json['daily_goal_completed']),
      dailyGoalTarget: _asInt(json['daily_goal_target']),
    );
  }
}

class TopicDto {
  final String id;
  final String title;
  final String level;
  final String category;
  final int lessonCount;
  final int completedLessons;
  final double progressPercent;

  TopicDto({
    required this.id,
    required this.title,
    required this.level,
    required this.category,
    required this.lessonCount,
    this.completedLessons = 0,
    this.progressPercent = 0,
  });

  factory TopicDto.fromJson(Map<String, dynamic> json) {
    return TopicDto(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      lessonCount: _asInt(json['lesson_count']),
      completedLessons: _asInt(json['completed_lessons']),
      progressPercent: _asDouble(json['progress_percent']),
    );
  }
}

class LessonDto {
  final String id;
  final String topicId;
  final int order;
  final int xpReward;
  final bool completed;

  LessonDto({
    required this.id,
    required this.topicId,
    required this.order,
    required this.xpReward,
    required this.completed,
  });

  factory LessonDto.fromJson(Map<String, dynamic> json) {
    return LessonDto(
      id: (json['id'] ?? '').toString(),
      topicId: (json['topic_id'] ?? '').toString(),
      order: _asInt(json['order']),
      xpReward: _asInt(json['xp_reward']),
      completed: (json['completed'] ?? false) as bool,
    );
  }
}

class LessonDetailDto {
  final String id;
  final String topicId;
  final String topicTitle;
  final int order;
  final int xpReward;
  final List<QuestionDto> questions;

  LessonDetailDto({
    required this.id,
    required this.topicId,
    required this.topicTitle,
    required this.order,
    required this.xpReward,
    required this.questions,
  });

  factory LessonDetailDto.fromJson(Map<String, dynamic> json) {
    final questionsJson = (json['questions'] as List?) ?? [];
    return LessonDetailDto(
      id: (json['id'] ?? json['lesson_id'] ?? '').toString(),
      topicId: (json['topic_id'] ?? '').toString(),
      topicTitle: (json['topic_title'] ?? '').toString(),
      order: _asInt(json['order']),
      xpReward: _asInt(json['xp_reward']),
      questions: questionsJson
          .map((e) => QuestionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuestionDto {
  final String id;
  final String word;
  final String contextSentence;
  final String correctAnswer;
  final List<String> distractors;
  final String? imageUrl;

  QuestionDto({
    required this.id,
    required this.word,
    required this.contextSentence,
    required this.correctAnswer,
    required this.distractors,
    this.imageUrl,
  });

  factory QuestionDto.fromJson(Map<String, dynamic> json) {
    final distractorsJson = (json['distractors'] as List?) ?? [];
    return QuestionDto(
      id: (json['id'] ?? '').toString(),
      word: (json['word'] ?? '').toString(),
      contextSentence: (json['context_sentence'] ?? '').toString(),
      correctAnswer: (json['correct_answer'] ?? '').toString(),
      distractors: distractorsJson.map((e) => e.toString()).toList(),
      imageUrl: json['image_url']?.toString(),
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

class AnswerPayloadDto {
  final String questionId;
  final String selectedAnswer;
  final bool isCorrect;

  AnswerPayloadDto({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
  });

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'selected_answer': selectedAnswer,
    'is_correct': isCorrect,
  };
}

class LessonSubmitResultDto {
  final String lessonId;
  final String topicTitle;
  final int lessonOrder;
  final int xpEarned;
  final int totalXp;
  final int currentStreak;
  final int masteredWords;
  final String ranking;
  final double accuracy;
  final int timeSpent;
  final int newTotalXp;
  final bool isCompleted;
  final bool needsReview;
  final bool alreadyCompleted;
  final double dailyGoalPercent;
  final MasteryDto? mastery;
  final String? nextLesson;

  LessonSubmitResultDto({
    required this.lessonId,
    required this.topicTitle,
    required this.lessonOrder,
    required this.xpEarned,
    required this.totalXp,
    required this.currentStreak,
    required this.masteredWords,
    required this.ranking,
    this.accuracy = 0.0,
    this.timeSpent = 0,
    this.newTotalXp = 0,
    this.isCompleted = false,
    this.needsReview = false,
    this.alreadyCompleted = false,
    this.dailyGoalPercent = 0,
    this.mastery,
    this.nextLesson,
  });

  factory LessonSubmitResultDto.fromJson(Map<String, dynamic> json) {
    final totalXp = _asInt(json['total_xp'] ?? json['new_total_xp']);
    return LessonSubmitResultDto(
      lessonId: (json['lesson_id'] ?? '').toString(),
      topicTitle: (json['topic_title'] ?? '').toString(),
      lessonOrder: _asInt(json['lesson_order'] ?? json['order']),
      xpEarned: _asInt(json['earned_xp']),
      totalXp: totalXp,
      currentStreak: _asInt(json['current_streak']),
      masteredWords: _asInt(json['mastered_words']),
      ranking: (json['ranking'] ?? '').toString(),
      accuracy: _asDouble(json['accuracy']),
      timeSpent: _asInt(json['time_spent']),
      newTotalXp: totalXp,
      isCompleted:
          json['is_completed'] == true || json['already_completed'] == true,
      needsReview: json['needs_review'] == true,
      alreadyCompleted: json['already_completed'] == true,
      dailyGoalPercent: _asDouble(json['daily_goal_percent']),
      mastery: json['mastery'] is Map
          ? MasteryDto.fromJson((json['mastery'] as Map).cast<String, dynamic>())
          : null,
      nextLesson: json['next_lesson']?.toString(),
    );
  }
}

class MasteryDto {
  final String title;
  final int level;
  final double progressPercent;

  MasteryDto({
    required this.title,
    required this.level,
    required this.progressPercent,
  });

  factory MasteryDto.fromJson(Map<String, dynamic> json) {
    return MasteryDto(
      title: (json['title'] ?? '').toString(),
      level: _asInt(json['level']),
      progressPercent: _asDouble(json['progress_percent']),
    );
  }
}
