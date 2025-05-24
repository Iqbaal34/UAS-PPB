import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'navbar_widget.dart';
import 'pinjambukupage.dart';
import 'package:google_fonts/google_fonts.dart';

class DaftarBuku extends StatefulWidget {
  const DaftarBuku({super.key});

  @override
  State<DaftarBuku> createState() => _DaftarBukuState();
}

class _DaftarBukuState extends State<DaftarBuku> {
  List<Map<String, dynamic>> books = [];
  List<Map<String, dynamic>> filteredBooks = [];
  bool isLoading = true;
  final TextEditingController searchCtrl = TextEditingController();

  final Color themeColor = const Color(0xFF4A4A6A);
  final Color accentColor = const Color(0xFF8E97FD);
  final Color bgColor = const Color(0xFFF0F4FA);

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('http://192.168.58.179/phpPerpus/daftarbuku.php'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            books = List<Map<String, dynamic>>.from(data['books']);
            applyFilter();
            isLoading = false;
          });
        } else {
          setState(() {
            books = [];
            filteredBooks = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          books = [];
          filteredBooks = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        books = [];
        filteredBooks = [];
        isLoading = false;
      });
    }
  }

  void applyFilter() {
    List<Map<String, dynamic>> temp = [...books];
    if (searchCtrl.text.isNotEmpty) {
      temp = temp.where((b) =>
        b['title'].toString().toLowerCase().contains(searchCtrl.text.toLowerCase())
      ).toList();
    }
    setState(() {
      filteredBooks = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyleTitle = GoogleFonts.poppins(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: themeColor,
    );

    final textStyleSubtitle = GoogleFonts.poppins(
      fontSize: 14,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 3,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Daftar Buku',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Search Field
                  TextField(
                    controller: searchCtrl,
                    onChanged: (_) => applyFilter(),
                    style: GoogleFonts.poppins(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Cari judul buku...",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search, color: accentColor),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: accentColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // List buku
                  Expanded(
                    child: filteredBooks.isEmpty
                        ? Center(
                            child: Text(
                              "Tidak ada buku yang ditemukan",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredBooks.length,
                            itemBuilder: (context, index) {
                              final b = filteredBooks[index];
                              final stockInt = int.tryParse(b['stock'].toString()) ?? 0;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PinjamBukuPage(buku: b),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          b['image'] ?? 'https://via.placeholder.com/80x110',
                                          width: 80,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 80,
                                            height: 110,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.book,
                                              color: Colors.grey,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(b['title'] ?? '-', style: textStyleTitle),
                                            const SizedBox(height: 8),
                                            Text("Pengarang: ${b['author'] ?? '-'}", style: textStyleSubtitle),
                                            Text("Penerbit: ${b['publisher'] ?? '-'}", style: textStyleSubtitle),
                                            Text("Tahun: ${b['year'] ?? '-'}", style: textStyleSubtitle),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Stok: ${b['stock'] ?? '0'}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: stockInt == 0 ? Colors.red : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
