import 'package:firebase_core/firebase_core.dart';
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
      home: const LoginPage(),
      routes: {
        HomePage.routeName: (context) => const HomePage(firstName: 'Guest'),
        RecoPage.routeName: (context) => const RecoPage(),
        SignUpPage.routeName: (context) => const SignUpPage(),
      },
    );
  }
}
