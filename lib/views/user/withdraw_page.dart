import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/wallet_state.dart';

TextStyle _jakarta({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = Colors.black,
  FontStyle? fontStyle,
  double? letterSpacing,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
  );
}

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final wallet = WalletState.instance;
  final TextEditingController _amountController = TextEditingController();
  late TextEditingController _accountNumberController;
  late TextEditingController _accountNameController;
  
  double? _withdrawAmount;
  bool _tarikSemua = false;
  String _selectedMethod = 'DANA';

  final List<Map<String, dynamic>> _methods = const [
    {'name': 'DANA', 'color': Color(0xFF1E88E5), 'icon': Icons.account_balance_wallet},
    {'name': 'OVO', 'color': Color(0xFF4A148C), 'icon': Icons.account_balance_wallet},
    {'name': 'GoPay', 'color': Color(0xFF00897B), 'icon': Icons.account_balance_wallet},
    {'name': 'ShopeePay', 'color': Color(0xFFE64A19), 'icon': Icons.account_balance_wallet},
    {'name': 'Bank BCA', 'color': Color(0xFF0D47A1), 'icon': Icons.account_balance},
    {'name': 'Bank Mandiri', 'color': Color(0xFF01579B), 'icon': Icons.account_balance},
    {'name': 'Bank BRI', 'color': Color(0xFF1565C0), 'icon': Icons.account_balance},
    {'name': 'Bank BNI', 'color': Color(0xFFE65100), 'icon': Icons.account_balance},
  ];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _accountNumberController = TextEditingController(
      text: wallet.bankAccount['phone'] as String? ?? '0895341381130',
    );
    _accountNameController = TextEditingController(
      text: wallet.bankAccount['name'] as String? ?? 'Pengguna EcoPoint',
    );
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _amountController.text.replaceAll('.', '');
    if (text.isEmpty) {
      setState(() {
        _withdrawAmount = null;
      });
      return;
    }
    final amount = double.tryParse(text);
    setState(() {
      _withdrawAmount = amount;
    });
  }

  void _toggleTarikSemua(bool value) {
    setState(() {
      _tarikSemua = value;
      if (_tarikSemua) {
        final bal = wallet.activeBalance.value;
        _withdrawAmount = bal;
        final balStr = bal.toInt().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
        _amountController.text = balStr;
      } else {
        _amountController.clear();
        _withdrawAmount = null;
      }
    });
  }

  void _formatInputText(String val) {
    if (val.isEmpty) return;
    final cleanVal = val.replaceAll('.', '');
    final numVal = double.tryParse(cleanVal);
    if (numVal == null) return;

    final formatted = numVal.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

    if (_amountController.text != formatted) {
      _amountController.text = formatted;
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: formatted.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgYellow = Color(0xFFEADB3F);
    const Color btnGreen = Color(0xFF82C13E);

    return Scaffold(
      backgroundColor: bgYellow,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Withdraw / Tarik Saldo',
          style: _jakarta(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Aktif',
                      style: _jakarta(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    ListenableBuilder(
                      listenable: wallet.activeBalance,
                      builder: (context, _) {
                        final bal = wallet.activeBalance.value;
                        final balStr = bal.toInt().toString().replaceAllMapped(
                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]}.',
                        );
                        return Text(
                          'Rp $balStr',
                          style: _jakarta(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Lakukan Penarikan',
                      style: _jakarta(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Rp ',
                            style: _jakarta(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: _jakarta(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Minimum Rp 10.000',
                                hintStyle: _jakarta(
                                  fontSize: 13,
                                  color: Colors.black38,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              enabled: !_tarikSemua,
                              onChanged: _formatInputText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tarik semua',
                          style: _jakarta(fontSize: 12, color: Colors.black54),
                        ),
                        Switch(
                          value: _tarikSemua,
                          onChanged: _toggleTarikSemua,
                          activeThumbColor: btnGreen,
                          activeTrackColor: btnGreen.withValues(alpha: 0.4),
                        ),
                      ],
                    ),

                    const Divider(height: 24, color: Color(0xFFEEEEEE)),

                    Text(
                      'Pilih Metode Transfer',
                      style: _jakarta(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Grid/Wrap of Methods
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _methods.map((m) {
                        final bool isSelected = _selectedMethod == m['name'];
                        final Color itemColor = m['color'] as Color;
                        return ChoiceChip(
                          avatar: Icon(
                            m['icon'] as IconData,
                            size: 16,
                            color: isSelected ? Colors.white : itemColor,
                          ),
                          label: Text(
                            m['name'] as String,
                            style: _jakarta(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: itemColor,
                          backgroundColor: const Color(0xFFF5F5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected ? itemColor : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedMethod = m['name'] as String;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      _selectedMethod.startsWith('Bank') ? 'Nomor Rekening Tujuan' : 'Nomor HP e-Wallet',
                      style: _jakarta(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        style: _jakarta(fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: _selectedMethod.startsWith('Bank') ? 'Contoh: 1234567890' : 'Contoh: 081234567890',
                          hintStyle: _jakarta(fontSize: 12, color: Colors.black38),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      'Nama Pemilik Akun / Rekening',
                      style: _jakarta(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _accountNameController,
                        style: _jakarta(fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Nama lengkap pemilik',
                          hintStyle: _jakarta(fontSize: 12, color: Colors.black38),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (_withdrawAmount == null ||
                                _withdrawAmount! < 10000 ||
                                _withdrawAmount! > wallet.activeBalance.value ||
                                _accountNumberController.text.trim().isEmpty ||
                                _accountNameController.text.trim().isEmpty)
                            ? null
                            : () {
                                wallet.setBankAccount(
                                  bank: _selectedMethod,
                                  phone: _accountNumberController.text.trim(),
                                  name: _accountNameController.text.trim(),
                                );
                                context.push(
                                  '/withdraw/confirm',
                                  extra: {'amount': _withdrawAmount},
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnGreen,
                          disabledBackgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Lanjut ke Konfirmasi',
                          style: _jakarta(
                            fontWeight: FontWeight.bold,
                            color:
                                (_withdrawAmount == null ||
                                    _withdrawAmount! < 10000 ||
                                    _withdrawAmount! > wallet.activeBalance.value ||
                                    _accountNumberController.text.trim().isEmpty ||
                                    _accountNameController.text.trim().isEmpty)
                                ? Colors.black26
                                : Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
