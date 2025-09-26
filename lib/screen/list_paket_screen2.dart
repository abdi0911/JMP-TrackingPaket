import 'package:flutter/material.dart';
import '../models/paket.dart';
import '../services/api_service.dart';
import 'map_screen.dart';
import 'login_screen.dart';

class ListPaketScreen2 extends StatefulWidget {
  const ListPaketScreen2({super.key});
  @override
  State<ListPaketScreen2> createState() => _ListPaketScreen2State();
}

class _ListPaketScreen2State extends State<ListPaketScreen2> {
  List<Paket> paketList = [];
  bool isLoading = true;
  Future<void> _loadData() async {
    final data = await ApiService.getPaket();
    setState(() {
      paketList = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
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
      appBar: AppBar(
        title: const Text("Daftar Paket"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Kembali ke login screen dan hapus halaman saat ini dari stack
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
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
                          trailing: IconButton(
                            icon: const Icon(Icons.map, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MapScreen(),
                                  settings: RouteSettings(
                                    arguments: {'lat': p.lat, 'lng': p.lng},
                                  ),
                                ),
                              );
                            },
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
