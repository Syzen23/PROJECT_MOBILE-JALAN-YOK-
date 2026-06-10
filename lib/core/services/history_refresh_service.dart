import 'package:flutter/foundation.dart';

class HistoryRefreshService {
  HistoryRefreshService._();

  static final ValueNotifier<int> token = ValueNotifier<int>(0);

  static void bump() {
    token.value++;
  }
}
