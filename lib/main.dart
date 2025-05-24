import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perpustakaan/daftaranggota.dart';
import 'package:perpustakaan/homepage.dart';
import 'package:perpustakaan/loginpage.dart';
import 'package:perpustakaan/settingpage.dart';
import 'package:perpustakaan/registerpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.light,
        ),
      ),
      home: Loginpage(),
      routes: {
      '/login': (_) => const Loginpage(),
      '/home': (_) => HomePage(),
      '/settings': (_) => const SettingsPage(),
      '/register': (context) => const RegisterPage(),
      '/daftarAnggota': (context) => const DaftarAnggotaPage(),
  },
    );
  }
}

