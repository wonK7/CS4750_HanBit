import 'package:cloud_functions/cloud_functions.dart';

class AssistantService {
  AssistantService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.wonk.hanbit';

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

  Future<ShareLinkResponse> createShareLink({
    required String shareType,
    required String title,
    required String description,
    required String body,
  }) async {
    final callable = _functions.httpsCallable('createShareLink');
    final result = await callable.call({
      'shareType': shareType,
      'title': title,
      'description': description,
      'body': body,
    });

    final data = result.data;
    if (data is Map && data['url'] is String) {
      final resolvedShareUrl = data['shareUrl'] is String
          ? data['shareUrl'] as String
          : data['url'] as String;
      return ShareLinkResponse(
        shareUrl: resolvedShareUrl,
        playStoreUrl: data['playStoreUrl'] is String
            ? data['playStoreUrl'] as String
            : playStoreUrl,
      );
    }

    throw Exception('Share link response was empty.');
  }
}

class ShareLinkResponse {
  const ShareLinkResponse({
    required this.shareUrl,
    required this.playStoreUrl,
  });

  final String shareUrl;
  final String playStoreUrl;
}
