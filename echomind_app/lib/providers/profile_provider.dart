import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';
import 'package:echomind_app/models/student.dart';

final profileProvider = FutureProvider<Student>((ref) async {
  final res = await ApiClient().dio.get('/auth/me');
  return Student.fromJson(res.data);
});
