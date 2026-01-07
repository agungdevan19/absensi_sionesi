import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // ===== DATA HISTORY =====
  List<String> history = [];

  // ✅ STEP 2.1 — DATE FILTER (WAJIB ADA)
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ===============================
  // LOAD DATA HISTORY DARI INTERNAL
  // ===============================
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('current_user');

    if (userEmail == null) {
      setState(() => history = []);
      return;
    }

    final historyKey = "attendance_history_$userEmail";

    setState(() {
      history = prefs.getStringList(historyKey) ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Absensi'),
        backgroundColor: const Color(0xFF044D30),
      ),

      // 🔽 BODY FIX
      body: Column(
        children: [

          // ===============================
          // STEP 2.2 — BUTTON PILIH TANGGAL
          // ===============================
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),
          ),

          // ===============================
          // HISTORY LIST
          // ===============================
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data absensi',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final data = jsonDecode(history[index]);
                      final waktu = DateTime.parse(data['waktu']);

                      // 🔍 FILTER PER HARI
                      if (waktu.year != selectedDate.year ||
                          waktu.month != selectedDate.month ||
                          waktu.day != selectedDate.day) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['nama'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("NIM: ${data['nim']}"),
                              Text("Kelas: ${data['kelas']}"),
                              const SizedBox(height: 4),
                              Text(
                                data['waktu'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
    );
  }
}
