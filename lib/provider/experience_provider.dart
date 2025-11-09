import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../model/experience.dart';

final experiencesProvider = FutureProvider<List<Experience>>((ref) async {
  final res = await apiClient.get(
    'experiences',
    queryParameters: {'active': true},
  );
  final data = res.data as Map<String, dynamic>;
  final list = data['data']?['experiences'] as List<dynamic>? ?? [];
  return list.map((e) => Experience.fromJson(e)).toList();
});
