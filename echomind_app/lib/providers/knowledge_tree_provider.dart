import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';
import 'package:echomind_app/models/knowledge_point.dart';

final knowledgeTreeProvider =
    FutureProvider<List<KnowledgePoint>>((ref) async {
  final res = await ApiClient().dio.get('/knowledge/tree');
  return (res.data as List)
      .map((e) => KnowledgePoint.fromJson(e))
      .toList();
});
