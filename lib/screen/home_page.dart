import 'package:flutter/material.dart';
import 'add_paket_screen.dart';
import 'list_paket_screen.dart';
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  final String email;

  const HomePage({super.key, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  String get kurirEmail => widget.email;

  String get kurirName {
    if (kurirEmail.isEmpty) return "Kurir";
    if (!kurirEmail.contains('@')) return kurirEmail;
    return kurirEmail.split('@')[0];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const AddPaketScreen(),
      const ListPaketScreen(),
      _buildAccountPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Kurir"),
        centerTitle: true,
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
                  "https://img.freepik.com/vektor-premium/logo-delivery-express-dengan-van-panel-dan-kurir_1639-29296.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay biru transparan
          Container(color: Colors.blue.withOpacity(0.6)),
          // Konten halaman
          _pages[_selectedIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade900.withOpacity(0.9),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: "Tambah Paket",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Daftar Paket",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Akun",
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              "Nama: $kurirName",
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            Text(
              "Email: $kurirEmail",
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
