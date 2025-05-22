import 'package:flutter/material.dart';
import 'package:perpustakaan/mysqlutils.dart';

class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginPageState();
}

class _LoginPageState extends State<Loginpage> {
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final conn = await MysqlUtils.getConnection();
    final result = await conn.query(
      'SELECT * FROM akun WHERE username = ? AND password = ?',
      [usernameCtrl.text.trim(), passwordCtrl.text.trim()],
    );
    await conn.close();

    if (result.isNotEmpty) {
      final user = result.first.fields;
      if (user['status'] == 'aktif') {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          errorMessage = "Akun belum dikonfirmasi oleh admin.";
        });
      }
    } else {
      setState(() {
        errorMessage = "Username atau password salah.";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/login-page-banner.webp',
                height: 250,
              ),
              const SizedBox(height: 100),
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Login Perpustakaan',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: double.infinity,
                child: Text(
                  'Silakan login untuk melanjutkan',
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register'); // Ganti sesuai rute halaman register kamu
                    },
                    child: const Text(
                      'Belum punya akun? Register here',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
