
import 'package:flutter/material.dart';
import 'package:perpustakaan/homepage.dart';
import 'package:perpustakaan/settingpage.dart';
import 'notifiers/navbar_notifiers.dart';
import 'loginpage.dart';
import 'daftarbuku.dart';
import 'peminjaman.dart';

class RouteDestination {
  static void GoToHome(BuildContext context) {
    navIndexNotifier.value = 0;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
  }

  static void GoToBuku(BuildContext context) {
    navIndexNotifier.value = 1;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DaftarBuku()),
      );
  }

  static void GoToPeminjaman(BuildContext context) {
    navIndexNotifier.value = 2;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PeminjamanPage()),
    );
  }

  static void GoToSetting(BuildContext context) {
    navIndexNotifier.value = 3;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }
}
