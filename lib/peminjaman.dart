import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'user_prefs.dart';
import 'navbar_widget.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  List<Map<String, dynamic>> peminjamanList = [];
  bool isLoading = true;
  String? nimUser;

  final themeColor = const Color(0xFF4A4A6A);
  final bgColor = const Color(0xFFF0F4FA);

  @override
  void initState() {
    super.initState();
    loadNimAndFetch();
  }

  Future<void> loadNimAndFetch() async {
    nimUser = await UserPrefs.getUserNim();

    if (nimUser == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    await fetchPeminjaman();
  }

  Future<void> fetchPeminjaman() async {
    if (nimUser == null) return;

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('http://192.168.58.179/phpPerpus/get_peminjaman.php?nim=$nimUser');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            peminjamanList = List<Map<String, dynamic>>.from(data['peminjaman']);
            isLoading = false;
          });
        } else {
          setState(() {
            peminjamanList = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          peminjamanList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        peminjamanList = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyleTitle = GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 17,
      color: themeColor,
    );

    final textStyleSubtitle = GoogleFonts.poppins(
      fontSize: 13,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text(
          "Daftar Peminjaman",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : nimUser == null
                ? Center(child: Text("Silakan login terlebih dahulu.", style: textStyleSubtitle))
                : peminjamanList.isEmpty
                    ? Center(
                        child: Text(
                          "Belum ada data peminjaman.",
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: peminjamanList.length,
                        itemBuilder: (context, index) {
                          final p = peminjamanList[index];
                          Color statusColor = (p['status']?.toString().toLowerCase() == 'aktif')
                              ? Colors.green
                              : Colors.red;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['namabuku'] ?? '-', style: textStyleTitle),
                                  const SizedBox(height: 8),
                                  Text("Jumlah: ${p['qty'] ?? '-'}", style: textStyleSubtitle),
                                  Text("Tanggal Pinjam: ${p['tglpinjam'] ?? '-'}", style: textStyleSubtitle),
                                  Text("Tanggal Kembali: ${p['tglkembali'] ?? '-'}", style: textStyleSubtitle),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text("Status: ",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text(
                                        p['status'] ?? '-',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
