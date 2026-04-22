import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/reco_page.dart';
import 'pages/signup_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }
  runApp(const HanBit());
}

class HanBit extends StatelessWidget {
  const HanBit({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HanBit Wellness',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.gaeguTextTheme(
          GoogleFonts.notoSansKrTextTheme(),
        ),
      ),
      home: const _AuthGate(),
      routes: {
        HomePage.routeName: (context) => const HomePage(firstName: 'Guest'),
        RecoPage.routeName: (context) => const RecoPage(),
        SignUpPage.routeName: (context) => const SignUpPage(),
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LaunchScreen();
        }

        final user = snapshot.data;
        if (user != null) {
          return const HomePage(firstName: 'Member');
        }

        return const LoginPage();
      },
    );
  }
}

class _LaunchScreen extends StatelessWidget {
  const _LaunchScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F1EA),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF789288))),
    );
  }
}
