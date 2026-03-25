import 'dart:convert';

import 'element_logic.dart';

const List<int> weeklyAttendanceRewards = [10, 10, 15, 15, 20, 20, 25];
const String assistantSystemPrompt = '''
You are HanBit Assistant, a soft-spoken wellness guide rooted in the five elements.
Keep replies to five sentences or fewer.
Use the user's birth-based element, current daily element, and gentle practical advice.
If the question is unsafe, sexual, hateful, medically diagnostic, illegal, or clearly inappropriate, decline warmly and redirect to calm wellness guidance.
Treat a declined answer as a used turn.
''';

class AppProgress {
  const AppProgress({
    required this.monthKey,
    required this.coins,
    required this.attendanceDay,
    required this.lastAttendanceDateKey,
    required this.assistantDateKey,
    required this.assistantUsedCount,
    this.weeklyReading,
    this.monthlyReading,
    this.lastWeeklyUnlockedAt,
    this.lastMonthlyUnlockedAt,
  });

  final String monthKey;
  final int coins;
  final int attendanceDay;
  final String? lastAttendanceDateKey;
  final String assistantDateKey;
  final int assistantUsedCount;
  final String? weeklyReading;
  final String? monthlyReading;
  final String? lastWeeklyUnlockedAt;
  final String? lastMonthlyUnlockedAt;

  factory AppProgress.empty(DateTime now) {
    return AppProgress(
      monthKey: toMonthKey(now),
      coins: 0,
      attendanceDay: 0,
      lastAttendanceDateKey: null,
      assistantDateKey: toDateKey(now),
      assistantUsedCount: 0,
    );
  }

  factory AppProgress.fromJson(Map<String, dynamic> json, DateTime now) {
    return AppProgress(
      monthKey: json['monthKey'] as String? ?? toMonthKey(now),
      coins: json['coins'] as int? ?? 0,
      attendanceDay: json['attendanceDay'] as int? ?? 0,
      lastAttendanceDateKey: json['lastAttendanceDateKey'] as String?,
      assistantDateKey: json['assistantDateKey'] as String? ?? toDateKey(now),
      assistantUsedCount: json['assistantUsedCount'] as int? ?? 0,
      weeklyReading: json['weeklyReading'] as String?,
      monthlyReading: json['monthlyReading'] as String?,
      lastWeeklyUnlockedAt: json['lastWeeklyUnlockedAt'] as String?,
      lastMonthlyUnlockedAt: json['lastMonthlyUnlockedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthKey': monthKey,
      'coins': coins,
      'attendanceDay': attendanceDay,
      'lastAttendanceDateKey': lastAttendanceDateKey,
      'assistantDateKey': assistantDateKey,
      'assistantUsedCount': assistantUsedCount,
      'weeklyReading': weeklyReading,
      'monthlyReading': monthlyReading,
      'lastWeeklyUnlockedAt': lastWeeklyUnlockedAt,
      'lastMonthlyUnlockedAt': lastMonthlyUnlockedAt,
    };
  }

  String encode() => jsonEncode(toJson());

  static AppProgress decode(String? source, DateTime now) {
    if (source == null || source.isEmpty) {
      return AppProgress.empty(now);
    }

    try {
      return AppProgress.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
        now,
      );
    } catch (_) {
      return AppProgress.empty(now);
    }
  }

  AppProgress copyWith({
    String? monthKey,
    int? coins,
    int? attendanceDay,
    String? lastAttendanceDateKey,
    String? assistantDateKey,
    int? assistantUsedCount,
    String? weeklyReading,
    bool clearWeeklyReading = false,
    String? monthlyReading,
    bool clearMonthlyReading = false,
    String? lastWeeklyUnlockedAt,
    String? lastMonthlyUnlockedAt,
  }) {
    return AppProgress(
      monthKey: monthKey ?? this.monthKey,
      coins: coins ?? this.coins,
      attendanceDay: attendanceDay ?? this.attendanceDay,
      lastAttendanceDateKey:
          lastAttendanceDateKey ?? this.lastAttendanceDateKey,
      assistantDateKey: assistantDateKey ?? this.assistantDateKey,
      assistantUsedCount: assistantUsedCount ?? this.assistantUsedCount,
      weeklyReading: clearWeeklyReading
          ? null
          : weeklyReading ?? this.weeklyReading,
      monthlyReading: clearMonthlyReading
          ? null
          : monthlyReading ?? this.monthlyReading,
      lastWeeklyUnlockedAt: lastWeeklyUnlockedAt ?? this.lastWeeklyUnlockedAt,
      lastMonthlyUnlockedAt:
          lastMonthlyUnlockedAt ?? this.lastMonthlyUnlockedAt,
    );
  }
}

