import 'dart:convert';

class DashboardPendapatanModel {
  final Saldo saldo;
  final RingkasanTransaksi ringkasanTransaksi;
  final List<TransaksiItem> riwayatTransaksi;

  DashboardPendapatanModel({
    required this.saldo,
    required this.ringkasanTransaksi,
    required this.riwayatTransaksi,
  });

  factory DashboardPendapatanModel.fromJson(Map<String, dynamic> json) {
    return DashboardPendapatanModel(
      saldo: Saldo.fromJson(json['saldo']),
      ringkasanTransaksi: RingkasanTransaksi.fromJson(json['ringkasan_transaksi']),
      riwayatTransaksi: (json['riwayat_transaksi'] as List)
          .map((item) => TransaksiItem.fromJson(item))
          .toList(),
    );
  }
}

class Saldo {
  final int bulanan;
  final String formattedBulanan;
  final int tahunan;
  final String formattedTahunan;

  Saldo({
    required this.bulanan,
    required this.formattedBulanan,
    required this.tahunan,
    required this.formattedTahunan,
  });

  factory Saldo.fromJson(Map<String, dynamic> json) {
    return Saldo(
      bulanan: _parseIntSafely(json['bulanan']),
      formattedBulanan: json['formatted_bulanan']?.toString() ?? "Rp 0",
      tahunan: _parseIntSafely(json['tahunan']),
      formattedTahunan: json['formatted_tahunan']?.toString() ?? "Rp 0",
    );
  }
}

class RingkasanTransaksi {
  final List<KategoriTransaksi> kategoriTransaksi;
  final int totalPendapatan;
  final String formattedTotalPendapatan;

  RingkasanTransaksi({
    required this.kategoriTransaksi,
    required this.totalPendapatan,
    required this.formattedTotalPendapatan,
  });

  factory RingkasanTransaksi.fromJson(Map<String, dynamic> json) {
    return RingkasanTransaksi(
      kategoriTransaksi: ((json['kategori_transaksi'] ?? []) as List)
          .map((item) => KategoriTransaksi.fromJson(item))
          .toList(),
      totalPendapatan: _parseIntSafely(json['total_pendapatan']),
      formattedTotalPendapatan: json['formatted_total_pendapatan']?.toString() ?? "Rp 0",
    );
  }
}

class KategoriTransaksi {
  final String namaKategori;
  final String kodeKategori;
  final String status;
  final int totalValue;
  String get name => namaKategori;
  int get total => totalValue;

  KategoriTransaksi({
    required this.namaKategori,
    required this.kodeKategori,
    required this.status,
    required this.totalValue,
  });

  factory KategoriTransaksi.fromJson(Map<String, dynamic> json) {
    return KategoriTransaksi(
      namaKategori: json['nama_kategori']?.toString() ?? '',
      kodeKategori: json['kode_kategori']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      totalValue: _parseIntSafely(json['total_value']),
    );
  }
}

class TransaksiItem {
  final String tanggal;
  final String judulTransaksi;
  final int amount;
  final String formattedAmount;
  final bool isIncome;
  final String description;

  String get date => tanggal;
  String get title => judulTransaksi;
  
  TransaksiItem({
    required this.tanggal,
    required this.judulTransaksi,
    required this.amount,
    required this.formattedAmount,
    required this.isIncome,
    required this.description,
  });

  factory TransaksiItem.fromJson(Map<String, dynamic> json) {
    return TransaksiItem(
      tanggal: json['tanggal']?.toString() ?? '',
      judulTransaksi: json['judul_transaksi']?.toString() ?? '',
      amount: _parseIntSafely(json['amount']),
      formattedAmount: json['formatted_amount']?.toString() ?? '',
      isIncome: json['isIncome'] == true,
      description: json['description']?.toString() ?? '',
    );
  }
}


int _parseIntSafely(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      return 0;
    }
  }
  if (value is double) return value.toInt();
  return 0;
}