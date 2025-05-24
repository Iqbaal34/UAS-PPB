import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class PinjamBukuPage extends StatefulWidget {
  final Map<String, dynamic> buku;
  const PinjamBukuPage({super.key, required this.buku});

  @override
  State<PinjamBukuPage> createState() => _PinjamBukuPageState();
}

class _PinjamBukuPageState extends State<PinjamBukuPage> {
  List<Map<String, dynamic>> userList = [];
  String? selectedNim;
  String? selectedNama;
  int qty = 1;
  DateTime? tglPinjam;
  DateTime? tglKembali;
  bool isLoadingUsers = true;

  final themeColor = const Color(0xFF4A4A6A);
  final accentColor = const Color(0xFF8E97FD);

  @override
  void initState() {
    super.initState();
    fetchActiveUsers();
  }

  Future<void> fetchActiveUsers() async {
    setState(() => isLoadingUsers = true);
    try {
      final response = await http.get(
        Uri.parse('http://192.168.58.179/phpPerpus/get_akun_aktif.php'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            userList = List<Map<String, dynamic>>.from(data['anggota']);
            isLoadingUsers = false;
          });
        } else {
          setState(() {
            userList = [];
            isLoadingUsers = false;
          });
        }
      } else {
        setState(() {
          userList = [];
          isLoadingUsers = false;
        });
      }
    } catch (e) {
      setState(() {
        userList = [];
        isLoadingUsers = false;
      });
    }
  }

  Future<void> submitPeminjamanApi() async {
    if (selectedNim == null ||
        selectedNama == null ||
        qty == 0 ||
        tglPinjam == null ||
        tglKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi semua data!")),
      );
      return;
    }

    final data = {
      'nim': selectedNim,
      'nama': selectedNama,
      'idbuku': widget.buku['id'],
      'namabuku': widget.buku['title'],
      'qty': qty,
      'tglpinjam': DateFormat('yyyy-MM-dd').format(tglPinjam!),
      'tglkembali': DateFormat('yyyy-MM-dd').format(tglKembali!),
      'status': 'tidak aktif',
    };

    final url = Uri.parse('http://192.168.58.179/phpPerpus/peminjaman.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resData['message'] ?? "Berhasil")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resData['message'] ?? "Gagal")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void goToDaftarAnggota() {
    Navigator.pushNamed(context, '/daftarAnggota');
  }

  @override
  Widget build(BuildContext context) {
    final buku = widget.buku;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        title: Text(
          "Pinjam Buku",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 20,  // dikurangi
          ),
        ),
        backgroundColor: themeColor,
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20), // padding dikurangi
        child: isLoadingUsers
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Detail Buku Card
                    Center(
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14), // radius dikurangi
                        ),
                        elevation: 5,
                        shadowColor: accentColor.withOpacity(0.12),
                        child: Padding(
                          padding: const EdgeInsets.all(16), // padding dikurangi
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10), // dikurangi
                                child: Image.network(
                                  buku['image'] ?? 'https://via.placeholder.com/80x110',
                                  width: 75,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16), // dikurangi
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    buku['title'] ?? '',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16, // dikurangi
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text("Pengarang: ${buku['author']}", style: GoogleFonts.poppins(fontSize: 12)),
                                  Text("Penerbit: ${buku['publisher']}", style: GoogleFonts.poppins(fontSize: 12)),
                                  Text("Tahun: ${buku['year']}", style: GoogleFonts.poppins(fontSize: 12)),
                                  Text("Stok: ${buku['stock']}", style: GoogleFonts.poppins(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dropdown NIM
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Pilih NIM",
                        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14), // padding dikurangi
                      ),
                      value: selectedNim,
                      items: userList
                          .map((user) => DropdownMenuItem<String>(
                                value: user['nim'],
                                child: Text('${user['nim']} - ${user['nama']}', style: GoogleFonts.poppins(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedNim = value;
                          selectedNama = userList.firstWhere((u) => u['nim'] == selectedNim)['nama'];
                        });
                      },
                    ),
                    const SizedBox(height: 18),

                    // Jumlah Buku
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Jumlah Buku",
                        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() {
                          qty = int.tryParse(val) ?? 1;
                        });
                      },
                      initialValue: qty.toString(),
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    const SizedBox(height: 18),

                    // Pilih Tanggal Pinjam
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      icon: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => tglPinjam = picked);
                        }
                      },
                      label: Text(
                        tglPinjam == null
                            ? "Pilih Tanggal Pinjam"
                            : "Tgl Pinjam: ${DateFormat('yyyy-MM-dd').format(tglPinjam!)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pilih Tanggal Kembali
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      icon: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => tglKembali = picked);
                        }
                      },
                      label: Text(
                        tglKembali == null
                            ? "Pilih Tanggal Kembali"
                            : "Tgl Kembali: ${DateFormat('yyyy-MM-dd').format(tglKembali!)}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tombol Ajukan Peminjaman
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
                          elevation: 4,
                        ),
                        onPressed: submitPeminjamanApi,
                        child: const Text("Ajukan Peminjaman"),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Link daftar anggota
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Belum daftar anggota?",
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: goToDaftarAnggota,
                            child: Text(
                              "Klik di sini untuk daftar",
                              style: GoogleFonts.poppins(
                                color: accentColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
