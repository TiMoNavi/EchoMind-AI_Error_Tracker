import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echomind_app/core/api_client.dart';

class Flashcard {
  final String id;
  final String question;
  final String answer;
  const Flashcard({required this.id, required this.question, required this.answer});

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'] ?? '',
    question: json['question'] ?? '',
    answer: json['answer'] ?? '',
  );
}

final flashcardProvider = FutureProvider<List<Flashcard>>((ref) async {
  final res = await ApiClient().dio.get('/flashcards');
  return (res.data as List).map((e) => Flashcard.fromJson(e)).toList();
});
