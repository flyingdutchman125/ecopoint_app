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
  double? _withdrawAmount;
  bool _tarikSemua = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
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
        // Format with thousand separator
        final balStr = bal.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
        _amountController.text = balStr;
      } else {
        _amountController.clear();
        _withdrawAmount = null;
      }
    });
  }

  // Format input with thousand separator dynamically while typing
  void _formatInputText(String val) {
    if (val.isEmpty) return;
    final cleanVal = val.replaceAll('.', '');
    final numVal = double.tryParse(cleanVal);
    if (numVal == null) return;
    
    final formatted = numVal.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    
    // Prevent infinite loop by checking if text is already formatted
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
          'Withdraw',
          style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Main White Card
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
                    )
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
                        final balStr = bal.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
                        return Text(
                          'Rp $balStr',
                          style: _jakarta(fontSize: 22, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Lakukan Penarikan',
                      style: _jakarta(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    
                    // Nominal Input Box
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text('Rp ', style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                hintText: 'Minimum Rp 10.000',
                                hintStyle: _jakarta(fontSize: 13, color: Colors.black38),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              enabled: !_tarikSemua,
                              onChanged: _formatInputText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Tarik Semua Row
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
                      'Transfer Ke',
                      style: _jakarta(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    
                    // Transfer Destination Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          // DANA Logo placeholder (blue rounded shape with standard look)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E88E5), // Dana Blue
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.account_balance_wallet, color: Colors.white, size: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Bank name and phone number
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallet.bankAccount['bank'] as String? ?? 'Dana',
                                  style: _jakarta(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  wallet.bankAccount['phone'] as String? ?? '0895341381130',
                                  style: _jakarta(fontSize: 11, color: Colors.black45),
                                ),
                              ],
                            ),
                          ),
                          
                          // Account Holder Name
                          Text(
                            'Ahmad Syifa\'ul Falakhul Khayyi',
                            style: _jakarta(fontSize: 10, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 28),
                    
                    // Lanjut Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_withdrawAmount == null || _withdrawAmount! < 10000 || _withdrawAmount! > wallet.activeBalance.value)
                            ? null
                            : () {
                                context.push('/withdraw/confirm', extra: {
                                  'amount': _withdrawAmount,
                                });
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
                          'Lanjut',
                          style: _jakarta(
                            fontWeight: FontWeight.bold,
                            color: (_withdrawAmount == null || _withdrawAmount! < 10000 || _withdrawAmount! > wallet.activeBalance.value) 
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
