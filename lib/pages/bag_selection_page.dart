import 'package:flutter/material.dart';
import 'payment_method_page.dart';
import '../services/api_service.dart';

class BagSelectionPage extends StatefulWidget {
  final List<dynamic> cartItems;
  final int totalAmount;
  final String? cartId;

  const BagSelectionPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    this.cartId,
  });

  @override
  State<BagSelectionPage> createState() => _BagSelectionPageState();
}

class _BagSelectionPageState extends State<BagSelectionPage> {
  int selectedBagCount = 1; // Default selection is 1 bag
  final int bagPrice = 3; // 3円 per bag

  int get totalWithBags => widget.totalAmount + (selectedBagCount * bagPrice);

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
                  'レジ袋',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Shopping stop button
                Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FA5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'お買物\n中止',
                      textAlign: TextAlign.center,
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
              padding: const EdgeInsets.all(40),
              child: Row(
                children: [
                  // Left side - Bag image and price
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bag image
                        Container(
                          width: 300,
                          height: 300,
                          padding: const EdgeInsets.all(20),
                          child: CustomPaint(
                            size: const Size(260, 260),
                            painter: BagPainter(),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Price per bag
                        const Text(
                          '3円/枚',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 60),
                  
                  // Right side - Selection area
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        
                        // Selection status text
                        Text(
                          '${selectedBagCount}枚選択されています',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 80),
                        
                        // Bag quantity selection grid
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 4,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.2,
                            children: [
                              // 1-4 bags (top row)
                              _buildBagButton(1, isSelected: selectedBagCount == 1, isOrange: true),
                              _buildBagButton(2, isSelected: selectedBagCount == 2),
                              _buildBagButton(3, isSelected: selectedBagCount == 3),
                              _buildBagButton(4, isSelected: selectedBagCount == 4),
                              
                              // 5-7 bags and "不要" (bottom row)
                              _buildBagButton(5, isSelected: selectedBagCount == 5),
                              _buildBagButton(6, isSelected: selectedBagCount == 6),
                              _buildBagButton(7, isSelected: selectedBagCount == 7),
                              _buildNoBagButton(isSelected: selectedBagCount == 0),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Next button
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 120,
                            height: 60,
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
                                onTap: () {
                                  // Navigate to next page (employee confirmation)
                                  _proceedToNextStep();
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: const Center(
                                  child: Text(
                                    '次へ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBagButton(int count, {required bool isSelected, bool isOrange = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange : Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(color: Colors.orange[700]!, width: 3)
            : null,
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
          onTap: () {
            setState(() {
              selectedBagCount = count;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text: '枚',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoBagButton({required bool isSelected}) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[400] : Colors.grey[400],
        borderRadius: BorderRadius.circular(8),
        border: isSelected 
            ? Border.all(color: Colors.grey[600]!, width: 3)
            : null,
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
          onTap: () {
            setState(() {
              selectedBagCount = 0;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: const Center(
            child: Text(
              '不要',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _proceedToNextStep() async {
    if (widget.cartId == null) {
      _showErrorMessage();
      return;
    }

    try {
      // Show loading indicator
      _showLoadingMessage();

      // Add bags to cart if any selected
      if (selectedBagCount > 0) {
        final bagData = await ApiService.addBagToCart(
          cartId: widget.cartId!,
          quantity: selectedBagCount,
          unitPrice: bagPrice.toDouble(),
        );
        
        if (bagData == null) {
          ScaffoldMessenger.of(context).clearSnackBars();
          _showBagErrorMessage();
          return;
        }
      }

      // Call subtotal API
      final subtotalData = await ApiService.calculateSubtotal(widget.cartId!);
      
      // Hide loading indicator
      ScaffoldMessenger.of(context).clearSnackBars();

      if (subtotalData != null) {
        // Show success message
        _showSuccessMessage();
        
        // Wait a moment before navigation
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // Navigate to payment method page
        if (mounted) {
                      Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentMethodPage(
                  cartItems: widget.cartItems,
                  totalAmount: widget.totalAmount,
                  bagCount: selectedBagCount,
                  bagPrice: bagPrice,
                  cartId: widget.cartId,
                ),
              ),
            );
        }
      } else {
        _showErrorMessage();
      }
    } catch (e) {
      print('Error in proceed to next step: $e');
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
              'レジ袋を追加して小計を計算しています...',
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
          '小計の計算が完了しました。お支払い方法を選択してください。',
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
          '小計の計算に失敗しました。もう一度お試しください。',
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

  void _showBagErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'レジ袋の追加に失敗しました。もう一度お試しください。',
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
}

class BagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    
    // Draw bag outline
    // Main bag body
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width * 0.75, size.height * 0.9);
    path.lineTo(size.width * 0.25, size.height * 0.9);
    path.close();
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
    
    // Draw handles
    final handlePaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    // Left handle
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.1),
      Offset(size.width * 0.25, size.height * 0.3),
      handlePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.1),
      Offset(size.width * 0.35, size.height * 0.3),
      handlePaint,
    );
    
    // Right handle
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.1),
      Offset(size.width * 0.65, size.height * 0.3),
      handlePaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.1),
      Offset(size.width * 0.75, size.height * 0.3),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 