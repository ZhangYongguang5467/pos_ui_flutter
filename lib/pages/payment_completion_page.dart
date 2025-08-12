import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/printer_service.dart';

class PaymentCompletionPage extends StatefulWidget {
  final int totalAmount;
  final int prepaidAmount;
  final int pointsUsed;
  final int cashAmount;
  final String? cartId;

  const PaymentCompletionPage({
    super.key,
    required this.totalAmount,
    required this.prepaidAmount,
    this.pointsUsed = 0,
    this.cashAmount = 0,
    this.cartId,
  });

  @override
  State<PaymentCompletionPage> createState() => _PaymentCompletionPageState();
}

class _PaymentCompletionPageState extends State<PaymentCompletionPage> {
  int _remainingSeconds = 5;
  bool _billGenerated = false;
  bool _receiptPrinted = false;

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
    _generateBillAfterDelay();
  }

  void _generateBillAfterDelay() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _generateBill();
      }
    });
  }

  Future<void> _generateBill() async {
    if (widget.cartId == null) {
      print('[PaymentCompletionPage] Skip generateBill: cartId is null');
      return;
    }
    if (_billGenerated) {
      print('[PaymentCompletionPage] Skip generateBill: already generated');
    }

    print('[PaymentCompletionPage] Generating bill for cartId=${widget.cartId}');
    
    try {
      final billData = await ApiService.generateBill(widget.cartId!);
      
      if (billData != null) {
        setState(() {
          _billGenerated = true;
        });
        print('[PaymentCompletionPage] Bill generated successfully');
        _showSuccessMessage();
      } else {
        print('[PaymentCompletionPage] Bill generation returned null data');
        _showErrorMessage();
      }
    } catch (e) {
      print('[PaymentCompletionPage] Error generating bill: $e');
      _showErrorMessage();
    } finally {
      // Ensure we trigger the print once after Get Bill call completes
      if (!_receiptPrinted) {
        print('[PaymentCompletionPage] Proceeding to print receipt after Get Bill call');
        _receiptPrinted = true;
        await _printReceipt();
      } else {
        print('[PaymentCompletionPage] Receipt already printed, skipping');
      }
    }
  }

  Future<void> _printReceipt() async {
    print('[PaymentCompletionPage] Sending receipt to printer...');

    // Sample content adapted from the provided cURL, using \n for new lines.
    const textContent = 'レジNo. 1             責# STF001\n'
        '2025年08月07日(木) 15:11        \n'
        '         【 領 収 証 】         \n'
        '--------------------------------\n'
        '美式咖啡                    50外\n'
        '        2 個@25                 \n'
        '--------------------------------\n'
        '小計            2 個       \\50  \n'
        '  外税10%                   \\5  \n'
        '合計                       \\55  \n'
        '  (外税10% 対象額         \\50)  \n'
        '  (外税10%                 \\5)  \n'
        'お預り                    \\100  \n'
        'お釣り                     \\45  \n'
        '--------------------------------\n'
        '现金支付                   \\55  \n'
        '--------------------------------\n'
        'レシートNo. 111112              \n';

    final success = await PrinterService.printReceipt(
      textContent: textContent,
      barcodeType: 'ean13',
      barcodeData: '000000111112',
      barcodeWidth: 2,
      barcodeHeight: 64,
      barcodeHri: 'below',
      feedBeforeCutUnit: 48,
    );

    if (success) {
      print('[PaymentCompletionPage] Receipt print sent successfully');
    } else {
      print('[PaymentCompletionPage] Failed to send receipt print');
    }
  }

  void _showSuccessMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('請求書が正常に生成されました'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('請求書の生成に失敗しました'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startCountdownTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });
        
        if (_remainingSeconds > 0) {
          _startCountdownTimer();
        } else {
          _navigateToHome();
        }
      }
    });
  }

  void _navigateToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B9BD8),
              Color(0xFF4A7FB8),
            ],
          ),
        ),
        child: Column(
          children: [
            // Top navigation bar
            Container(
              height: 80,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    '1234 (株)4U Applications',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  // Trial badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'TRIAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Thank you message
                    const Text(
                      'ご利用ありがとうございました。',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Receipt message
                    const Text(
                      '『領収証』をお取りください',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Staff illustration
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Male staff
                        _buildStaffAvatar(
                          hairColor: const Color(0xFF8B4513),
                          shirtColor: Colors.white,
                          apronColor: const Color(0xFF4A6FA5),
                          isMale: true,
                        ),
                        
                        const SizedBox(width: 60),
                        
                        // Female staff
                        _buildStaffAvatar(
                          hairColor: const Color(0xFF8B4513),
                          shirtColor: Colors.white,
                          apronColor: const Color(0xFF4A6FA5),
                          isMale: false,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffAvatar({
    required Color hairColor,
    required Color shirtColor,
    required Color apronColor,
    required bool isMale,
  }) {
    return Container(
      width: 160,
      height: 200,
      child: Column(
        children: [
          // Head
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDBB5), // Skin color
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                // Hair
                Positioned(
                  top: 0,
                  left: 8,
                  right: 8,
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: hairColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                  ),
                ),
                // Eyes
                Positioned(
                  top: 20,
                  left: 16,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 16,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Mouth (smile)
                Positioned(
                  top: 36,
                  left: 24,
                  right: 24,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Body
          Container(
            width: 96,
            height: 128,
            child: Stack(
              children: [
                // Shirt
                Container(
                  width: 96,
                  height: 80,
                  decoration: BoxDecoration(
                    color: shirtColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Apron
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: apronColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'TRIAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Arms
                Positioned(
                  top: 16,
                  left: -16,
                  child: Container(
                    width: 24,
                    height: 64,
                    decoration: BoxDecoration(
                      color: shirtColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: -16,
                  child: Container(
                    width: 24,
                    height: 64,
                    decoration: BoxDecoration(
                      color: shirtColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 