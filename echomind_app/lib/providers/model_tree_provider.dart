import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';
import 'package:echomind_app/models/model_item.dart';

final modelTreeProvider =
    FutureProvider<List<ModelChapterNode>>((ref) async {
  final res = await ApiClient().dio.get('/models/tree');
  return (res.data as List)
      .map((e) => ModelChapterNode.fromJson(e))
      .toList();
});
