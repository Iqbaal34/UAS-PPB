import 'package:flutter/material.dart';
import 'mysqlutils.dart';
import 'loginpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController identitasNamaController = TextEditingController();

  String errorMessage = '';
  String successMessage = '';

  void registerUser() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final identitasNama = identitasNamaController.text.trim();

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty || identitasNama.isEmpty) {
      setState(() {
        errorMessage = 'Semua field harus diisi!';
        successMessage = '';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Password tidak sama!';
        successMessage = '';
      });
      return;
    }

    final conn = await MysqlUtils.getConnection();
    try {
      // Cek apakah username sudah ada
      var check = await conn.query(
        'SELECT * FROM users WHERE username = ?',
        [username],
      );

      if (check.isNotEmpty) {
        setState(() {
          errorMessage = 'Username sudah digunakan.';
          successMessage = '';
        });
        return;
      }

      // Simpan data ke database
      await conn.query(
        'INSERT INTO users (username, password, identitasnama, konfirmasi, status) VALUES (?, ?, ?, ?, ?)',
        [username, password, identitasNama, 'belum', 'aktif'],
      );

      setState(() {
        successMessage = 'Registrasi berhasil! Silakan login.';
        errorMessage = '';
      });

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Loginpage()),
        );
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        successMessage = '';
      });
    } finally {
      await conn.close();
    }
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
                height: 200,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: const Text(
                  'Register',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 30, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 40),
              Column(
                children: [
                  TextField(
                    controller: usernameController,
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
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: identitasNamaController,
                    decoration: InputDecoration(
                      labelText: 'Identitas Nama',
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (errorMessage.isNotEmpty)
                    Text(errorMessage, style: const TextStyle(color: Colors.red)),
                  if (successMessage.isNotEmpty)
                    Text(successMessage, style: const TextStyle(color: Colors.green)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sudah punya akun?", style: TextStyle(fontFamily: 'Poppins')),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Loginpage()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