class AttendanceResult {
  const AttendanceResult({
    required this.progress,
    required this.claimed,
    required this.reward,
    required this.message,
  });

  final AppProgress progress;
  final bool claimed;
  final int reward;
  final String message;
}

class UnlockResult {
  const UnlockResult({
    required this.progress,
    required this.unlocked,
    required this.message,
  });

  final AppProgress progress;
  final bool unlocked;
  final String message;
}

class AssistantReplyResult {
  const AssistantReplyResult({
    required this.progress,
    required this.answer,
    required this.usedCount,
    required this.remainingCount,
    required this.blocked,
    required this.limitReached,
  });

  final AppProgress progress;
  final String answer;
  final int usedCount;
  final int remainingCount;
  final bool blocked;
  final bool limitReached;
}

String toDateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String toMonthKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  return '${date.year}-$month';
}

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

AppProgress normalizeProgress(AppProgress progress, DateTime now) {
  final currentMonth = toMonthKey(now);
  final currentDate = toDateKey(now);
  var normalized = progress;

  if (progress.monthKey != currentMonth) {
    normalized = AppProgress.empty(now);
  }

  if (normalized.assistantDateKey != currentDate) {
    normalized = normalized.copyWith(
      assistantDateKey: currentDate,
      assistantUsedCount: 0,
    );
  }

  return normalized;
}

AttendanceResult claimAttendance(AppProgress rawProgress, DateTime now) {
  var progress = normalizeProgress(rawProgress, now);
  final todayKey = toDateKey(now);

  if (progress.lastAttendanceDateKey == todayKey) {
    return AttendanceResult(
      progress: progress,
      claimed: false,
      reward: 0,
      message: 'Today attendance is already complete.',
    );
  }

  int attendanceDay = progress.attendanceDay;
  if (progress.lastAttendanceDateKey != null) {
    final last = DateTime.tryParse(progress.lastAttendanceDateKey!);
    if (last == null ||
        dateOnly(now).difference(dateOnly(last)).inDays > 1 ||
        attendanceDay >= weeklyAttendanceRewards.length) {
      attendanceDay = 0;
    }
  }

  attendanceDay += 1;
  final reward = weeklyAttendanceRewards[attendanceDay - 1];
  progress = progress.copyWith(
    coins: progress.coins + reward,
    attendanceDay: attendanceDay,
    lastAttendanceDateKey: todayKey,
  );

  return AttendanceResult(
    progress: progress,
    claimed: true,
    reward: reward,
    message:
        'Day $attendanceDay attendance complete. You earned $reward coins.',
  );
}

UnlockResult unlockWeeklyReading({
  required AppProgress rawProgress,
  required DateTime now,
  required OhaengElement? userElement,
  required OhaengElement todayElement,
  required String birthTimeLabel,
  required String locationHint,
}) {
  var progress = normalizeProgress(rawProgress, now);
  if (progress.coins < 50) {
    return UnlockResult(
      progress: progress,
      unlocked: false,
      message: '50 coins are needed for a weekly reading.',
    );
  }

  final reading = buildWeeklyReading(
    userElement: userElement,
    todayElement: todayElement,
    birthTimeLabel: birthTimeLabel,
    locationHint: locationHint,
  );

  progress = progress.copyWith(
    coins: progress.coins - 50,
    weeklyReading: reading,
    lastWeeklyUnlockedAt: now.toIso8601String(),
  );

  return UnlockResult(
    progress: progress,
    unlocked: true,
    message: 'Weekly reading unlocked for 50 coins.',
  );
}

