import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void logout(BuildContext context) {
    // Hapus session user kalau pakai penyimpanan lokal (misal SharedPreferences)

    // Kembali ke halaman login
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}
