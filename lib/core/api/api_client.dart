import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // GET request
  Future<dynamic> get(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body); // يرجع البيانات جاهزة
    } else {
      throw Exception("Error: ${response.statusCode}"); // يرمي خطأ إذا ما نجحش
    }
  }

  // POST request
  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body), // يحوّل body لـ JSON
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error: ${response.statusCode}");
    }
  }
}
