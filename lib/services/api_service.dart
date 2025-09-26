import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/paket.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = "https://fa9005b66fd7.ngrok-free.app/api";

  // =======================
  // 📌 Paket
  // =======================
  // api_service.dart
  static Future<bool> addPaket(
    String nama,
    String jenis,
    String alamat,
    String status,
    double lat,
    double lng,
    File? foto,
  ) async {
    try {
      var uri = Uri.parse("$baseUrl/add_paket.php");

      var request = http.MultipartRequest("POST", uri);
      request.fields['nama_penerima'] = nama;
      request.fields['jenis_paket'] = jenis;
      request.fields['alamat_penerima'] = alamat;
      request.fields['status'] = status;
      request.fields['lat'] = lat.toString();
      request.fields['lng'] = lng.toString();

      if (foto != null) {
        request.files.add(await http.MultipartFile.fromPath("foto", foto.path));
      }

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print("Error addPaket: $e");
      return false;
    }
  }

  static Future<List<Paket>> getPaket() async {
    final url = Uri.parse("$baseUrl/get_paket.php");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body["success"] == true) {
        final List data = body["data"];
        return data.map((json) => Paket.fromJson(json)).toList();
      } else {
        throw Exception(body["message"]);
      }
    } else {
      throw Exception("Failed to load data");
    }
  }

  // Hapus paket
  static Future<void> deletePaket(int id) async {
    final response = await http.post(
      Uri.parse("$baseUrl/delete_paket.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id}),
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal hapus paket (code: ${response.statusCode})");
    }

    final res = json.decode(response.body);
    if (res["success"] != true) {
      throw Exception("Hapus gagal: ${res["message"]}");
    }
  }

  // Update paket (status + lokasi baru)
  static Future<void> updatePaket(
    int id,
    String status,
    double lat,
    double lng,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update_paket.php"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"id": id, "status": status, "lat": lat, "lng": lng}),
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal update paket (code: ${response.statusCode})");
    }

    final res = json.decode(response.body);
    if (res["success"] != true) {
      throw Exception("Update gagal: ${res["message"]}");
    }
  }

  // Register user
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/register.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password, "role": role}),
    );
    return jsonDecode(response.body);
  }

  // Login user
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateFoto(int id, File foto) async {
    final url = Uri.parse("$baseUrl/update_foto.php");

    var request = http.MultipartRequest("POST", url);
    request.fields["id"] = id.toString();
    request.files.add(await http.MultipartFile.fromPath("foto", foto.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseBody);
    } else {
      throw Exception("Gagal update foto");
    }
  }
}
