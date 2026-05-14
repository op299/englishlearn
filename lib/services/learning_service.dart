import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'auth_service.dart';

class LearningService {
  final AuthService _authService;

  LearningService({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<List<TopicDto>> fetchTopics({String? level, String? category}) async {
    final token = await _authService.getAccessToken();
    if (token == null) throw Exception('No access token found');

    final uri = Uri.parse(ApiService.learningTopicsEndpoint).replace(
      queryParameters: {
        if (level != null) 'level': level,
        if (category != null) 'category': category,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load topics: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final list = (body['topics'] as List?) ?? [];
    return list.map((e) => TopicDto.fromJson(e)).toList();
  }

  Future<List<LessonDto>> fetchLessonsByTopic(String topicId) async {
    final token = await _authService.getAccessToken();
    if (token == null) throw Exception('No access token found');

    final uri = Uri.parse(
      ApiService.learningLessonsByTopicEndpoint.replaceAll(
        '{topic_id}',
        topicId,
      ),
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load lessons: ${response.statusCode}');
    }

    final body = jsonDecode(response.body);
    final list = (body['lessons'] as List?) ?? [];
    return list.map((e) => LessonDto.fromJson(e)).toList();
  }

  Future<LessonDetailDto> fetchLessonDetail(String lessonId) async {
    final token = await _authService.getAccessToken();
    if (token == null) throw Exception('No access token found');

    final uri = Uri.parse(
      ApiService.learningLessonDetailEndpoint.replaceAll(
        '{lesson_id}',
        lessonId,
      ),
    );

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
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
    final token = await _authService.getAccessToken();
    if (token == null) throw Exception('No access token found');

    final uri = Uri.parse(
      ApiService.lessonSubmitEndpoint.replaceAll('{lesson_id}', lessonId),
    );

    final requestBody = {'accuracy': accuracy, 'time_spent': timeSpentSeconds};

    print('Submit Request: $requestBody');
    print('Submit URI: $uri');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('Submit Response Status: ${response.statusCode}');
    print('Submit Response Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to submit lesson: ${response.statusCode} - ${response.body}',
      );
    }

    final body = jsonDecode(response.body);
    return LessonSubmitResultDto.fromJson(body);
  }
}

class TopicDto {
  final String id;
  final String title;
  final String level;
  final String category;

  TopicDto({
    required this.id,
    required this.title,
    required this.level,
    required this.category,
  });

  factory TopicDto.fromJson(Map<String, dynamic> json) {
    return TopicDto(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      level: (json['level'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
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
      order: (json['order'] ?? 0) as int,
      xpReward: (json['xp_reward'] ?? 0) as int,
      completed: (json['completed'] ?? false) as bool,
    );
  }
}

class LessonDetailDto {
  final String id;
  final String topicId;
  final int xpReward;
  final List<QuestionDto> questions;

  LessonDetailDto({
    required this.id,
    required this.topicId,
    required this.xpReward,
    required this.questions,
  });

  factory LessonDetailDto.fromJson(Map<String, dynamic> json) {
    final questionsJson = (json['questions'] as List?) ?? [];
    return LessonDetailDto(
      id: (json['id'] ?? '').toString(),
      topicId: (json['topic_id'] ?? '').toString(),
      xpReward: (json['xp_reward'] ?? 0) as int,
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

class AnswerPayloadDto {
  final String questionId;
  final String userAnswer;

  AnswerPayloadDto({required this.questionId, required this.userAnswer});

  Map<String, dynamic> toJson() => {
    'question_id': questionId,
    'user_answer': userAnswer,
  };
}

class LessonSubmitResultDto {
  final String lessonId;
  final double accuracy;
  final int xpEarned;
  final int newTotalXp;
  final bool isCompleted;
  final String? nextLesson;

  LessonSubmitResultDto({
    required this.lessonId,
    required this.accuracy,
    required this.xpEarned,
    required this.newTotalXp,
    required this.isCompleted,
    required this.nextLesson,
  });

  factory LessonSubmitResultDto.fromJson(Map<String, dynamic> json) {
    return LessonSubmitResultDto(
      lessonId: (json['lesson_id'] ?? '').toString(),
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      xpEarned: (json['xp_earned'] ?? 0) as int,
      newTotalXp: (json['new_total_xp'] ?? 0) as int,
      isCompleted: (json['is_completed'] ?? false) as bool,
      nextLesson: json['next_lesson']?.toString(),
    );
  }
}
