import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = "https://contoh-api.com";

  // ================== KIRIM ABSENSI ==================
  static Future<bool> sendAttendance(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/attendance"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
