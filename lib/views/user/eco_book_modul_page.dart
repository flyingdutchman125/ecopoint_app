import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

TextStyle _jakarta({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = Colors.black,
  FontStyle? fontStyle,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    height: height,
  );
}

class EcoBookModulPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const EcoBookModulPage({super.key, this.extra});

  @override
  State<EcoBookModulPage> createState() => _EcoBookModulPageState();
}

class _ModulContent {
  final String id;
  final String title;
  final String headerTitle;
  final String description;
  final List<Map<String, String>> sections;
  _ModulContent({
    required this.id,
    required this.title,
    required this.headerTitle,
    required this.description,
    required this.sections,
  });
}

class _EcoBookModulPageState extends State<EcoBookModulPage> {
  late _ModulContent content;
  int _currentSection = 0;

  @override
  void initState() {
    super.initState();
    final id = widget.extra?['id']?.toString() ?? '1';
    content = _getModulContent(id);
  }

  _ModulContent _getModulContent(String id) {
    switch (id) {
      case '1':
        return _ModulContent(
          id: '1',
          title: 'Kamus Kode Plastik',
          headerTitle:
              'MODUL 1: KAMUS KODE PLASTIK\n(MENGENAL ANGKA DI PANTAT BOTOL)',
          description:
              'Modul ini berisi tentang cara mengidentifikasi jenis plastik dari kode yang terdapat pada kemasan. Setiap angka di bawah botol plastik memiliki arti berbeda menandakan jenis bahan yang digunakan. Penting untuk mengetahui ini agar bisa memilah dan mendaur ulang sampah plastik dengan benar.',
          sections: [
            {
              'title': 'Kode 1 - PETE / PET (Polyethylene Terephthalate)',
              'content':
                  'Plastik PETE merupakan plastik bening yang transparan dan awet terhadap gas dan bau. Sering digunakan untuk botol minuman. Plastik jenis ini dapat di daur ulang. Kandungan di dalamnya dapat mengandung bakteri layaknya air. Lalu label botol bisa disebut sebagai satu kesatuan. Lalu anda harus mencuci botol terlebih dahulu sebelum mendaur ulang.\n\nTips Pemilahan: Pastikan botol dalam keadaan kosong dan bersih dari sisa cairan. Lepas label jika memungkinkan, lalu lembar botol hingga pipih. Langkah ini sangat membantu dalam proses pengangkutan dan penyimpanan.',
            },
            {
              'title': 'Kode 2 - HDPE (High-Density Polyethylene)',
              'content':
                  'Merupakan plastik dengan kepanasan tinggi yang auh lebih kuat, kaku, tahan. Warna plastik ini lebih gelap dan lebih opaque. Plastik ini juga lebih kaku dibanding produk-produk pembersih. Contoh di sekitar kita: Botol cat mineral, botol minyak goreng, wadah es, dan beberapa kemasan obat.\n\nTips Pemilahan: Pastikan botol sudah kosong sama sekali dan bersih. Lepas label positifnya jika memungkinkan, lalu lembar botol hingga pipil. Langkah ini sangat membantu menghemat volume ruang.',
            },
            {
              'title': 'Kategori Saseti & Plastik Lainnya (Low-Value)',
              'content':
                  'Saseti untuk jenis kategori mutu plastik (plastik multilapis, alas meja) dengan material yang berbeda-beda. Contoh di sekitar kita: Bungkus mi instan, sacet kopi, kemasan minyaknya instan, kantong kresek, dan aluminum.\n\nContoh di sekitar kita: Bungkus mi instan, sacet kopi, kemasan minyaknya instan, kantong kresek (snack), kantongnya kresek tissu, dan timbunable wraps.',
            },
          ],
        );
      case '2':
        return _ModulContent(
          id: '2',
          title: 'D.I.Y Eco-Hacks',
          headerTitle: 'MODUL 2: D.I.Y ECO-HACKS\n(MENGOLAH SAMPAH MANDIRI)',
          description:
              'Modul ini mengajarkan cara mengolah sampah organik menjadi sesuatu yang berguna melalui metode sederhana. Dua strategi utama yang paling mudah dilakukan adalah membuat Eco-Enzyme dan Kompos rumahan. Keduanya dapat membuat dampak lingkungan yang signifikan.',
          sections: [
            {
              'title': 'Ramuan Ajaib Eco-Enzyme',
              'content':
                  'Ramuan ajaib guna yang dirancang dibuat begitu saja ke tempat sampah akan membuat dan menurunkan bakteri anaerob. Dengan membuat Eco-Enzym rumahan akan membuat bakteri baik menjadi proses perombakan sampah organik menjadi cair biologis.\n\nFormula & Rumah Perbandingan: Gunakan tanah baksi 3:1:10 berdasarkan berat bahan baku.\n\n3 Bagian: Sisa kulit buah seperi (jeruk, lemon, apel, mangga) atau sisa potongan buah berisi 10 Bagian: Gula merrah atau gula tebu 1 Bagian: Air kran atau air dalam wadah plastik yang diisi EM-1.\n\nLangkah Pembuatan & Proses:\n1. Potong kulit buah kursi dalam garis demi sauyran peroses distribusi peroksidatif perombakan matematic.\n2. Larutkan gula dalam air dalam wadah plastik penempatan ruang dengan suhu 25-30 derajat celcius.\n3. Masukkan potongan buah, aduk isi, lalu tutup wadah dengan rapat.\n4. Simpan di tempat tutup selama 3 bulan. Pada minggu pertama, buka tutup wadah sekali setiap hari untuk membiarkan gas keluar. Setelah itu bisa ditutup rapat selama masa penyimpanan yang diperlukan dalam daya tahan.\n\nManfaat Hasil Akhir: Setelah proses pemberian sisa digunahkan sebagai cairan pembersih pupuk serta pengembangan pupuk organik, hingga bisa digunakan sebagai cairan pembersih pupuk serta pengembangan pupuk organik.',
            },
            {
              'title': 'Amankan Minyak Jelantanku',
              'content':
                  'Untuk jenis kategori mutu plastik (plastik multilapis). Minyak akan mendidihkan, menggelas, dan menjustifikasi kotoran asli hingga membentuk suarbatan (tetapan) di dalam panci. Lalu minyak jelantah dapat menjadi akan pembersih ataupun kandungan untuk memproses pembubaran minyak baru biodesil berbakuran.\n\nLangkah Penanganan yang Benar:\n1. Setelah seluruh minyak alda mendidih semenejnjnya di dalam wadah.\n2. Saintikan botol plastik atau wadah gelas untuk menyimpan gelantah minyak tersebut.\n3. Keamanan seluruh sisi pembungkus minyak/gelantah botol wadah sebelum diletakkan untuk menyimpan gelantah.\n4. Tulisgan botol/pembungkusan isinya botol tapi sesuai menyimpan minyak gelantah.',
            },
          ],
        );
      case '3':
        return _ModulContent(
          id: '3',
          title: 'Kalkulator Dampak Lingkungan',
          headerTitle:
              'MODUL 3: KALKULATOR DAMPAK LINGKUNGAN\n(THE "REAL IMPACT")',
          description:
              'Modul ini menjelaskan dampak nyata dari pemilahan sampah organik dan anorganik melalui kalkulasi sederhana. Dengan menggunakan aplikasi kalkulator dampak, kita bisa melihat berapa banyak pohon yang dapat diselamatkan dan berapa banyak gas metana yang tidak dilepaskan ke atmosfer.',
          sections: [
            {
              'title': '10 Kg Kertas = 1 Pohon Bernnyawa',
              'content':
                  'Fakta Industri: Industri kertas merupakan industri kertas baru dihasilkan sekitar 10 pohon potongan setiap tahun. Perhitungan pohon yang hilang dalam mengeluarkan satu liter susu untuk merawat habitat salwa har.\n\nDampak Asumsi: Dengan melakukan pemilahan sampah kertas di masyarakat, kita memberikan pilihan untuk industri pengolahan untuk melakukan daur ulang terhadap pulp serat. Pohon yang akan dimulai dengan tidak akan mengalami deforestasi dari manusia sejawat tahun.',
            },
            {
              'title': 'Menahan Ledakan Gas Metana di TPA',
              'content':
                  'Proses Kimawi di TPA: Saat sampah organik (makanan) dibuang tercampur dengan sampah lainnya, pemecahan sampah akan menghasilkan gas metan melalui proses anaerobik. Sampah organik akan mengalami dekomposisi anaerob, (tanda oksigen/dasar tunggannya) dapat bisa menciptakan gas metana.\n\nBahaya Gas Metana (CH₄): Gas metana adalah umum kaca berbahaya yang memiliki 28-34 kali lebih berbahaya dibanding karbon dioksida (CO₂). Demiikinya, mengembalikan pengguna di dalam wadah plastik kecil yang mendadaknginkan gas karbon organik Sampel Permanasan Akhir (TPA).\n\nDampak Akumuli: Dengan memisahkan sampah organik dan menyertakan sampah organik secara benar ke lokasi, kami memotong emisi gas metana berbahaya di lingkungan sumber umban sunbernya. Kamu menjadi bagian dari agen pejaga emisi.',
            },
          ],
        );
      default:
        return _ModulContent(
          id: '4',
          title: 'Etika & Keamanan Pemilihan',
          headerTitle: 'MODUL 4: ETIKA & KEAMANAN PEMILIHAN\n(SAFETY FIRST)',
          description:
              'Modul ini mengajarkan protokol keselamatan dan etika dalam memilah sampah, terutama sampah yang dapat membahayakan jika tidak ditangani dengan baik. Proses yang aman akan melindungi pemilah dan lingkungan.',
          sections: [
            {
              'title': 'Protokol Pecahan Kaca & Benda Tajam',
              'content':
                  'Risiko di sekeliking kaca yang akan pecah saat di pisir, cemin nulas, bothan lemuri, atau salet botsan langsng ke dalam kalungan sampah orum berpotesisi membuat pisik tercemar. Luka infeksi bakteri berbahaya seperti bakteri.\n\nLangkah Pengamanan Wajib:\n1. Kemasan kaca atau benda tajam lainnya harus dibungkus dengan koran.\n2. Tandai atau berikan tanda khusus pada paket supaya terlihat dari luar bungkusan.\n3. Pisahkan seluruh sisi pembungkus minyak gelantah botol wadah sebelum diletakkan untuk menyimpan.\n4. Bungkusan tidak boleh ditekan atau dipotong.\n5. Tuliskan peringatan dengan spidol tebal di bagian luar bungkusan "AWAS!".',
            },
            {
              'title': 'Limbah Medis Domestik',
              'content':
                  'Batasan Tugas Aplikasi: Sangat penting untuk diketahui bahwa kuir aplikasi hanya menunggu bahwa sampah kuir aplikasi yang memenuhi sampah anorganik domestik saja medis.\n\nAplikasi tidak memiliki pengenal sampah anorganik ternpau serta penjalasan keselamatan standar untuk mengolah limbah medis berbahaya.\n\nMasker Medis Basah: Sebelum dibuang ke tempat sampah rumah tangga, guring kudus wadah kemasan dengan ikatan panjang dalam hal kemasan baru, Langkah ini sangat penting jika memiliki indicator penyusun dalam aplikasi wadah plastik kecil yang mendadaknginkan gas karbon organik permanaen menangani masker medis.',
            },
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final section = content.sections[_currentSection];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'EcoBook',
          style: _jakarta(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  content.headerTitle,
                  textAlign: TextAlign.center,
                  style: _jakarta(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF558B2F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  content.description,
                  style: _jakarta(
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                section['title']!,
                style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                section['content']!,
                style: _jakarta(
                  fontSize: 12,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(content.sections.length, (idx) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: idx == _currentSection
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFBDBDBD),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_currentSection > 0)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _currentSection--),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9E9E9E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Sebelumnya',
                          style: _jakarta(color: Colors.white),
                        ),
                      ),
                    ),
                  if (_currentSection > 0) const SizedBox(width: 12),
                  if (_currentSection < content.sections.length - 1)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _currentSection++),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Selanjutnya',
                          style: _jakarta(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
