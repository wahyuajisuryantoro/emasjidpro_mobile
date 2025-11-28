class AkunKeuanganModel {
  final int? no;
  final String kode;
  final String nama;
  final String kategori;
  final double saldo;
  final String? type;
  final bool? cashAndBank;

  AkunKeuanganModel({
    this.no,
    required this.kode,
    required this.nama,
    required this.kategori,
    required this.saldo,
    this.type,
    this.cashAndBank,
  });

  factory AkunKeuanganModel.fromJson(Map<String, dynamic> json) {
    return AkunKeuanganModel(
      no: json['no'],
      kode: json['kode'],
      nama: json['nama'],
      kategori: json['kategori'],
      saldo: json['saldo'].toDouble(),
      type: json['type'],
      cashAndBank: json['cash_and_bank'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'kode': kode,
      'nama': nama,
      'kategori': kategori,
      'saldo': saldo,
      'type': type,
      'cash_and_bank': cashAndBank == true ? '1' : '0',
    };
  }
}