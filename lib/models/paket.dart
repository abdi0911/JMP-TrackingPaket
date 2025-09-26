class Paket {
  final int id;
  final String namaPenerima;
  final String jenisPaket;
  final String alamatPenerima;
  final String status;
  final double lat;
  final double lng;
  final String createdAt;
  final String? foto;

  Paket({
    required this.id,
    required this.namaPenerima,
    required this.jenisPaket,
    required this.alamatPenerima,
    required this.status,
    required this.lat,
    required this.lng,
    required this.createdAt,
    this.foto,
  });

  factory Paket.fromJson(Map<String, dynamic> json) {
    return Paket(
      id: int.parse(json['id'].toString()),
      namaPenerima: json['nama_penerima'],
      jenisPaket: json['jenis_paket'],
      alamatPenerima: json['alamat_penerima'],
      status: json['status'],
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
      createdAt: json['created_at'],
      foto: json['foto'], // ✅ ambil dari API
    );
  }
}
