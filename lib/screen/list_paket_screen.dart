import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vsga_kurir/screen/foto_screen.dart';
import '../services/api_service.dart';
import '../models/paket.dart';
import 'map_screen.dart';

class ListPaketScreen extends StatefulWidget {
  const ListPaketScreen({super.key});

  @override
  State<ListPaketScreen> createState() => _ListPaketScreenState();
}

class _ListPaketScreenState extends State<ListPaketScreen> {
  List<Paket> paketList = [];
  bool isLoading = true;

  Future<void> _loadData() async {
    try {
      final data = await ApiService.getPaket();
      setState(() {
        paketList = data; // langsung assign List<Paket>
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _editPaket(Paket paket) async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String selected = paket.status;

    String? status = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Ubah Status Paket"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Status sekarang: ${paket.status}"),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selected,
                    items: const [
                      DropdownMenuItem(
                        value: "diproses",
                        child: Text("Diproses"),
                      ),
                      DropdownMenuItem(
                        value: "pengantaran",
                        child: Text("Pengantaran"),
                      ),
                      DropdownMenuItem(
                        value: "selesai",
                        child: Text("Selesai"),
                      ),
                      DropdownMenuItem(
                        value: "tidak diketahui",
                        child: Text("Tidak Diketahui"),
                      ),
                      DropdownMenuItem(value: "return", child: Text("Return")),
                    ],
                    onChanged: (val) => setStateDialog(() => selected = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, selected),
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );

    if (status != null) {
      await ApiService.updatePaket(
        paket.id,
        status,
        pos.latitude,
        pos.longitude,
      );
      _loadData();
    }
  }

  Future<void> _confirmDelete(Paket paket) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Hapus Paket"),
            content: Text(
              "Apakah Anda yakin ingin menghapus paket ${paket.namaPenerima}?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Hapus"),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await ApiService.deletePaket(paket.id);
      _loadData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Paket berhasil dihapus")));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "diproses":
        return Colors.orange;
      case "pengantaran":
        return Colors.blue;
      case "selesai":
        return Colors.green;
      case "return":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Paket"), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: paketList.length,
                    itemBuilder: (context, index) {
                      final p = paketList[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            p.namaPenerima,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("${p.jenisPaket} - ${p.alamatPenerima}"),
                              const SizedBox(height: 4),
                              Text("Lokasi: ${p.lat}, ${p.lng}"),
                              const SizedBox(height: 4),
                              Text(
                                "Status: ${p.status}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(p.status),
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == "edit") {
                                await _editPaket(p);
                              } else if (value == "delete") {
                                await _confirmDelete(p);
                              } else if (value == "map") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MapScreen(),
                                    settings: RouteSettings(
                                      arguments: {'lat': p.lat, 'lng': p.lng},
                                    ),
                                  ),
                                );
                              } else if (value == "foto") {
                                if (p.foto != null && p.foto!.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FotoScreen(paket: p),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Foto tidak tersedia"),
                                    ),
                                  );
                                }
                              }
                            },
                            itemBuilder:
                                (context) => const [
                                  PopupMenuItem(
                                    value: "map",
                                    child: Text("Lihat di Map"),
                                  ),
                                  PopupMenuItem(
                                    value: "edit",
                                    child: Text("Ubah Status"),
                                  ),
                                  PopupMenuItem(
                                    value: "delete",
                                    child: Text("Hapus"),
                                  ),
                                  PopupMenuItem(
                                    value: "foto",
                                    child: Text("Lihat Foto"),
                                  ),
                                ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
