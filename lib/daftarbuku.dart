import 'package:flutter/material.dart';
import 'package:perpustakaan/mysqlutils.dart';

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

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    final conn = await MysqlUtils.getConnection();
    final result = await conn.query('SELECT * FROM databuku');
    await conn.close();

    List<Map<String, dynamic>> fetched = [];
    for (var row in result) {
      fetched.add({
        'id': row['idbuku'],
        'title': row['namabuku'],
        'image': row['image'],
        'author': row['pengarang'],
        'publisher': row['penerbit'],
        'year': row['tahunterbit'],
        'stock': row['stok'],
      });
    }

    setState(() {
      books = fetched;
      applyFilter();
      isLoading = false;
    });
  }

  void applyFilter() {
    List<Map<String, dynamic>> temp = [...books];
    if (searchCtrl.text.isNotEmpty) {
      temp = temp.where((b) => b['title']
          .toString()
          .toLowerCase()
          .contains(searchCtrl.text.toLowerCase())).toList();
    }
    setState(() {
      filteredBooks = temp;
    });
  }

  void deleteBook(int id) async {
    final conn = await MysqlUtils.getConnection();
    await conn.query('DELETE FROM databuku WHERE idbuku = ?', [id]);
    await conn.close();
    fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Daftar Buku', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tambah buku (belum ada halaman AddBook)
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    onChanged: (_) => applyFilter(),
                    decoration: InputDecoration(
                      hintText: "Cari judul buku...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        final b = filteredBooks[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  b['image'] ?? 'https://via.placeholder.com/50',
                                  width: 50,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(b['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text("Pengarang: ${b['author']}"),
                                    Text("Penerbit: ${b['publisher']}"),
                                    Text("Tahun: ${b['year']}"),
                                    Text("Stok: ${b['stock']}"),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                    onPressed: () {
                                      // Tambahkan navigasi ke edit page jika ada
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => deleteBook(b['id']),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
