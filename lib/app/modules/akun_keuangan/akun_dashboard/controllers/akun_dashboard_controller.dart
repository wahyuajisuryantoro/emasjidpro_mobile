import 'package:emasjid_pro/app/models/AkunKeuanganModel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';

class AkunDashboardController extends GetxController {
  final RxList<AkunKeuanganModel> aktivaLancar = <AkunKeuanganModel>[].obs;
  final RxList<AkunKeuanganModel> aktivaTetap = <AkunKeuanganModel>[].obs;
  final RxList<AkunKeuanganModel> kewajiban = <AkunKeuanganModel>[].obs;

  final RxDouble totalAktivaLancar = 0.0.obs;
  final RxDouble totalAktivaTetap = 0.0.obs;
  final RxDouble totalKewajiban = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  void loadAccounts() {
    aktivaLancar.value = [
      AkunKeuanganModel(
          kode: '101',
          nama: 'Kas di Tangan',
          kategori: 'Aktiva Lancar',
          saldo: 20000000),
      AkunKeuanganModel(
          kode: '102',
          nama: 'Bank BCA',
          kategori: 'Aktiva Lancar',
          saldo: 50000000),
      AkunKeuanganModel(
          kode: '103',
          nama: 'Bank Syariah Indonesia',
          kategori: 'Aktiva Lancar',
          saldo: 35000000),
    ];

    aktivaTetap.value = [
      AkunKeuanganModel(
          kode: '201',
          nama: 'Tanah',
          kategori: 'Aktiva Tetap',
          saldo: 500000000),
      AkunKeuanganModel(
          kode: '202',
          nama: 'Bangunan Masjid',
          kategori: 'Aktiva Tetap',
          saldo: 750000000),
      AkunKeuanganModel(
          kode: '203',
          nama: 'Furniture',
          kategori: 'Aktiva Tetap',
          saldo: 75000000),
    ];

    kewajiban.value = [
      AkunKeuanganModel(
          kode: '301',
          nama: 'Hutang Renovasi',
          kategori: 'Kewajiban',
          saldo: 25000000),
      AkunKeuanganModel(
          kode: '302',
          nama: 'Hutang Supplier',
          kategori: 'Kewajiban',
          saldo: 15000000),
    ];

    totalAktivaLancar.value = aktivaLancar.fold(
        0, (previousValue, account) => previousValue + account.saldo);

    totalAktivaTetap.value = aktivaTetap.fold(
        0, (previousValue, account) => previousValue + account.saldo);

    totalKewajiban.value = kewajiban.fold(
        0, (previousValue, account) => previousValue + account.saldo);
  }

  void navigateToAddAccount() {
    Get.toNamed(Routes.AKUN_KEUANGAN_TAMBAH);
  }

  void navigateToEditAccount(AkunKeuanganModel account) {
    Get.toNamed(Routes.AKUN_KEUANGAN_EDIT, arguments: account);
  }

  String formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }
}
