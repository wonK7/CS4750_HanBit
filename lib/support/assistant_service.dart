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
    required List<String> personalityTraits,
    required List<String> stressTriggers,
    required List<Map<String, String>> conversationHistory,
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
      'personalityTraits': personalityTraits,
      'stressTriggers': stressTriggers,
      'conversationHistory': conversationHistory,
    });

    final data = result.data;
    if (data is Map && data['answer'] is String) {
      return data['answer'] as String;
    }

    throw Exception('Assistant response was empty.');
  }

  Future<String> generatePremiumReading({
    required String readingType,
    required String firstName,
    required String birthDate,
    required String birthTime,
    required String userElement,
    required String todayElement,
    required String timezoneLabel,
    required String currentDateLabel,
    required List<String> personalityTraits,
    required List<String> stressTriggers,
  }) async {
    final callable = _functions.httpsCallable('generatePremiumReading');
    final result = await callable.call({
      'readingType': readingType,
      'firstName': firstName,
      'birthDate': birthDate,
      'birthTime': birthTime,
      'userElement': userElement,
      'todayElement': todayElement,
      'timezoneLabel': timezoneLabel,
      'currentDateLabel': currentDateLabel,
      'personalityTraits': personalityTraits,
      'stressTriggers': stressTriggers,
    });

    final data = result.data;
    if (data is Map && data['reading'] is String) {
      return data['reading'] as String;
    }

    throw Exception('Premium reading response was empty.');
  }
}
