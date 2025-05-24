import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'navbar_widget.dart';
import 'route_destination.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> books = [];
  bool isLoading = true;
  int lowStockCount = 0;
  int highStockCount = 0;
  final TextEditingController searchCtrl = TextEditingController();
  List<Map<String, dynamic>> allBooks = [];

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
      final response = await http.get(Uri.parse('http://192.168.58.179/phpPerpus/daftarbuku.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> rawBooks = data['books'];
          int lowCount = 0;
          int highCount = 0;

          List<Map<String, dynamic>> fetchedBooks = rawBooks.map<Map<String, dynamic>>((item) {
            int stok = int.tryParse(item['stock'].toString()) ?? 0;
            if (stok < 15) {
              lowCount++;
            } else {
              highCount++;
            }
            return {
              'id': item['idbuku'],
              'name': item['title'],
              'category': item['author'], // Bisa sesuaikan kategori kalau ada
              'stock': stok,
              'image': item['image'] ?? '',
            };
          }).toList();

          setState(() {
            books = fetchedBooks;
            allBooks = fetchedBooks;
            lowStockCount = lowCount;
            highStockCount = highCount;
            isLoading = false;
          });
        } else {
          setState(() {
            books = [];
            allBooks = [];
            lowStockCount = 0;
            highStockCount = 0;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          books = [];
          allBooks = [];
          lowStockCount = 0;
          highStockCount = 0;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        books = [];
        allBooks = [];
        lowStockCount = 0;
        highStockCount = 0;
        isLoading = false;
      });
    }
  }

  void applyFilter() {
    final query = searchCtrl.text.toLowerCase();
    setState(() {
      if (query.isNotEmpty) {
        books = allBooks.where((b) {
          return b['name'].toString().toLowerCase().contains(query);
        }).toList();
      } else {
        books = allBooks;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle headerStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: themeColor,
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/300'),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Perpustakaan Digital',
                    style: GoogleFonts.poppins(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.notifications_none_rounded, color: themeColor),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: themeColor),
                    onPressed: () {
                      RouteDestination.GoToSetting(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: searchCtrl,
                onChanged: (_) => applyFilter(),
                decoration: InputDecoration(
                  hintText: "Cari buku...",
                  prefixIcon: Icon(Icons.search, color: accentColor),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                style: GoogleFonts.poppins(color: themeColor),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatCard(highStockCount.toString(), "Stok Tinggi", Icons.trending_up, accentColor),
                  _buildStatCard(lowStockCount.toString(), "Stok Rendah", Icons.trending_down, Colors.redAccent),
                  _buildStatCard(books.length.toString(), "Total Buku", Icons.book_outlined, themeColor),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Buku",
                    style: headerStyle,
                  ),
                  GestureDetector(
                    onTap: () {
                      RouteDestination.GoToBuku(context);
                    },
                    child: Text(
                      "Lihat Semua",
                      style: GoogleFonts.poppins(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : books.isEmpty
                        ? Center(
                            child: Text(
                              "Tidak ada buku ditemukan.",
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: books.length,
                            itemBuilder: (context, index) {
                              final buku = books[index];
                              final int stock = buku['stock'] ?? 0;
                              final bool isAvailable = stock > 15;

                              return _buildBookItem(
                                buku['name'].toString(),
                                buku['category'].toString(),
                                "Stok: $stock",
                                buku['image'].toString().isNotEmpty
                                    ? buku['image'].toString()
                                    : 'https://via.placeholder.com/50',
                                isAvailable,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color iconColor) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: iconColor),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildBookItem(
    String title,
    String author,
    String stockText,
    String imgUrl,
    bool isAvailable,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imgUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.book, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(author, style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                isAvailable ? Icons.trending_up : Icons.trending_down,
                color: isAvailable ? Colors.green : Colors.red,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(stockText, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}
