import 'package:flutter/material.dart';
import 'payment_completion_page.dart';
import '../services/api_service.dart';

class PrepaidPaymentPage extends StatefulWidget {
  final List<dynamic> cartItems;
  final int totalAmount;
  final int bagCount;
  final int bagPrice;
  final String? cartId;

  const PrepaidPaymentPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.bagCount,
    required this.bagPrice,
    this.cartId,
  });

  @override
  State<PrepaidPaymentPage> createState() => _PrepaidPaymentPageState();
}

class _PrepaidPaymentPageState extends State<PrepaidPaymentPage> {
  // Sample prepaid card data
  final int prepaidBalance = 4000; // 4,000円
  final int pointBalance = 1076; // 1,076 P
  int usedPoints = 0; // Points to be used for payment

  int get finalTotalAmount => widget.totalAmount + (widget.bagCount * widget.bagPrice);
  int get remainingAmount => finalTotalAmount - prepaidBalance - usedPoints;
  bool get hasInsufficientFunds => remainingAmount > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Top navigation bar
          Container(
            height: 80,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Back button
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FA5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: const Center(
                        child: Text(
                          '戻る',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Staff call button
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE67E22),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Handle staff call
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Center(
                        child: Text(
                          '係員呼出',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Title
                const Text(
                  'お会計',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Balance update button
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FA5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '残高更新',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
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
            child: Padding(
              padding: const EdgeInsets.all(20), // 减少padding从40到20
              child: Column(
                children: [
                  // Header message
                  const Text(
                    '「チャージ操作」や「ポイント利用」が行えます',
                    style: TextStyle(
                      fontSize: 20, // 减少字体大小从24到20
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 20), // 减少间距从40到20
                  
                  // Prepaid balance section
                  _buildBalanceSection(
                    title: 'プリカ残高：',
                    amount: prepaidBalance,
                    unit: '円',
                    buttonText: 'チャージ',
                    buttonColor: const Color(0xFF4A6FA5),
                    onButtonPressed: _handleCharge,
                  ),
                  
                  const Divider(height: 20, thickness: 1), // 减少间距从40到20
                  
                  // Points section
                  _buildPointsSection(),
                  
                  const Divider(height: 20, thickness: 1), // 减少间距从40到20
                  
                  // Payment summary section
                  _buildPaymentSummary(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceSection({
    required String title,
    required int amount,
    required String unit,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onButtonPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(10), // 减少padding从20到10
      child: Row(
        children: [
          // Title
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20, // 减少字体大小从24到20
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          // Amount
          Expanded(
            flex: 3,
            child: Text(
              '${amount.toString().replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              )}$unit',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24, // 减少字体大小从28到24
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          // Action button
          Expanded(
            flex: 2,
            child: Container(
              height: 50, // 减少高度从60到50
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onButtonPressed,
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // 减少字体大小从18到14
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSection() {
    return Container(
      padding: const EdgeInsets.all(10), // 减少padding从20到10
      child: Column(
        children: [
          // Points balance
          Row(
            children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'ポイント残高：',
                  style: TextStyle(
                    fontSize: 20, // 减少字体大小从24到20
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${pointBalance.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}P',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24, // 减少字体大小从28到24
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 50, // 减少高度从60到50
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FA5),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handlePointPayment,
                      borderRadius: BorderRadius.circular(8),
                      child: const Center(
                        child: Text(
                          'ポイント\n支払',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12, // 减少字体大小从16到12
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10), // 减少间距从20到10
          
          // Used points
          Row(
            children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'ご利用ポイント：',
                  style: TextStyle(
                    fontSize: 20, // 减少字体大小从24到20
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${usedPoints}P',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24, // 减少字体大小从28到24
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const Expanded(flex: 2, child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(10), // 减少padding从20到10
      child: Column(
        children: [
          // Total amount
          Row(
            children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'お会計金額：',
                  style: TextStyle(
                    fontSize: 20, // 减少字体大小从24到20
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${finalTotalAmount.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}円',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24, // 减少字体大小从28到24
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Payment button
              Expanded(
                flex: 2,
                child: Container(
                  height: 50, // 减少高度从60到50
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _processPayment,
                      borderRadius: BorderRadius.circular(8),
                      child: const Center(
                        child: Text(
                          '支払い',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16, // 减少字体大小从18到16
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10), // 减少间距从20到10
          
          // Insufficient amount (if any)
          if (hasInsufficientFunds) ...[
            Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    '不足額：',
                    style: TextStyle(
                      fontSize: 20, // 减少字体大小从24到20
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '${remainingAmount.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )}円',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24, // 减少字体大小从28到24
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50, // 减少高度从60到50
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _handleCashPayment,
                        borderRadius: BorderRadius.circular(8),
                        child: const Center(
                          child: Text(
                            '不足額を\n現金支払',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12, // 减少字体大小从14到12
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _handleCharge() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('チャージ操作を開始します'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handlePointPayment() {
    // For demo, use some points
    setState(() {
      int maxUsablePoints = pointBalance < finalTotalAmount ? pointBalance : finalTotalAmount;
      usedPoints = maxUsablePoints;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${usedPoints}ポイントを利用します'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleCashPayment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('不足額${remainingAmount}円を現金で支払います'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Navigate to payment completion
    Future.delayed(const Duration(seconds: 1), () {
      _completePayment();
    });
  }

  Future<void> _processPayment() async {
    if (widget.cartId == null) {
      _showErrorMessage();
      return;
    }

    try {
      // Show loading message
      _showLoadingMessage();

      // 1) Fetch cart before payment
      print('[PrepaidPayment] Fetching cart before payment. cartId=${widget.cartId}');
      final beforeCart = await ApiService.getCart(widget.cartId!);
      double? serverBalance;
      if (beforeCart != null) {
        dynamic bal = beforeCart['balanceAmount'] ?? beforeCart['balance'] ?? beforeCart['remaining'] ?? beforeCart['remainingAmount'];
        if (bal is num) {
          serverBalance = bal.toDouble();
        } else {
          final dynamic totalWithTax = beforeCart['totalAmountWithTax'];
          final dynamic deposit = beforeCart['depositAmount'];
          if (totalWithTax is num) {
            final double paid = deposit is num ? deposit.toDouble() : 0.0;
            serverBalance = (totalWithTax.toDouble() - paid);
            if (serverBalance! < 0) serverBalance = 0.0;
          }
        }
      }
      print('[PrepaidPayment] Server balance before payment: ' + (serverBalance?.toString() ?? 'null'));

      // 2) Decide payment amount based on server balance if available, otherwise fallback to UI total
      final double uiAmount = finalTotalAmount.toDouble();
      final double paymentAmount = (serverBalance != null && serverBalance > 0) ? serverBalance! : uiAmount;

      print('[PrepaidPayment] Using payment amount: ' + paymentAmount.toString());

      // 3) Call payment API
      final paymentData = await ApiService.addPayment(
        cartId: widget.cartId!,
        paymentCode: '01', // prepaid
        amount: paymentAmount,
        detail: 'Prepaid card payment with ' + (usedPoints > 0 ? ('$usedPoints points') : 'no points'),
      );

      // Hide loading message
      ScaffoldMessenger.of(context).clearSnackBars();

      if (paymentData != null) {
        // 4) Verify cart after payment
        print('[PrepaidPayment] Payment success, verifying cart after payment...');
        final afterCart = await ApiService.getCart(widget.cartId!);
        double afterBalance = -1;
        if (afterCart != null) {
          final dynamic balanceValue = afterCart['balance'] ?? afterCart['remaining'] ?? afterCart['remainingAmount'];
          if (balanceValue is num) {
            afterBalance = balanceValue.toDouble();
          }
        }
        print('[PrepaidPayment] Server balance after payment: ' + afterBalance.toString());

        // Show success message
        _showSuccessMessage();

        // Wait a moment before navigation
        await Future.delayed(const Duration(milliseconds: 2000));

        // 5) Navigate to completion page
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentCompletionPage(
                totalAmount: finalTotalAmount,
                prepaidAmount: prepaidBalance,
                pointsUsed: usedPoints,
                cashAmount: hasInsufficientFunds ? remainingAmount : 0,
                cartId: widget.cartId,
              ),
            ),
          );
        }
      } else {
        print('[PrepaidPayment] Payment API returned null data');
        _showErrorMessage();
      }
    } catch (e) {
      print('Error processing payment: ' + e.toString());
      ScaffoldMessenger.of(context).clearSnackBars();
      _showErrorMessage();
    }
  }

  void _showLoadingMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              '支払い処理中です...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 30),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '支払いが正常に完了しました。ありがとうございました。',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '支払い処理に失敗しました。もう一度お試しください。',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _completePayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('支払い完了'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('お会計金額: ${finalTotalAmount}円'),
            Text('プリカ支払: ${prepaidBalance}円'),
            if (usedPoints > 0) Text('ポイント利用: ${usedPoints}P'),
            if (hasInsufficientFunds) Text('現金支払: ${remainingAmount}円'),
            const Text('\nお買い物ありがとうございました！'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to home or main screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('完了'),
          ),
        ],
      ),
    );
  }
} 