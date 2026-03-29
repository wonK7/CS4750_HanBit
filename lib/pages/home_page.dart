import 'dart:io';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/element_logic.dart';
import '../support/engagement_logic.dart';
import '../support/assistant_service.dart';
import 'login_page.dart';
import 'signup_page.dart';

const Color _globalMutedTextColor = Color(0xFF5F695F);
const Color _globalSecondaryTextColor = Color(0xFF6C5F50);

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.firstName});

  static const routeName = '/home';
  final String firstName;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _assistantController = TextEditingController();
  final List<_AssistantMessage> _assistantMessages = [];
  final GlobalKey _todayShareKey = GlobalKey();
  final GlobalKey _weeklyShareKey = GlobalKey();
  final GlobalKey _monthlyShareKey = GlobalKey();

  late String displayFirstName;
  String myEnergy = 'Check your energy';
  String ohaengSymbol = '☯';
  String energyDescription =
      'In Korean wellness philosophy, the five elements describe different kinds of balance and personal energy. Enter your birthdate and birth time to unlock a more personal reading.';
  Color energyAccent = const Color(0xFF789288);
  Color energyCardColor = Colors.white;
  Color energyButtonColor = const Color(0xFFEAE6F6);
  int _selectedIndex = 0;
  OhaengElement? userElement;
  late OhaengElement todayElement;
  Map<String, dynamic> recommendation = defaultRecommendation;
  DateTime? birthDate;
  String birthDateLabel = '';
  String birthTimeLabel = '';
  bool _loadingProfile = false;
  bool _syncingProgress = false;
  bool _assistantIsThinking = false;
  bool _coinBurstVisible = false;
  int _coinBurstReward = 0;
  AppProgress _progress = AppProgress.empty(DateTime.now());
  OhaengElement _selectedGuideElement = OhaengElement.wood;

  static const Color _mutedTextColor = _globalMutedTextColor;
  static const Color _secondaryTextColor = _globalSecondaryTextColor;
  final AssistantService _assistantService = AssistantService();

  bool get _isGuestUser => FirebaseAuth.instance.currentUser == null;
  int get _assistantLimit => _isGuestUser ? 1 : 3;
  int get _assistantRemaining =>
      (_assistantLimit - _progress.assistantUsedCount).clamp(0, _assistantLimit)
          as int;
  int get _assistantUsedCount => _progress.assistantUsedCount;

  @override
  void initState() {
    super.initState();
    displayFirstName = widget.firstName;
    todayElement = getTodayElement();
    _loadMemberProfile();
  }

  @override
  void dispose() {
    _assistantController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      _loadingProfile = true;
    });

    try {
      Map<String, dynamic>? remoteData;

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        remoteData = userDoc.data();

        if (remoteData != null) {
          final firstName = (remoteData['firstName'] as String?)?.trim();
          final savedBirthDate = remoteData['birthDate'] as Timestamp?;
          final savedBirthTime = remoteData['birthTime'] as String?;

          if (firstName != null && firstName.isNotEmpty) {
            displayFirstName = firstName;
          }

          if (savedBirthDate != null &&
              savedBirthTime != null &&
              savedBirthTime.isNotEmpty) {
            _applyReading(
              picked: savedBirthDate.toDate(),
              birthTime: savedBirthTime,
            );
          }
        }
      }

      await _loadStoredProgress(remoteData: remoteData);
    } finally {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
        });
      }
    }
  }

  Future<void> _loadStoredProgress({Map<String, dynamic>? remoteData}) async {
    final prefs = await SharedPreferences.getInstance();
    final localSource = prefs.getString(_progressStorageKey);
    final localProgress = AppProgress.decode(localSource, DateTime.now());
    AppProgress nextProgress = normalizeProgress(localProgress, DateTime.now());

    final remoteProgressJson = remoteData?['engagement'];
    if (remoteProgressJson is Map<String, dynamic>) {
      nextProgress = normalizeProgress(
        AppProgress.fromJson(remoteProgressJson, DateTime.now()),
        DateTime.now(),
      );
    } else if (remoteProgressJson is Map) {
      nextProgress = normalizeProgress(
        AppProgress.fromJson(
          Map<String, dynamic>.from(remoteProgressJson),
          DateTime.now(),
        ),
        DateTime.now(),
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _progress = nextProgress;
    });
  }

  Future<void> _persistProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressStorageKey, _progress.encode());

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    setState(() {
      _syncingProgress = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
            'engagement': _progress.toJson(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } finally {
      if (mounted) {
        setState(() {
          _syncingProgress = false;
        });
      }
    }
  }

  String get _progressStorageKey {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null ? 'hanbit_progress_guest' : 'hanbit_progress_$uid';
  }

  String get _locationHint {
    final zone = DateTime.now().timeZoneName.trim();
    if (zone.isEmpty) {
      return 'your local time zone';
    }
    return zone;
  }

  void _applyReading({required DateTime picked, required String birthTime}) {
    final nextUserElement = getUserElementFromBirthdate(picked);
    final nextTodayElement = getTodayElement();
    final nextRecommendation = getRecommendation(
      nextUserElement,
      nextTodayElement,
    );
    final theme = elementTheme(nextUserElement);

    setState(() {
      birthDate = picked;
      birthDateLabel = formatBirthDate(picked);
      birthTimeLabel = birthTime;
      userElement = nextUserElement;
      todayElement = nextTodayElement;
      recommendation = nextRecommendation;
      myEnergy = theme.title;
      ohaengSymbol = theme.symbol;
      energyDescription = theme.description;
      energyAccent = theme.accent;
      energyCardColor = theme.cardColor;
      energyButtonColor = theme.buttonColor;
      _selectedGuideElement = nextUserElement;
    });
  }

  Future<void> checkEnergy() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked == null) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );

    if (pickedTime == null) {
      return;
    }

    final nextBirthTimeLabel = formatBirthTime(pickedTime);
    final nextUserElement = getUserElementFromBirthdate(picked);
    final nextTodayElement = getTodayElement();
    final nextRecommendation = getRecommendation(
      nextUserElement,
      nextTodayElement,
    );

    _applyReading(picked: picked, birthTime: nextBirthTimeLabel);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final isGuest = currentUser == null;

      await FirebaseFirestore.instance.collection('readings').add({
        'firstName': displayFirstName,
        'userId': currentUser?.uid,
        'isGuest': isGuest,
        'birthDate': Timestamp.fromDate(picked),
        'birthTime': nextBirthTimeLabel,
        'userElement': formatElement(nextUserElement),
        'todayElement': formatElement(nextTodayElement),
        'interaction': nextRecommendation['interaction'],
        'explanation': nextRecommendation['explanation'],
        'k': nextRecommendation['k'],
        'global': nextRecommendation['global'],
        'supplement': nextRecommendation['supplement'],
        'avoid': nextRecommendation['avoid'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!isGuest) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .set({
              'firstName': displayFirstName,
              'birthDate': Timestamp.fromDate(picked),
              'birthTime': nextBirthTimeLabel,
              'userElement': formatElement(nextUserElement),
              'symbol': displayElementIcon(nextUserElement, ohaengSymbol),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your energy profile was saved.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your reading right now.')),
      );
    }
  }

  Future<void> _claimAttendance() async {
    if (_isGuestUser) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance coins are for signed-in members only.'),
        ),
      );
      return;
    }

    final result = claimAttendance(_progress, DateTime.now());
    setState(() {
      _progress = result.progress;
    });
    await _persistProgress();

    if (!mounted) {
      return;
    }

    if (result.claimed) {
      _showCoinBurst(result.reward);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  void _showCoinBurst(int reward) {
    setState(() {
      _coinBurstReward = reward;
      _coinBurstVisible = true;
    });

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _coinBurstVisible = false;
      });
    });
  }

  Future<void> _unlockWeeklyReading() async {
    if (_isGuestUser) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to use coins and unlock weekly readings.'),
        ),
      );
      return;
    }

    final result = unlockWeeklyReading(
      rawProgress: _progress,
      now: DateTime.now(),
      userElement: userElement,
      todayElement: todayElement,
      birthTimeLabel: birthTimeLabel,
      locationHint: _locationHint,
    );

    setState(() {
      _progress = result.progress;
    });
    await _persistProgress();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _unlockMonthlyReading() async {
    if (_isGuestUser) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to use coins and unlock monthly readings.'),
        ),
      );
      return;
    }

    final result = unlockMonthlyReading(
      rawProgress: _progress,
      now: DateTime.now(),
      userElement: userElement,
      todayElement: todayElement,
      birthTimeLabel: birthTimeLabel,
      locationHint: _locationHint,
    );

    setState(() {
      _progress = result.progress;
    });
    await _persistProgress();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  Future<void> _sendAssistantQuestion() async {
    final question = _assistantController.text.trim();
    if (question.isEmpty) {
      return;
    }

    setState(() {
      _assistantMessages.add(
        _AssistantMessage(content: question, isUser: true),
      );
      _assistantController.clear();
      _assistantIsThinking = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));

    final result = askAssistant(
      rawProgress: _progress,
      now: DateTime.now(),
      isGuest: _isGuestUser,
      question: question,
      userElement: userElement,
      todayElement: todayElement,
    );

    String answer = result.answer;
    try {
      answer = await _assistantService.askAssistant(
        question: question,
        firstName: displayFirstName,
        birthDate: birthDateLabel,
        birthTime: birthTimeLabel,
        userElement: userElement == null ? '' : formatElement(userElement!),
        todayElement: formatElement(todayElement),
        isGuest: _isGuestUser,
      );
    } catch (_) {
      answer = result.answer;
    }

    setState(() {
      _assistantMessages.add(_AssistantMessage(content: answer, isUser: false));
      _progress = result.progress;
      _assistantIsThinking = false;
    });
    await _persistProgress();
  }

  Future<void> _shareReadingCard({
    required GlobalKey boundaryKey,
    required String fallbackText,
    required String subject,
  }) async {
    try {
      if (kIsWeb) {
        await SharePlus.instance.share(
          ShareParams(text: fallbackText, subject: subject),
        );
        return;
      }

      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('Share area not ready');
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null) {
        throw StateError('Could not create image');
      }

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$subject.png');
      await file.writeAsBytes(bytes, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: fallbackText,
          subject: subject,
        ),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: fallbackText));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sharing failed, so the reading text was copied instead.',
          ),
        ),
      );
    }
  }

  String _todayShareText() {
    return 'HanBit Today Guide\n'
        '$myEnergy\n'
        'Today\'s element: ${formatElement(todayElement)}\n'
        '${_hanBitMessage()}';
  }

  String _weeklyShareText() {
    return 'HanBit Weekly Reading\n'
        '${_progress.weeklyReading ?? 'Unlock a weekly reading with 50 coins.'}';
  }

  String _monthlyShareText() {
    return 'HanBit Monthly Reading\n'
        '${_progress.monthlyReading ?? 'Unlock a monthly reading with 180 coins.'}';
  }

  Future<void> _editProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final nameController = TextEditingController(text: displayFirstName);
    DateTime? draftBirthDate = birthDate;
    String draftBirthDateLabel = birthDateLabel;
    String draftBirthTimeLabel = birthTimeLabel;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFFBF5),
              title: const Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: draftBirthDate ?? DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked == null) {
                          return;
                        }
                        setDialogState(() {
                          draftBirthDate = picked;
                          draftBirthDateLabel = formatBirthDate(picked);
                        });
                      },
                      child: Text(
                        draftBirthDateLabel.isEmpty
                            ? 'Choose Birth Date'
                            : 'Birth Date: $draftBirthDateLabel',
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () async {
                        final parsedTime = _initialTimeFromLabel(
                          draftBirthTimeLabel,
                        );
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime:
                              parsedTime ?? const TimeOfDay(hour: 7, minute: 0),
                        );
                        if (picked == null) {
                          return;
                        }
                        setDialogState(() {
                          draftBirthTimeLabel = formatBirthTime(picked);
                        });
                      },
                      child: Text(
                        draftBirthTimeLabel.isEmpty
                            ? 'Choose Birth Time'
                            : 'Birth Time: $draftBirthTimeLabel',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldSave != true) {
      nameController.dispose();
      return;
    }

    final nextName = nameController.text.trim();
    nameController.dispose();

    if (nextName.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('First name cannot be empty.')),
      );
      return;
    }

    if ((draftBirthDate == null) != draftBirthTimeLabel.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please save both birth date and birth time together.'),
        ),
      );
      return;
    }

    try {
      setState(() {
        displayFirstName = nextName;
      });

      final updateData = <String, dynamic>{
        'firstName': nextName,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (draftBirthDate != null && draftBirthTimeLabel.isNotEmpty) {
        final nextUserElement = getUserElementFromBirthdate(draftBirthDate!);
        updateData.addAll({
          'birthDate': Timestamp.fromDate(draftBirthDate!),
          'birthTime': draftBirthTimeLabel,
          'userElement': formatElement(nextUserElement),
          'symbol': displayElementIcon(nextUserElement, ohaengSymbol),
        });
        _applyReading(picked: draftBirthDate!, birthTime: draftBirthTimeLabel);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set(updateData, SetOptions(merge: true));

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update profile right now.')),
      );
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) {
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  TimeOfDay? _initialTimeFromLabel(String value) {
    if (value.isEmpty) {
      return null;
    }
    final match = RegExp(r'^(\d{1,2}):(\d{2}) (AM|PM)$').firstMatch(value);
    if (match == null) {
      return null;
    }
    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    final period = match.group(3);
    if (hour == null || minute == null || period == null) {
      return null;
    }
    final normalizedHour = period == 'PM' ? (hour % 12) + 12 : hour % 12;
    return TimeOfDay(hour: normalizedHour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeTab(),
      _buildGuideTab(),
      _buildAssistantTab(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      appBar: AppBar(
        title: Text(switch (_selectedIndex) {
          0 => "Today's Energy",
          1 => '✨ Readings',
          2 => 'AI Assistant',
          _ => 'Profile',
        }),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F0E7), Color(0xFFEEE4D2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomPaint(
          painter: _HanjiPatternPainter(),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: pages[_selectedIndex],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF2C2C2C),
        unselectedItemColor: const Color(0xFF789288),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_rounded),
            label: '✨ Readings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      key: const ValueKey('home-tab'),
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                displayElementIcon(userElement, ohaengSymbol),
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Welcome, $displayFirstName',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ],
          ),
          if (_loadingProfile) ...[
            const SizedBox(height: 8),
            const Text(
              'Loading your saved profile...',
              style: TextStyle(fontSize: 14, color: _mutedTextColor),
            ),
          ],
          if (_syncingProgress) ...[
            const SizedBox(height: 4),
            const Text(
              'Syncing your coins and readings...',
              style: TextStyle(fontSize: 13, color: _mutedTextColor),
            ),
          ],
          RepaintBoundary(
            key: _todayShareKey,
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: energyCardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: energyAccent.withOpacity(0.22),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.75),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ohaengSymbol,
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    myEnergy,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: energyAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    energyDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: energyAccent.withValues(alpha: 0.92),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Today\'s Element: ${formatElement(todayElement)} ${displayElementIcon(todayElement, '')}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: energyAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hanBitMessage(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF5C4B3B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: checkEnergy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: energyButtonColor,
                    foregroundColor: energyAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Input Birthdate & Time'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _shareReadingCard(
                      boundaryKey: _todayShareKey,
                      fallbackText: _todayShareText(),
                      subject: 'hanbit_today_guide',
                    );
                  },
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2C2C2C),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFBDAF92)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildAttendanceCard(),
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _coinBurstVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: AnimatedScale(
                        scale: _coinBurstVisible ? 1 : 0.72,
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutBack,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '+$_coinBurstReward coins',
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildFiveElementExplorer(),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    final rewards = weeklyAttendanceRewards;
    final isGuest = _isGuestUser;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2F2A24), Color(0xFF5A4B39)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Attendance Coins',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isGuest
                      ? const Color(0xFFE6DCC8)
                      : Colors.amber.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isGuest ? 'Guests: 0 coins' : '${_progress.coins} coins',
                  style: TextStyle(
                    color: const Color(0xFF2C2C2C),
                    fontWeight: FontWeight.w700,
                    fontSize: isGuest ? 13 : 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isGuest
                ? 'Attendance coins and reading unlocks are available after sign-in.'
                : 'Weekly attendance resets after day 7. Coins reset every new month.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          if (!isGuest)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(rewards.length, (index) {
                final day = index + 1;
                final completed = day <= _progress.attendanceDay;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 88,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: completed
                        ? Colors.amber.shade200
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Day $day',
                        style: TextStyle(
                          color: completed
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${rewards[index]}',
                        style: TextStyle(
                          color: completed
                              ? const Color(0xFF5A4B39)
                              : Colors.amber.shade100,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          if (isGuest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: const Text(
                'Create an account to start collecting attendance coins and unlock weekly or monthly readings.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isGuest
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    }
                  : _claimAttendance,
              icon: Icon(
                isGuest ? Icons.lock_outline : Icons.check_circle_outline,
              ),
              label: Text(
                isGuest ? 'Sign In To Collect Coins' : 'Check In Today',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2C2C2C),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isGuest
                ? 'Guests can preview only. Sign in to earn and spend coins.'
                : '50 coins: Weekly reading  •  180 coins: Monthly reading',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideTab() {
    return ListView(
      key: const ValueKey('guide-tab'),
      children: [
        _buildGuideSummaryCard(),
        const SizedBox(height: 16),
        _buildUnlockCard(
          boundaryKey: _weeklyShareKey,
          title: 'Weekly Reading',
          subtitle: '50 coins',
          reading: _progress.weeklyReading,
          cost: 50,
          accent: const Color(0xFFE6DCC8),
          buttonLabel: 'Unlock Weekly Reading',
          onPressed: _unlockWeeklyReading,
          onShare: _progress.weeklyReading == null
              ? null
              : () {
                  _shareReadingCard(
                    boundaryKey: _weeklyShareKey,
                    fallbackText: _weeklyShareText(),
                    subject: 'hanbit_weekly_reading',
                  );
                },
        ),
        const SizedBox(height: 16),
        _buildUnlockCard(
          boundaryKey: _monthlyShareKey,
          title: 'Monthly Energy Reading',
          subtitle: '180 coins',
          reading: _progress.monthlyReading,
          cost: 180,
          accent: const Color(0xFFF1E1C7),
          buttonLabel: 'Unlock Monthly Reading',
          onPressed: _unlockMonthlyReading,
          onShare: _progress.monthlyReading == null
              ? null
              : () {
                  _shareReadingCard(
                    boundaryKey: _monthlyShareKey,
                    fallbackText: _monthlyShareText(),
                    subject: 'hanbit_monthly_reading',
                  );
                },
        ),
      ],
    );
  }

  Widget _buildUnlockCard({
    required GlobalKey boundaryKey,
    required String title,
    required String subtitle,
    required String? reading,
    required int cost,
    required Color accent,
    required String buttonLabel,
    required VoidCallback onPressed,
    required VoidCallback? onShare,
  }) {
    final lockedText = title == 'Weekly Reading'
        ? 'Unlock a short AI-style weekly energy reading. It uses your birth profile and current local rhythm.'
        : 'Unlock a deeper monthly energy reading with a slightly longer focus for the month ahead.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF8B7D68),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_progress.coins} coins',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          RepaintBoundary(
            key: boundaryKey,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: accent.withOpacity(0.38),
              ),
              child: Text(
                reading ?? lockedText,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: Color(0xFF3D3328),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(buttonLabel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2C2C2C),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Color(0xFFBDAF92)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSummaryCard() {
    final profileMood = userElement == null
        ? 'Balanced, thoughtful, and open to insight'
        : _elementMoodLine(userElement!);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today Guide Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profileMood,
            style: const TextStyle(fontSize: 16, color: _mutedTextColor),
          ),
          if (birthDateLabel.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Birth Date: $birthDateLabel',
              style: const TextStyle(fontSize: 15, color: _mutedTextColor),
            ),
          ],
          if (birthTimeLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Birth Time: $birthTimeLabel',
              style: const TextStyle(fontSize: 15, color: _mutedTextColor),
            ),
          ],
          const SizedBox(height: 14),
          _GuideCard(
            icon: Icons.restaurant,
            title: 'K-Food',
            description: joinItems(recommendation['k'] as List<String>),
            backgroundColor: Colors.white,
          ),
          _GuideCard(
            icon: Icons.self_improvement,
            title: 'Global Wellness',
            description: joinItems(recommendation['global'] as List<String>),
            backgroundColor: Colors.white,
          ),
          _GuideCard(
            icon: Icons.medication_outlined,
            title: 'Supplements',
            description: joinItems(
              recommendation['supplement'] as List<String>,
            ),
            backgroundColor: Colors.white,
          ),
          _GuideCard(
            icon: Icons.do_not_disturb_on_outlined,
            title: 'Avoid',
            description: joinItems(recommendation['avoid'] as List<String>),
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildFiveElementExplorer() {
    final details = _elementInsight(_selectedGuideElement);
    final diagramItems = <({OhaengElement element, Alignment alignment})>[
      (element: OhaengElement.wood, alignment: const Alignment(0, -0.96)),
      (element: OhaengElement.fire, alignment: const Alignment(0.92, -0.2)),
      (element: OhaengElement.earth, alignment: const Alignment(0.58, 0.84)),
      (element: OhaengElement.metal, alignment: const Alignment(-0.58, 0.84)),
      (element: OhaengElement.water, alignment: const Alignment(-0.92, -0.2)),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCCFB7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A6C58).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Five Elements Explorer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover your natural tendencies and learn how to balance your life through the wisdom of the Five Elements.',
            style: TextStyle(fontSize: 14, color: _mutedTextColor),
          ),
          const SizedBox(height: 4),
          const Text(
            "It's about making better daily decisions for a more harmonious you.",
            style: TextStyle(
              fontSize: 14,
              color: _secondaryTextColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: SizedBox(
              width: 340,
              height: 340,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(340, 340),
                    painter: _ElementOrbitPainter(),
                  ),
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.95),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2C2C2C).withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '☯',
                      style: TextStyle(fontSize: 54, color: Color(0xFF2C2C2C)),
                    ),
                  ),
                  ...diagramItems.map((item) {
                    final element = item.element;
                    final isSelected = element == _selectedGuideElement;
                    final insight = _elementInsight(element);
                    return Align(
                      alignment: item.alignment,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGuideElement = element;
                          });
                        },
                        child: AnimatedScale(
                          scale: isSelected ? 1.04 : 1,
                          duration: const Duration(milliseconds: 180),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 98,
                            height: 98,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  insight.color.withOpacity(0.94),
                                  insight.deepColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: insight.color.withOpacity(
                                    isSelected ? 0.38 : 0.2,
                                  ),
                                  blurRadius: isSelected ? 20 : 10,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.white.withOpacity(0.35),
                                width: isSelected ? 2.4 : 1.2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  insight.emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  insight.shortLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: details.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: details.color.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${details.emoji} ${details.title}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: details.labelColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  details.description,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: Color(0xFF3E372F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                _InsightDetail(label: 'Traits', value: details.traits),
                _InsightDetail(label: 'Strengths', value: details.strengths),
                _InsightDetail(label: 'Challenges', value: details.challenges),
                _InsightDetail(
                  label: 'Wellness Strategy',
                  value: details.wellnessStrategy,
                  emphasize: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssistantTab() {
    return Column(
      key: const ValueKey('assistant-tab'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Questions used today: $_assistantUsedCount / $_assistantLimit',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isGuestUser
                    ? 'Guest users can ask one question per day. Sign in for three.'
                    : 'Signed-in members can ask up to three questions per day.',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: _mutedTextColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE4D9C7)),
            ),
            child: _assistantMessages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AssistantMascot(isThinking: _assistantIsThinking),
                        const SizedBox(height: 18),
                        const Text(
                          'Ask about timing, mood, relationships, or energy flow.',
                          style: TextStyle(
                            fontSize: 15,
                            color: _mutedTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _assistantMessages.length,
                    itemBuilder: (context, index) {
                      final message = _assistantMessages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? const Color(0xFF2C2C2C)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              color: message.isUser
                                  ? Colors.white
                                  : const Color(0xFF2C2C2C),
                              height: 1.45,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        if (_assistantIsThinking) ...[
          const SizedBox(height: 12),
          const Center(
            child: _AssistantMascot(isThinking: true, compact: true),
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _assistantController,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ask HanBit Assistant...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _sendAssistantQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C2C2C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Send'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      key: const ValueKey('profile-tab'),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    displayElementIcon(userElement, ohaengSymbol),
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      displayFirstName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                userElement == null
                    ? 'Symbolic Element: Not selected yet'
                    : 'Symbolic Element: ${formatElement(userElement!)}',
                style: const TextStyle(fontSize: 16, color: Color(0xFF789288)),
              ),
              const SizedBox(height: 8),
              Text(
                'Coins this month: ${_progress.coins}',
                style: const TextStyle(fontSize: 16, color: Color(0xFF789288)),
              ),
              if (birthDateLabel.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Birth Date: $birthDateLabel',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF789288),
                  ),
                ),
              ],
              if (birthTimeLabel.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Birth Time: $birthTimeLabel',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF789288),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_isGuestUser) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2C2C2C),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF789288)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Back to Sign In'),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _editProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _signOut,
                    style: TextButton.styleFrom(
                      foregroundColor: _secondaryTextColor,
                    ),
                    child: const Text('Sign out'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _hanBitMessage() {
    if (userElement == null) {
      return 'Move gently today. Balance often begins in quiet moments.';
    }

    final interaction = recommendation['interaction'] as String? ?? 'neutral';
    switch (interaction) {
      case 'boost':
        return 'Today supports your flow. Trust a calm step forward and let momentum build naturally.';
      case 'support':
        return 'You may give more energy than usual today. Protect your pace and keep your center steady.';
      case 'control':
        return 'Do not force the day to bend too quickly. Clarity grows when you move with patience.';
      case 'suppressed':
        return 'Rest is not weakness today. Gentle choices will bring your balance back faster than pressure.';
      default:
        return 'Stay present with small rituals today. Even quiet care can shift the whole mood of the day.';
    }
  }

  String _elementMoodLine(OhaengElement element) {
    switch (element) {
      case OhaengElement.wood:
        return 'Growing, creative, and ready to begin';
      case OhaengElement.fire:
        return 'Warm, expressive, and full of spark';
      case OhaengElement.earth:
        return 'Grounded, steady, and quietly supportive';
      case OhaengElement.metal:
        return 'Clear, disciplined, and composed';
      case OhaengElement.water:
        return 'Calm, intuitive, and reflective';
    }
  }

  _ElementInsight _elementInsight(OhaengElement element) {
    switch (element) {
      case OhaengElement.wood:
        return const _ElementInsight(
          title: 'Wood (木) · The Creative Pioneer',
          shortLabel: 'Wood',
          emoji: '🌱',
          color: Color(0xFF8DB63F),
          deepColor: Color(0xFF5C8E1A),
          labelColor: Color(0xFF47661D),
          description:
              'You are growth-oriented and full of vitality. You love starting new projects and pushing boundaries.',
          traits: 'Growth-oriented, vital, and always ready to begin.',
          strengths: 'Strong leadership, creativity, and a pioneering spirit.',
          challenges:
              'Can become stubborn or easily frustrated when things do not go as planned.',
          wellnessStrategy:
              '"Be like Water." Practice flexibility with stretching and morning walks in nature to release tension.',
        );
      case OhaengElement.fire:
        return const _ElementInsight(
          title: 'Fire (火) · The Passionate Expresser',
          shortLabel: 'Fire',
          emoji: '🔥',
          color: Color(0xFFE45B2C),
          deepColor: Color(0xFFBF3B14),
          labelColor: Color(0xFF9B2F14),
          description:
              'You are sociable, bright, and energetic. You light up the room but can burn out if you overextend yourself.',
          traits: 'Sociable, expressive, bright, and energetically magnetic.',
          strengths:
              'Charisma, honesty, and positive energy that spreads fast.',
          challenges:
              'Prone to emotional fluctuations, overheating, anxiety, or heart-restlessness.',
          wellnessStrategy:
              '"Stay Cool." Use cooling meditations and sip Omija tea or herbal infusions to calm inner heat.',
        );
      case OhaengElement.earth:
        return const _ElementInsight(
          title: 'Earth (土) · The Reliable Supporter',
          shortLabel: 'Earth',
          emoji: '⛰',
          color: Color(0xFFE0A23B),
          deepColor: Color(0xFFB9781B),
          labelColor: Color(0xFF8D5813),
          description:
              'You are stable, nurturing, and trustworthy. You often hold others together, but that can turn into decision fatigue.',
          traits: 'Stable, caring, dependable, and naturally grounding.',
          strengths: 'Patience, empathy, and strong emotional endurance.',
          challenges:
              'Can overthink, absorb stress, and feel it in digestion or heaviness.',
          wellnessStrategy:
              '"Ground Yourself." Simplify your thoughts and reconnect through soil, earthing, or slow steady walks.',
        );
      case OhaengElement.metal:
        return const _ElementInsight(
          title: 'Metal (金) · The Sharp Idealist',
          shortLabel: 'Metal',
          emoji: '⚙',
          color: Color(0xFF9A9CA8),
          deepColor: Color(0xFF727584),
          labelColor: Color(0xFF5E6271),
          description:
              'You are logical, clean-cut, and principled. You value justice, but perfectionism can make you too hard on yourself and others.',
          traits: 'Logical, structured, principled, and clean in judgment.',
          strengths: 'Decisiveness, loyalty, and disciplined thinking.',
          challenges:
              'Can lean toward perfectionism, melancholy, or respiratory sensitivity.',
          wellnessStrategy:
              '"Let it Flow." Practice deep abdominal breathing and release the urge to control every detail.',
        );
      case OhaengElement.water:
        return const _ElementInsight(
          title: 'Water (水) · The Wise Flow',
          shortLabel: 'Water',
          emoji: '💧',
          color: Color(0xFF5B9FD0),
          deepColor: Color(0xFF3477A8),
          labelColor: Color(0xFF2E6793),
          description:
              'You are flexible, intuitive, and wise. You adapt well, but fear can sometimes leave you feeling lost or frozen.',
          traits: 'Intuitive, adaptive, observant, and quietly deep.',
          strengths: 'Insight, flexibility, resilience, and quiet wisdom.',
          challenges:
              'May feel cold, anxious, or stuck in fear when energy drops.',
          wellnessStrategy:
              '"Keep the Warmth." Use warm baths, ginger tea, and gentle rituals to stay motivated and grounded.',
        );
    }
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({
    required this.icon,
    required this.title,
    required this.description,
    this.backgroundColor = Colors.white,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF789288)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
}

class _AssistantMessage {
  const _AssistantMessage({required this.content, required this.isUser});

  final String content;
  final bool isUser;
}

class _ElementInsight {
  const _ElementInsight({
    required this.title,
    required this.shortLabel,
    required this.emoji,
    required this.color,
    required this.deepColor,
    required this.labelColor,
    required this.description,
    required this.traits,
    required this.strengths,
    required this.challenges,
    required this.wellnessStrategy,
  });

  final String title;
  final String shortLabel;
  final String emoji;
  final Color color;
  final Color deepColor;
  final Color labelColor;
  final String description;
  final String traits;
  final String strengths;
  final String challenges;
  final String wellnessStrategy;
}

class _InsightDetail extends StatelessWidget {
  const _InsightDetail({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 14,
          height: 1.62,
          color: emphasize ? const Color(0xFF2C2C2C) : const Color(0xFF4A4238),
        ) ??
        TextStyle(
          fontSize: 14,
          height: 1.62,
          color: emphasize ? const Color(0xFF2C2C2C) : const Color(0xFF4A4238),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            TextSpan(
              text: '$label: ',
              style: baseStyle.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3A342E),
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _AssistantMascot extends StatefulWidget {
  const _AssistantMascot({required this.isThinking, this.compact = false});

  final bool isThinking;
  final bool compact;

  @override
  State<_AssistantMascot> createState() => _AssistantMascotState();
}

class _AssistantMascotState extends State<_AssistantMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.isThinking) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AssistantMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isThinking && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isThinking && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 88.0 : 170.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final floatY = widget.isThinking ? -8 * _controller.value : 0.0;
        final glow = widget.isThinking
            ? 0.24 + (0.12 * _controller.value)
            : 0.18;

        return Transform.translate(
          offset: Offset(0, floatY),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8EB), Color(0xFFF0E1C5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF0C86C).withValues(alpha: glow),
                      blurRadius: widget.compact ? 24 : 40,
                      spreadRadius: widget.compact ? 2 : 6,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(widget.compact ? 10 : 16),
                child: ClipOval(
                  child: Image.asset(
                    'assets/assistant_cat.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _AssistantMascotFallback(compact: widget.compact);
                    },
                  ),
                ),
              ),
              if (widget.isThinking) ...[
                const SizedBox(height: 10),
                Text(
                  widget.compact ? 'thinking...' : 'HanBit is thinking...',
                  style: TextStyle(
                    fontSize: 14,
                    color: _globalSecondaryTextColor,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AssistantMascotFallback extends StatelessWidget {
  const _AssistantMascotFallback({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF2CC), Color(0xFFF4D37B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Text(
          compact ? '🐱' : '🐱✨',
          style: TextStyle(fontSize: compact ? 34 : 58),
        ),
      ),
    );
  }
}

class _HanjiPatternPainter extends CustomPainter {
  const _HanjiPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final specklePaint = Paint()
      ..color = const Color(0xFFBDAE92).withOpacity(0.08)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final wavePaint = Paint()
      ..color = const Color(0xFFD8CAB2).withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (double y = 36; y < size.height; y += 52) {
      for (double x = 18; x < size.width; x += 42) {
        final offset = ((x + y) % 3) * 3;
        canvas.drawPoints(ui.PointMode.points, [
          Offset(x + offset, y),
          Offset(x + 10 + offset, y + 8),
          Offset(x - 4 + offset, y + 16),
        ], specklePaint);
      }
    }

    for (double y = 80; y < size.height; y += 180) {
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= size.width; x += 40) {
        path.quadraticBezierTo(x + 20, y - 10, x + 40, y);
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ElementOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final orbitPaint = Paint()
      ..color = const Color(0xFFCDBEA7).withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final flowPaint = Paint()
      ..color = const Color(0xFFE6DAC5).withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, 122, orbitPaint);

    final path = Path()
      ..moveTo(center.dx, center.dy - 122)
      ..quadraticBezierTo(
        center.dx + 94,
        center.dy - 84,
        center.dx + 118,
        center.dy - 22,
      )
      ..quadraticBezierTo(
        center.dx + 102,
        center.dy + 90,
        center.dx + 56,
        center.dy + 112,
      )
      ..quadraticBezierTo(
        center.dx - 18,
        center.dy + 138,
        center.dx - 58,
        center.dy + 112,
      )
      ..quadraticBezierTo(
        center.dx - 118,
        center.dy + 76,
        center.dx - 118,
        center.dy - 18,
      )
      ..quadraticBezierTo(
        center.dx - 92,
        center.dy - 92,
        center.dx,
        center.dy - 122,
      );
    canvas.drawPath(path, flowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
