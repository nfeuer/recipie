import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_app/data/services/dynamic_link_service.dart';

// Dynamic Link Service Provider
final dynamicLinkServiceProvider = Provider<DynamicLinkService>((ref) {
  return DynamicLinkService();
});
