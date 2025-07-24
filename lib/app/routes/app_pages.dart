import 'package:get/get.dart';

import '../modules/akun_keuangan/akun_dashboard/bindings/akun_dashboard_binding.dart';
import '../modules/akun_keuangan/akun_dashboard/views/akun_dashboard_view.dart';
import '../modules/akun_keuangan/akun_keuangan_edit/bindings/akun_keuangan_edit_binding.dart';
import '../modules/akun_keuangan/akun_keuangan_edit/views/akun_keuangan_edit_view.dart';
import '../modules/akun_keuangan/akun_keuangan_tambah/bindings/akun_keuangan_tambah_binding.dart';
import '../modules/akun_keuangan/akun_keuangan_tambah/views/akun_keuangan_tambah_view.dart';
import '../modules/aset/aset_beli/bindings/aset_beli_binding.dart';
import '../modules/aset/aset_beli/views/aset_beli_view.dart';
import '../modules/aset/aset_daftar/bindings/aset_daftar_binding.dart';
import '../modules/aset/aset_daftar/views/aset_daftar_view.dart';
import '../modules/aset/aset_daftar_jual/bindings/aset_daftar_jual_binding.dart';
import '../modules/aset/aset_daftar_jual/views/aset_daftar_jual_view.dart';
import '../modules/aset/aset_dashboard/bindings/aset_dashboard_binding.dart';
import '../modules/aset/aset_dashboard/views/aset_dashboard_view.dart';
import '../modules/aset/aset_detail/bindings/aset_detail_binding.dart';
import '../modules/aset/aset_detail/views/aset_detail_view.dart';
import '../modules/aset/aset_edit/bindings/aset_edit_binding.dart';
import '../modules/aset/aset_edit/views/aset_edit_view.dart';
import '../modules/aset/aset_jual/bindings/aset_jual_binding.dart';
import '../modules/aset/aset_jual/views/aset_jual_view.dart';
import '../modules/aset/aset_kategori_daftar/bindings/aset_kategori_daftar_binding.dart';
import '../modules/aset/aset_kategori_daftar/views/aset_kategori_daftar_view.dart';
import '../modules/aset/aset_kategori_edit/bindings/aset_kategori_edit_binding.dart';
import '../modules/aset/aset_kategori_edit/views/aset_kategori_edit_view.dart';
import '../modules/aset/aset_kategori_tambah/bindings/aset_kategori_tambah_binding.dart';
import '../modules/aset/aset_kategori_tambah/views/aset_kategori_tambah_view.dart';
import '../modules/aset/aset_laporan/bindings/aset_laporan_binding.dart';
import '../modules/aset/aset_laporan/views/aset_laporan_view.dart';
import '../modules/aset/aset_penyusutan_edit/bindings/aset_penyusutan_edit_binding.dart';
import '../modules/aset/aset_penyusutan_edit/views/aset_penyusutan_edit_view.dart';
import '../modules/aset/aset_penyusutan_tambah/bindings/aset_penyusutan_tambah_binding.dart';
import '../modules/aset/aset_penyusutan_tambah/views/aset_penyusutan_tambah_view.dart';
import '../modules/buku_besar/bindings/buku_besar_binding.dart';
import '../modules/buku_besar/views/buku_besar_view.dart';
import '../modules/buku_besar_detail/bindings/buku_besar_detail_binding.dart';
import '../modules/buku_besar_detail/views/buku_besar_detail_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/hutang/hutang_daftar/bindings/hutang_daftar_binding.dart';
import '../modules/hutang/hutang_daftar/views/hutang_daftar_view.dart';
import '../modules/hutang/hutang_dashboard/bindings/hutang_dashboard_binding.dart';
import '../modules/hutang/hutang_dashboard/views/hutang_dashboard_view.dart';
import '../modules/hutang/hutang_detail/bindings/hutang_detail_binding.dart';
import '../modules/hutang/hutang_detail/views/hutang_detail_view.dart';
import '../modules/hutang/hutang_laporan/bindings/hutang_laporan_binding.dart';
import '../modules/hutang/hutang_laporan/views/hutang_laporan_view.dart';
import '../modules/hutang/hutang_tambah/bindings/hutang_tambah_binding.dart';
import '../modules/hutang/hutang_tambah/views/hutang_tambah_view.dart';
import '../modules/hutang/hutang_tambah_cicilan/bindings/hutang_tambah_cicilan_binding.dart';
import '../modules/hutang/hutang_tambah_cicilan/views/hutang_tambah_cicilan_view.dart';
import '../modules/informasi/bindings/informasi_binding.dart';
import '../modules/informasi/views/informasi_view.dart';
import '../modules/jurnal_umum/bindings/jurnal_umum_binding.dart';
import '../modules/jurnal_umum/views/jurnal_umum_view.dart';
import '../modules/jurnal_umum_detail/bindings/jurnal_umum_detail_binding.dart';
import '../modules/jurnal_umum_detail/views/jurnal_umum_detail_view.dart';
import '../modules/kas_dan_bank/kas_dan_bank_dashboard/bindings/kas_dan_bank_dashboard_binding.dart';
import '../modules/kas_dan_bank/kas_dan_bank_dashboard/views/kas_dan_bank_dashboard_view.dart';
import '../modules/kas_dan_bank/kas_dan_bank_laporan/bindings/kas_dan_bank_laporan_binding.dart';
import '../modules/kas_dan_bank/kas_dan_bank_laporan/views/kas_dan_bank_laporan_view.dart';
import '../modules/kas_dan_bank/kas_dan_bank_setor/bindings/kas_dan_bank_setor_binding.dart';
import '../modules/kas_dan_bank/kas_dan_bank_setor/views/kas_dan_bank_setor_view.dart';
import '../modules/kas_dan_bank/kas_dan_bank_tambah/bindings/kas_dan_bank_tambah_binding.dart';
import '../modules/kas_dan_bank/kas_dan_bank_tambah/views/kas_dan_bank_tambah_view.dart';
import '../modules/kas_dan_bank/kas_dan_bank_tarik/bindings/kas_dan_bank_tarik_binding.dart';
import '../modules/kas_dan_bank/kas_dan_bank_tarik/views/kas_dan_bank_tarik_view.dart';
import '../modules/kas_dan_bank/kas_dan_bank_transfer/bindings/kas_dan_bank_transfer_binding.dart';
import '../modules/kas_dan_bank/kas_dan_bank_transfer/views/kas_dan_bank_transfer_view.dart';
import '../modules/laporan/bindings/laporan_binding.dart';
import '../modules/laporan/views/laporan_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/notifikasi/bindings/notifikasi_binding.dart';
import '../modules/notifikasi/views/notifikasi_view.dart';
import '../modules/pendapatan/pendapatan_dashboard/bindings/pendapatan_binding.dart';
import '../modules/pendapatan/pendapatan_dashboard/views/pendapatan_view.dart';
import '../modules/pendapatan/pendapatan_laporan/bindings/pendapatan_laporan_binding.dart';
import '../modules/pendapatan/pendapatan_laporan/views/pendapatan_laporan_view.dart';
import '../modules/pendapatan/pendapatan_riwayat/bindings/pendapatan_riwayat_binding.dart';
import '../modules/pendapatan/pendapatan_riwayat/views/pendapatan_riwayat_view.dart';
import '../modules/pendapatan/pendapatan_transaksi/bindings/pendapatan_transaksi_binding.dart';
import '../modules/pendapatan/pendapatan_transaksi/views/pendapatan_transaksi_view.dart';
import '../modules/pengeluaran/pengeluaran_dashboard/bindings/pengeluaran_dashboard_binding.dart';
import '../modules/pengeluaran/pengeluaran_dashboard/views/pengeluaran_dashboard_view.dart';
import '../modules/pengeluaran/pengeluaran_laporan/bindings/pengeluaran_laporan_binding.dart';
import '../modules/pengeluaran/pengeluaran_laporan/views/pengeluaran_laporan_view.dart';
import '../modules/pengeluaran/pengeluaran_riwayat/bindings/pengeluaran_riwayat_binding.dart';
import '../modules/pengeluaran/pengeluaran_riwayat/views/pengeluaran_riwayat_view.dart';
import '../modules/pengeluaran/pengeluaran_transaksi/bindings/pengeluaran_transaksi_binding.dart';
import '../modules/pengeluaran/pengeluaran_transaksi/views/pengeluaran_transaksi_view.dart';
import '../modules/piutang/piutang_daftar/bindings/piutang_daftar_binding.dart';
import '../modules/piutang/piutang_daftar/views/piutang_daftar_view.dart';
import '../modules/piutang/piutang_dashboard/bindings/piutang_dashboard_binding.dart';
import '../modules/piutang/piutang_dashboard/views/piutang_dashboard_view.dart';
import '../modules/piutang/piutang_detail/bindings/piutang_detail_binding.dart';
import '../modules/piutang/piutang_detail/views/piutang_detail_view.dart';
import '../modules/piutang/piutang_laporan/bindings/piutang_laporan_binding.dart';
import '../modules/piutang/piutang_laporan/views/piutang_laporan_view.dart';
import '../modules/piutang/piutang_tambah/bindings/piutang_tambah_binding.dart';
import '../modules/piutang/piutang_tambah/views/piutang_tambah_view.dart';
import '../modules/piutang/piutang_tambah_cicilan/bindings/piutang_tambah_cicilan_binding.dart';
import '../modules/piutang/piutang_tambah_cicilan/views/piutang_tambah_cicilan_view.dart';
import '../modules/setting/profil/bindings/profil_binding.dart';
import '../modules/setting/profil/views/profil_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/setting/profile_detail_akun/bindings/profile_detail_akun_binding.dart';
import '../modules/setting/profile_detail_akun/views/profile_detail_akun_view.dart';
import '../modules/setting/profile_masjid_saya/bindings/profile_masjid_saya_binding.dart';
import '../modules/setting/profile_masjid_saya/views/profile_masjid_saya_view.dart';
import '../modules/setting/profile_ubah_password/bindings/profile_ubah_password_binding.dart';
import '../modules/setting/profile_ubah_password/views/profile_ubah_password_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PENDAPATAN,
      page: () => const PendapatanView(),
      binding: PendapatanBinding(),
    ),
    GetPage(
      name: _Paths.PENDAPATAN_TRANSAKSI,
      page: () => const PendapatanTransaksiView(),
      binding: PendapatanTransaksiBinding(),
    ),
    GetPage(
      name: _Paths.PENDAPATAN_RIWAYAT,
      page: () => const PendapatanRiwayatView(),
      binding: PendapatanRiwayatBinding(),
    ),
    GetPage(
      name: _Paths.PENGELUARAN_DASHBOARD,
      page: () => const PengeluaranDashboardView(),
      binding: PengeluaranDashboardBinding(),
    ),
    GetPage(
      name: _Paths.PENGELUARAN_RIWAYAT,
      page: () => const PengeluaranRiwayatView(),
      binding: PengeluaranRiwayatBinding(),
    ),
    GetPage(
      name: _Paths.PENGELUARAN_TRANSAKSI,
      page: () => const PengeluaranTransaksiView(),
      binding: PengeluaranTransaksiBinding(),
    ),
    GetPage(
      name: _Paths.HUTANG_DASHBOARD,
      page: () => const HutangDashboardView(),
      binding: HutangDashboardBinding(),
    ),
    GetPage(
      name: _Paths.HUTANG_DAFTAR,
      page: () => const HutangDaftarView(),
      binding: HutangDaftarBinding(),
    ),
    GetPage(
      name: _Paths.HUTANG_DETAIL,
      page: () => const HutangDetailView(),
      binding: HutangDetailBinding(),
    ),
    GetPage(
      name: _Paths.HUTANG_TAMBAH_CICILAN,
      page: () => const HutangTambahCicilanView(),
      binding: HutangTambahCicilanBinding(),
    ),
    GetPage(
      name: _Paths.HUTANG_TAMBAH,
      page: () => const HutangTambahView(),
      binding: HutangTambahBinding(),
    ),
    GetPage(
      name: _Paths.PIUTANG_DASHBOARD,
      page: () => const PiutangDashboardView(),
      binding: PiutangDashboardBinding(),
    ),
    GetPage(
      name: _Paths.PIUTANG_DAFTAR,
      page: () => const PiutangDaftarView(),
      binding: PiutangDaftarBinding(),
    ),
    GetPage(
      name: _Paths.PIUTANG_TAMBAH,
      page: () => const PiutangTambahView(),
      binding: PiutangTambahBinding(),
    ),
    GetPage(
      name: _Paths.PIUTANG_DETAIL,
      page: () => const PiutangDetailView(),
      binding: PiutangDetailBinding(),
    ),
    GetPage(
      name: _Paths.PIUTANG_TAMBAH_CICILAN,
      page: () => const PiutangTambahCicilanView(),
      binding: PiutangTambahCicilanBinding(),
    ),
    GetPage(
      name: _Paths.KAS_DAN_BANK_DASHBOARD,
      page: () => const KasDanBankDashboardView(),
      binding: KasDanBankDashboardBinding(),
    ),
    GetPage(
      name: _Paths.KAS_DAN_BANK_TAMBAH,
      page: () => const KasDanBankTambahView(),
      binding: KasDanBankTambahBinding(),
    ),
    GetPage(
      name: _Paths.AKUN_DASHBOARD,
      page: () => const AkunDashboardView(),
      binding: AkunDashboardBinding(),
    ),
    GetPage(
      name: _Paths.AKUN_KEUANGAN_EDIT,
      page: () => const AkunKeuanganEditView(),
      binding: AkunKeuanganEditBinding(),
    ),
    GetPage(
      name: _Paths.AKUN_KEUANGAN_TAMBAH,
      page: () => const AkunKeuanganTambahView(),
      binding: AkunKeuanganTambahBinding(),
    ),
    GetPage(
      name: _Paths.ASET_DASHBOARD,
      page: () => const AsetDashboardView(),
      binding: AsetDashboardBinding(),
    ),
    GetPage(
      name: _Paths.ASET_DAFTAR,
      page: () => const AsetDaftarView(),
      binding: AsetDaftarBinding(),
    ),
    GetPage(
      name: _Paths.ASET_DETAIL,
      page: () => const AsetDetailView(),
      binding: AsetDetailBinding(),
    ),
    GetPage(
      name: _Paths.ASET_EDIT,
      page: () => const AsetEditView(),
      binding: AsetEditBinding(),
    ),
    GetPage(
      name: _Paths.ASET_JUAL,
      page: () => const AsetJualView(),
      binding: AsetJualBinding(),
    ),
    GetPage(
      name: _Paths.ASET_BELI,
      page: () => const AsetBeliView(),
      binding: AsetBeliBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.JURNAL_UMUM,
      page: () => const JurnalUmumView(),
      binding: JurnalUmumBinding(),
    ),
    GetPage(
      name: _Paths.LAPORAN,
      page: () => const LaporanView(),
      binding: LaporanBinding(),
    ),
    GetPage(
      name: _Paths.JURNAL_UMUM_DETAIL,
      page: () => const JurnalUmumDetailView(),
      binding: JurnalUmumDetailBinding(),
    ),
    GetPage(
      name: _Paths.INFORMASI,
      page: () => const InformasiView(),
      binding: InformasiBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFIKASI,
      page: () => const NotifikasiView(),
      binding: NotifikasiBinding(),
    ),
    GetPage(
      name: _Paths.KAS_DAN_BANK_SETOR,
      page: () => const KasDanBankSetorView(),
      binding: KasDanBankSetorBinding(),
    ),
    GetPage(
      name: _Paths.KAS_DAN_BANK_TARIK,
      page: () => const KasDanBankTarikView(),
      binding: KasDanBankTarikBinding(),
    ),
    GetPage(
      name: _Paths.KAS_DAN_BANK_TRANSFER,
      page: () => const KasDanBankTransferView(),
      binding: KasDanBankTransferBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_DETAIL_AKUN,
      page: () => const ProfileDetailAkunView(),
      binding: ProfileDetailAkunBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_UBAH_PASSWORD,
      page: () => const ProfileUbahPasswordView(),
      binding: ProfileUbahPasswordBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_MASJID_SAYA,
      page: () => const ProfileMasjidSayaView(),
      binding: ProfileMasjidSayaBinding(),
    ),
    GetPage(
      name: _Paths.PENDAPATAN_LAPORAN,
      page: () => const PendapatanLaporanView(),
      binding: PendapatanLaporanBinding(),
    ),
    GetPage(
      name: _Paths.PENGELUARAN_LAPORAN,
      page: () => const PengeluaranLaporanView(),
      binding: PengeluaranLaporanBinding(),
    ),
    GetPage(
      name: _Paths.HUTANG_LAPORAN,
      page: () => const HutangLaporanView(),
      binding: HutangLaporanBinding(),
    ),
    GetPage(
      name: _Paths.PIUTANG_LAPORAN,
      page: () => const PiutangLaporanView(),
      binding: PiutangLaporanBinding(),
    ),
    GetPage(
      name: _Paths.KAS_DAN_BANK_LAPORAN,
      page: () => const KasDanBankLaporanView(),
      binding: KasDanBankLaporanBinding(),
    ),
    GetPage(
      name: _Paths.ASET_DAFTAR_JUAL,
      page: () => const AsetDaftarJualView(),
      binding: AsetDaftarJualBinding(),
    ),
    GetPage(
      name: _Paths.ASET_LAPORAN,
      page: () => const AsetLaporanView(),
      binding: AsetLaporanBinding(),
    ),
    GetPage(
      name: _Paths.ASET_KATEGORI_TAMBAH,
      page: () => const AsetKategoriTambahView(),
      binding: AsetKategoriTambahBinding(),
    ),
    GetPage(
      name: _Paths.ASET_KATEGORI_DAFTAR,
      page: () => const AsetKategoriDaftarView(),
      binding: AsetKategoriDaftarBinding(),
    ),
    GetPage(
      name: _Paths.ASET_KATEGORI_EDIT,
      page: () => const AsetKategoriEditView(),
      binding: AsetKategoriEditBinding(),
    ),
    GetPage(
      name: _Paths.ASET_PENYUSUTAN_TAMBAH,
      page: () => const AsetPenyusutanTambahView(),
      binding: AsetPenyusutanTambahBinding(),
    ),
    GetPage(
      name: _Paths.ASET_PENYUSUTAN_EDIT,
      page: () => const AsetPenyusutanEditView(),
      binding: AsetPenyusutanEditBinding(),
    ),
    GetPage(
      name: _Paths.BUKU_BESAR,
      page: () => const BukuBesarView(),
      binding: BukuBesarBinding(),
    ),
    GetPage(
      name: _Paths.BUKU_BESAR_DETAIL,
      page: () => const BukuBesarDetailView(),
      binding: BukuBesarDetailBinding(),
    ),
    GetPage(
      name: _Paths.PROFIL,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),
  ];
}
