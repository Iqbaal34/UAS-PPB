import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'package:perpustakaan/mysqlutils.dart';
import 'mysqlutils.dart';

class Peminjaman extends StatefulWidget {
  const Peminjaman({super.key});

  @override
  State<Peminjaman> createState() => _PeminjamanState();
}

class _PeminjamanState extends State<Peminjaman> {
  List<Map<String, dynamic>> bukuList = [];
  List<Map<String, dynamic>> userList = [];
  int? selectedIdbuku;
  String? selectedNamabuku;
  String? selectedNim;
  String? selectedNama;
  DateTime? tglPinjam;
  DateTime? tglKembali;

  Future<void> fetchData() async {
    final conn = await MysqlUtils.getConnection();

    // Buku
    var bukuResult = await conn.query('SELECT idbuku, namabuku FROM buku');
    bukuList =
        bukuResult
            .map(
              (row) => {'idbuku': row['idbuku'], 'namabuku': row['namabuku']},
            )
            .toList();

    // User aktif
    var userResult = await conn.query(
      'SELECT nim, nama FROM akun WHERE status = "aktif"',
    );
    userList =
        userResult
            .map((row) => {'nim': row['nim'].toString(), 'nama': row['nama']})
            .toList();

    await conn.close();
    setState(() {});
  }

  Future<void> submitPeminjaman() async {
    if (selectedIdbuku == null ||
        selectedNim == null ||
        tglPinjam == null ||
        tglKembali == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lengkapi semua data!")));
      return;
    }

    final conn = await MysqlUtils.getConnection();

    await conn.query(
      'INSERT INTO peminjaman (nim, nama, idbuku, namabuku, qty, tglpinjam, tglkembali, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        selectedNim,
        selectedNama,
        selectedIdbuku,
        selectedNamabuku,
        1,
        DateFormat('yyyy-MM-dd').format(tglPinjam!),
        DateFormat('yyyy-MM-dd').format(tglKembali!),
        'tidak aktif',
      ],
    );

    await conn.close();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Peminjaman berhasil diajukan.")),
    );

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pinjam Buku")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Pilih NIM"),
                items:
                    userList.map((user) {
                      return DropdownMenuItem(
                        value: user['nim'],
                        child: Text('${user['nim']} - ${user['nama']}'),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedNim = value as String?;
                    selectedNama =
                        userList.firstWhere(
                              (u) => u['nim'] == selectedNim,
                            )['nama']
                            as String?;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Pilih Buku"),
                items:
                    bukuList.map((buku) {
                      return DropdownMenuItem(
                        value: buku['idbuku'],
                        child: Text(buku['namabuku']),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedIdbuku = value as int;
                    selectedNamabuku =
                        bukuList.firstWhere(
                          (b) => b['idbuku'] == selectedIdbuku,
                        )['namabuku'];
                  });
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
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
                child: Text(
                  tglPinjam == null
                      ? "Pilih Tanggal Pinjam"
                      : "Tgl Pinjam: ${DateFormat('yyyy-MM-dd').format(tglPinjam!)}",
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
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
                child: Text(
                  tglKembali == null
                      ? "Pilih Tanggal Kembali"
                      : "Tgl Kembali: ${DateFormat('yyyy-MM-dd').format(tglKembali!)}",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitPeminjaman,
                child: const Text("Ajukan Peminjaman"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
