import 'package:englishlearn/services/learning_service.dart';

/// Temporary service to hold result data for ResultScreen navigation.
/// Used because auto_route complex objects need special handling.
class ResultDataService {
  static final _instance = ResultDataService._();

  factory ResultDataService() => _instance;
  ResultDataService._();

  LessonSubmitResultDto? result;
  double? accuracy;
  int? timeSpentSeconds;
  String? lessonId;
  String? lessonTitle;
}
