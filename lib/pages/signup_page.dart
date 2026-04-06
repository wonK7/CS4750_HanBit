import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../support/element_logic.dart';
import '../support/profile_options.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  static const routeName = '/signup';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  DateTime? _birthDate;
  String _birthDateLabel = '';
  String _birthTimeLabel = '';
  final List<String> _personalityTraits = <String>[];
  final List<String> _stressTriggers = <String>[];

  bool _isValidPassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSpecial = RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]=+;`~]',
    ).hasMatch(password);

    return hasMinLength && hasLetter && hasNumber && hasSpecial;
  }

  Future<void> _signUp() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    if (!_isValidPassword(password)) {
      _showMessage(
        'Password must be at least 8 characters and include a letter, number, and special character.',
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    if (_birthDate == null || _birthTimeLabel.isEmpty) {
      _showMessage('Please choose both your birth date and birth time.');
      return;
    }

    if (_personalityTraits.length != 3) {
      _showMessage('Please choose exactly 3 personality traits.');
      return;
    }

    if (_stressTriggers.length != 2) {
      _showMessage('Please choose exactly 2 stress patterns.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final userElement = getUserElementFromBirthdate(_birthDate!);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'birthDate': Timestamp.fromDate(_birthDate!),
            'birthTime': _birthTimeLabel,
            'userElement': formatElement(userElement),
            'symbol': displayElementIcon(userElement, '☯'),
            'personalityTraits': _personalityTraits,
            'stressTriggers': _stressTriggers,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(firstName: firstName)),
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(_messageForSignUpError(e));
    } on FirebaseException catch (e) {
      _showMessage(e.message ?? 'Firebase setup error.');
    } catch (e) {
      _showMessage('Sign up failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _birthDate = picked;
      _birthDateLabel = formatBirthDate(picked);
    });
  }

  Future<void> _pickBirthTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _birthTimeLabel = formatBirthTime(picked);
    });
  }

  void _toggleTrait(String option) {
    setState(() {
      if (_personalityTraits.contains(option)) {
        _personalityTraits.remove(option);
      } else if (_personalityTraits.length < 3) {
        _personalityTraits.add(option);
      }
    });
  }

  void _toggleStressTrigger(String option) {
    setState(() {
      if (_stressTriggers.contains(option)) {
        _stressTriggers.remove(option);
      } else if (_stressTriggers.length < 2) {
        _stressTriggers.add(option);
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Join HanBit',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 36),
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xFF789288),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: _pickBirthDate,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2C2C2C),
                    backgroundColor: Colors.white.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    _birthDateLabel.isEmpty
                        ? 'Choose Birth Date'
                        : 'Birth Date: $_birthDateLabel',
                  ),
                ),
                const SizedBox(height: 15),
                OutlinedButton(
                  onPressed: _pickBirthTime,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2C2C2C),
                    backgroundColor: Colors.white.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    _birthTimeLabel.isEmpty
                        ? 'Choose Birth Time'
                        : 'Birth Time: $_birthTimeLabel',
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Which 3 traits describe you best?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: personalityTraitOptions
                      .map((option) {
                        final selected = _personalityTraits.contains(option);
                        return FilterChip(
                          label: Text(option),
                          selected: selected,
                          onSelected: (_) => _toggleTrait(option),
                          selectedColor: const Color(0xFFE9E2D2),
                          checkmarkColor: const Color(0xFF2C2C2C),
                          side: BorderSide(
                            color: selected
                                ? const Color(0xFF789288)
                                : const Color(0xFFD8CFC1),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_personalityTraits.length}/3 selected',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF789288),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Which 2 patterns tend to throw you off most?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: stressTriggerOptions
                      .map((option) {
                        final selected = _stressTriggers.contains(option);
                        return FilterChip(
                          label: Text(option),
                          selected: selected,
                          onSelected: (_) => _toggleStressTrigger(option),
                          selectedColor: const Color(0xFFF2E8E4),
                          checkmarkColor: const Color(0xFF2C2C2C),
                          side: BorderSide(
                            color: selected
                                ? const Color(0xFFC0846B)
                                : const Color(0xFFD8CFC1),
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_stressTriggers.length}/2 selected',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF789288),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: Color(0xFF789288),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color(0xFF789288),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  obscuringCharacter: '•',
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFF789288),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Use 8+ characters with a letter, number, and special character.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF789288)),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  obscuringCharacter: '•',
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF789288),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2C),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _isLoading ? 'Creating Account...' : 'Sign Up',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to Sign In',
                    style: TextStyle(color: Color(0xFF789288), fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _messageForSignUpError(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'That email is already registered.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'weak-password':
      return 'Password is too weak.';
    case 'operation-not-allowed':
      return 'Email/Password sign-in is not enabled in Firebase Authentication.';
    default:
      return e.message ?? 'Sign up failed.';
  }
}
