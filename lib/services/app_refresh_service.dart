import 'package:flutter/foundation.dart';

class AppRefreshService {
  static final ValueNotifier<int> dashboardRefresh = ValueNotifier<int>(0);
  static final ValueNotifier<int> progressRefresh = ValueNotifier<int>(0);

  static void notifyLearningDataChanged() {
    dashboardRefresh.value++;
    progressRefresh.value++;
  }
}
