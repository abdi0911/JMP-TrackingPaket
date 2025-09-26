import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddPaketScreen extends StatefulWidget {
  const AddPaketScreen({super.key});

  @override
  State<AddPaketScreen> createState() => _AddPaketScreenState();
}

class _AddPaketScreenState extends State<AddPaketScreen> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController jenisController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();

  double? latitude;
  double? longitude;
  bool isLoading = false;
  File? fotoPaket;

  final ImagePicker _picker = ImagePicker();

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        fotoPaket = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveData() async {
    if (namaController.text.isEmpty ||
        jenisController.text.isEmpty ||
        alamatController.text.isEmpty ||
        latitude == null ||
        longitude == null ||
        fotoPaket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi semua data termasuk foto")),
      );
      return;
    }

    setState(() => isLoading = true);

    bool success = await ApiService.addPaket(
      namaController.text.trim(),
      jenisController.text.trim(),
      alamatController.text.trim(),
      "diproses", // default status
      latitude!,
      longitude!,
      fotoPaket,
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Paket berhasil disimpan")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menyimpan paket")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Paket"),
        backgroundColor: Colors.blue.shade900.withOpacity(0.7),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://i.pinimg.com/736x/3c/2f/f6/3c2ff64a13c2d1f2e10819954c016b9e.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.blue.withOpacity(0.6)),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: namaController,
                  decoration: _inputDecoration("Nama Penerima"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: jenisController,
                  decoration: _inputDecoration("Jenis Paket"),
                ),
                const SizedBox(height: 16),
                // FOTO PAKET
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Ambil Foto Paket"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    if (fotoPaket != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.file(
                          fotoPaket!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: alamatController,
                  maxLines: 2,
                  decoration: _inputDecoration("Alamat Penerima"),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text("Ambil Lokasi Sekarang"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                ),
                if (latitude != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Lokasi: $latitude , $longitude",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "Simpan Paket",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
