import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/paket.dart';
import '../services/api_service.dart';

class FotoScreen extends StatefulWidget {
  final Paket paket;
  const FotoScreen({super.key, required this.paket});

  @override
  State<FotoScreen> createState() => _FotoScreenState();
}

class _FotoScreenState extends State<FotoScreen> {
  File? _image;
  bool _isUploading = false;
  String? _fotoUrl;

  @override
  void initState() {
    super.initState();
    // inisialisasi fotoUrl dari paket
    if (widget.paket.foto != null && widget.paket.foto!.isNotEmpty) {
      _fotoUrl = _buildFotoUrl(widget.paket.foto!);
    }
  }

  // Fungsi untuk memastikan path foto benar
  String _buildFotoUrl(String fotoPath) {
    if (fotoPath.startsWith("http")) {
      return fotoPath; // sudah full URL
    }
    if (fotoPath.startsWith("uploads/")) {
      return "${ApiService.baseUrl}/$fotoPath";
    }
    return "${ApiService.baseUrl}/uploads/$fotoPath";
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final res = await ApiService.updateFoto(widget.paket.id, _image!);
      if (res["success"] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Foto berhasil diupdate")));

        // update fotoUrl lokal
        setState(() {
          if (res["foto"] != null && res["foto"].toString().isNotEmpty) {
            _fotoUrl = _buildFotoUrl(res["foto"]);
          }
          _image = null; // reset file sementara
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal update foto: ${res["message"]}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Foto Paket")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(
                  _image!,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                )
                : _fotoUrl != null
                ? Image.network(
                  _fotoUrl!,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Text("Gagal memuat foto"),
                )
                : const Text("Foto tidak tersedia"),
            const SizedBox(height: 20),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Ambil Foto"),
                ),
          ],
        ),
      ),
    );
  }
}
