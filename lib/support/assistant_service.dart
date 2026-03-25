import 'package:cloud_functions/cloud_functions.dart';

class AssistantService {
  AssistantService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  Future<String> askAssistant({
    required String question,
    required String firstName,
    required String birthDate,
    required String birthTime,
    required String userElement,
    required String todayElement,
    required bool isGuest,
  }) async {
    final callable = _functions.httpsCallable('askAssistant');
    final result = await callable.call({
      'question': question,
      'firstName': firstName,
      'birthDate': birthDate,
      'birthTime': birthTime,
      'userElement': userElement,
      'todayElement': todayElement,
      'isGuest': isGuest,
    });

    final data = result.data;
    if (data is Map && data['answer'] is String) {
      return data['answer'] as String;
    }

    throw Exception('Assistant response was empty.');
  }
}
