import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/services/analytics_service.dart';

// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
