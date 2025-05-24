import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class DaftarAnggotaPage extends StatefulWidget {
  const DaftarAnggotaPage({super.key});

  @override
  State<DaftarAnggotaPage> createState() => _DaftarAnggotaPageState();
}

class _DaftarAnggotaPageState extends State<DaftarAnggotaPage> {
  final _formKey = GlobalKey<FormState>();
  final nimCtrl = TextEditingController();
  final namaCtrl = TextEditingController();
  final tempatLahirCtrl = TextEditingController();
  final alamatCtrl = TextEditingController();
  final kelasCtrl = TextEditingController();
  final jenisKelaminCtrl = TextEditingController(); // <--- Tambah controller baru
  bool _isLoading = false;

  Future<void> submit() async {
    setState(() => _isLoading = true);
    final res = await http.post(
      Uri.parse('http://192.168.58.179/phpPerpus/daftaranggota.php'),
      body: {
        'nim': nimCtrl.text,
        'nama': namaCtrl.text,
        'ttl': tempatLahirCtrl.text,
        'jenis_kelamin': jenisKelaminCtrl.text,
        'alamat': alamatCtrl.text,
        'kelas': kelasCtrl.text,
        'status': 'nonaktif',
      },
    );
    setState(() => _isLoading = false);

    final data = json.decode(res.body);
    if (data['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pendaftaran berhasil. Tunggu aktivasi dari admin."),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal daftar: ${data['message']}")),
      );
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? type,
    IconData? icon,
    String? Function(String?)? validator, // <--- biar bisa custom validator
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null ? Icon(icon, color: const Color(0xFF8E97FD)) : null,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      style: GoogleFonts.poppins(),
      validator: validator ??
          (value) => value!.isEmpty ? '$label tidak boleh kosong' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Daftar Anggota",
          style: GoogleFonts.poppins(
            color: const Color(0xFF4A4A6A),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF4A4A6A)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 18),
              buildTextField(
                "NIM",
                nimCtrl,
                type: TextInputType.number,
                icon: Icons.confirmation_number_rounded,
              ),
              const SizedBox(height: 18),
              buildTextField("Nama", namaCtrl, icon: Icons.person_outline),
              const SizedBox(height: 18),
              buildTextField(
                "Tempat Lahir",
                tempatLahirCtrl,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 18),
              buildTextField(
                "Jenis Kelamin (Laki/Perempuan)",
                jenisKelaminCtrl,
                icon: Icons.wc_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jenis kelamin tidak boleh kosong';
                  }
                  if (value != "Laki" && value != "Perempuan") {
                    return 'Isi dengan "Laki" atau "Perempuan"';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              buildTextField("Alamat", alamatCtrl, icon: Icons.home_outlined),
              const SizedBox(height: 18),
              buildTextField("Kelas", kelasCtrl, icon: Icons.class_outlined),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            submit();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E97FD),
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Daftar"),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                "Pastikan data yang kamu masukkan sudah benar sebelum daftar.",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