UnlockResult unlockMonthlyReading({
  required AppProgress rawProgress,
  required DateTime now,
  required OhaengElement? userElement,
  required OhaengElement todayElement,
  required String birthTimeLabel,
  required String locationHint,
}) {
  var progress = normalizeProgress(rawProgress, now);
  if (progress.coins < 180) {
    return UnlockResult(
      progress: progress,
      unlocked: false,
      message: '180 coins are needed for a monthly energy reading.',
    );
  }

  final reading = buildMonthlyReading(
    userElement: userElement,
    todayElement: todayElement,
    birthTimeLabel: birthTimeLabel,
    locationHint: locationHint,
  );

  progress = progress.copyWith(
    coins: progress.coins - 180,
    monthlyReading: reading,
    lastMonthlyUnlockedAt: now.toIso8601String(),
  );

  return UnlockResult(
    progress: progress,
    unlocked: true,
    message: 'Monthly reading unlocked for 180 coins.',
  );
}

AssistantReplyResult askAssistant({
  required AppProgress rawProgress,
  required DateTime now,
  required bool isGuest,
  required String question,
  required OhaengElement? userElement,
  required OhaengElement todayElement,
}) {
  var progress = normalizeProgress(rawProgress, now);
  final limit = isGuest ? 1 : 3;

  if (progress.assistantUsedCount >= limit) {
    return AssistantReplyResult(
      progress: progress,
      answer: isGuest
          ? 'Guest access allows one question each day. Sign in for three guided questions.'
          : 'You have used all three assistant questions for today. Come back tomorrow for more guidance.',
      usedCount: progress.assistantUsedCount,
      remainingCount: 0,
      blocked: false,
      limitReached: true,
    );
  }

  final blocked = _isBlockedQuestion(question);
  final answer = blocked
      ? _blockedAssistantReply()
      : _buildAssistantReply(
          question: question,
          userElement: userElement,
          todayElement: todayElement,
        );
  final usedCount = progress.assistantUsedCount + 1;
  progress = progress.copyWith(
    assistantDateKey: toDateKey(now),
    assistantUsedCount: usedCount,
  );

  return AssistantReplyResult(
    progress: progress,
    answer: answer,
    usedCount: usedCount,
    remainingCount: limit - usedCount,
    blocked: blocked,
    limitReached: false,
  );
}

bool _isBlockedQuestion(String question) {
  final lowered = question.toLowerCase();
  const blockedTerms = [
    'sex',
    'nude',
    'porn',
    'kill',
    'suicide',
    'self harm',
    'bomb',
    'weapon',
    'hack',
    'steal',
    'drug',
    'diagnose',
    'racist',
    'hate',
  ];

  return blockedTerms.any((term) => lowered.contains(term));
}

String buildWeeklyReading({
  required OhaengElement? userElement,
  required OhaengElement todayElement,
  required String birthTimeLabel,
  required String locationHint,
}) {
  final element = userElement == null ? 'balanced' : formatElement(userElement);
  final dayFlow = formatElement(todayElement);

  return 'Your $element energy meets a $dayFlow week. '
      'Move with clean focus, begin one brave thing, and let $locationHint nights restore your rhythm.';
}

String buildMonthlyReading({
  required OhaengElement? userElement,
  required OhaengElement todayElement,
  required String birthTimeLabel,
  required String locationHint,
}) {
  final element = userElement == null ? 'balanced' : formatElement(userElement);
  final dayFlow = formatElement(todayElement);
  final birthTone = birthTimeLabel.isEmpty ? 'inner timing' : birthTimeLabel;

  return 'This month your $element energy moves through a lasting $dayFlow tone. '
      'Keep commitments lighter, protect sleep around $birthTone, and repeat one grounding habit. '
      'In $locationHint, calm routines and deliberate choices will open your best results.';
}

String _buildAssistantReply({
  required String question,
  required OhaengElement? userElement,
  required OhaengElement todayElement,
}) {
  final element = userElement == null ? 'balanced' : formatElement(userElement);
  final dayFlow = formatElement(todayElement);
  final trimmedQuestion = question.trim();

  return 'I hear your question about "$trimmedQuestion." '
      'Your $element energy meets today\'s $dayFlow flow, so a calm and direct approach will serve you best. '
      'Focus on one honest action instead of trying to solve everything at once. '
      'If the situation feels noisy, step back, breathe, and respond after your body softens. '
      'Let clarity grow through rhythm, not pressure.';
}

String _blockedAssistantReply() {
  return 'I can\'t help with that kind of request. '
      'If you want, ask me about emotional balance, relationships, timing, or your current energy instead. '
      'I can still offer a calm wellness reading within those topics.';
}
