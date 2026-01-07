import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_preview_page.dart';
import 'api_service.dart';



// ===== LOKASI =====
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// ===== STORAGE =====
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'history_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  // ================= FORM =================
  final namaController = TextEditingController();
  final nimController = TextEditingController();
  final kelasController = TextEditingController();

  String? jenisKelamin; // <-- AWALNYA KOSONG

  // ================= KAMERA =================
  XFile? capturedImage;

  // ================= LOKASI =================
  Position? currentPosition;
  String locationText = "Lokasi belum diambil";
  double? distance;

  final double campusLat = -8.689348843504257; 
  final double campusLng = 115.23775759417019;

  // ================= LOGOUT =================
  void showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tidak"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text("Ya"),
          ),
        ],
      ),
    );
  }

  // ================= KAMERA (PREVIEW DULU) =================
  Future<void> openCameraPreview() async {
    final cameras = await availableCameras();

    //PILIH KAMERA DEPAN
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    final image = await Navigator.push<XFile?>(
      context,
      MaterialPageRoute(
        builder: (_) => CameraPreviewPage(camera: frontCamera),
      ),
    );

    if (image != null) {
      setState(() => capturedImage = image);
    }
  }


  // ================= LOKASI =================
  Future<void> getLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    final place = placemarks.first;

    // ✅ HITUNG JARAK DI SINI
    final calculatedDistance = Geolocator.distanceBetween(
      campusLat,
      campusLng,
      position.latitude,
      position.longitude,
    );

    setState(() {
      currentPosition = position;
      distance = calculatedDistance; // <-- ini penting
      locationText =
          "${place.street}, ${place.subLocality}, ${place.locality}";
    });
  }


  bool isInsideCampus(Position pos) {
    final distance = Geolocator.distanceBetween(
      campusLat,
      campusLng,
      pos.latitude,
      pos.longitude,
    );
    return distance <= 75;
  }

  bool isFormValid() {
    return namaController.text.isNotEmpty &&
        nimController.text.isNotEmpty &&
        kelasController.text.isNotEmpty &&
        jenisKelamin != null &&
        currentPosition != null;
  }

  // ================= SUBMIT =================
  void submitAttendance() async {
  final prefs = await SharedPreferences.getInstance();

  final data = {
    "nama": namaController.text,
    "nim": nimController.text,
    "kelas": kelasController.text,
    "jenis_kelamin": jenisKelamin,
    "lokasi": locationText,
    "waktu": DateTime.now().toString(),
  };

  final success = await ApiService.sendAttendance(data);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Absensi berhasil dikirim ke server"),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Gagal mengirim ke server, disimpan lokal"),
        backgroundColor: Colors.orange,
      ),
    );
  }


  final userEmail = prefs.getString('current_user');

  if (userEmail == null) {
    showPopup(
      "Error",
      "User tidak ditemukan, silakan login ulang",
      true,
    );
    return;
  }

  final historyKey = "attendance_history_$userEmail";
  final history = prefs.getStringList(historyKey) ?? [];

  history.add(jsonEncode(data));

  await prefs.setStringList(historyKey, history);

  showPopup(
    "Berhasil",
    "Absensi berhasil disimpan",
    false,
  );

}


  void showPopup(String title, String msg, bool error) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title,
            style: TextStyle(color: error ? Colors.red : Colors.green)),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // ===================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF044D30),
        title: const Text("Absensi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: showLogoutDialog,
          ),
        ],
      ),
      body: SafeArea( 
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100), // SPACE BAWAH
          child: Column(
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: "Nama"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nimController,
                decoration: const InputDecoration(labelText: "NIM"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: kelasController,
                decoration: const InputDecoration(labelText: "Kelas"),
              ),
              const SizedBox(height: 12),

              // ===== DROPDOWN JENIS KELAMIN =====
              DropdownButtonFormField<String>(
                value: jenisKelamin,
                hint: const Text("Pilih Jenis Kelamin"),
                items: const [
                  DropdownMenuItem(value: 'Laki-Laki', child: Text('Laki-Laki')),
                  DropdownMenuItem(
                      value: 'Perempuan', child: Text('Perempuan')),
                ],
                onChanged: (v) => setState(() => jenisKelamin = v),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: getLocation,
                icon: const Icon(Icons.location_on),
                label: const Text("Ambil Lokasi"),
              ),
              Text(locationText),

              // ===== TAMPILKAN JARAK KE KAMPUS =====
              if (distance != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    "Jarak ke kampus: ${distance!.toStringAsFixed(1)} meter",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: openCameraPreview,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Ambil Foto"),
              ),

              if (capturedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child:
                      Image.file(File(capturedImage!.path), height: 200),
                ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  // CEK FORM KOSONG
                  if (!isFormValid()) {
                    showPopup(
                      "Data Belum Lengkap",
                      "Tolong isi seluruh data",
                      true,
                    );
                    return;
                  }

                  // CEK LOKASI DI LUAR KAMPUS
                  if (!isInsideCampus(currentPosition!)) {
                    showPopup(
                      "Lokasi Tidak Valid",
                      "Anda berada di luar kampus, lakukan absensi di kelas",
                      true,
                    );
                    return;
                  }

                  // JIKA AMAN → SIMPAN
                  submitAttendance();
                },
                child: const Text("Submit Absensi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
