import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'no_barcode_products_page.dart';
import 'bag_selection_page.dart';
import '../services/api_service.dart';
import 'dart:async';

class CartItem {
  final Map<String, dynamic> product;
  int quantity;
  final double taxRate; // per-item tax rate for display (e.g., 0.08 or 0.10)
  
  CartItem({required this.product, this.quantity = 1, required this.taxRate});
}

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  List<CartItem> _cartItems = [];
  String? _cartId;
  bool _isInitialized = false;
  final StringBuffer _scanBuffer = StringBuffer();
  Timer? _scanDebounce;

  int get _totalItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get _totalAmount => _cartItems.fold(0, (sum, item) => sum + ((item.product['price'] as int) * item.quantity));

  // Current tax rate derived from API (e.g., 0.10 for 10%)
  double? _taxRate;

  // Total amount including tax
  int get _totalAmountTaxIncluded => (_totalAmount * (1 + (_taxRate ?? 0))).round();

  // Line total including tax for a cart item (uses per-item tax rate)
  int _calculateLineTotalWithTax(CartItem item) {
    final int unitPrice = item.product['price'] as int; // price excl. tax
    final int lineSubtotal = unitPrice * item.quantity; // excl. tax
    return (lineSubtotal * (1 + item.taxRate)).round();
  }

  // Guess a per-item tax rate based on item code or name when server does not provide per-line tax info
  double _guessTaxRateForProduct(Map<String, dynamic> product) {
    final String code = (product['code'] ?? '').toString();
    final String name = (product['name'] ?? '').toString();

    // Example heuristic: coffee 8%, others 10%
    if (code.startsWith('COFFEE') || name.contains('コーヒー')) {
      return 0.08;
    }
    return 0.10; // default
  }

  // Refresh tax rate by fetching cart from API
  Future<void> _refreshTaxRateFromApi() async {
    if (_cartId == null) return;
    try {
      final cart = await ApiService.getCart(_cartId!);
      if (cart != null) {
        double? rate;
        final total = (cart['totalAmount'] as num?)?.toDouble();
        final withTax = (cart['totalAmountWithTax'] as num?)?.toDouble();
        if (total != null && withTax != null && total > 0) {
          rate = (withTax - total) / total;
        } else {
          final taxes = cart['taxes'];
          if (taxes is List && taxes.isNotEmpty) {
            final taxAmount = (taxes.first['taxAmount'] as num?)?.toDouble();
            final targetAmount = (taxes.first['targetAmount'] as num?)?.toDouble();
            if (taxAmount != null && targetAmount != null && targetAmount > 0) {
              rate = taxAmount / targetAmount;
            }
          }
        }
        setState(() {
          _taxRate = rate ?? _taxRate ?? 0.0;
        });
      }
    } catch (e) {
      // leave _taxRate unchanged on failure
      print('Failed to refresh tax rate from API: $e');
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      // Check if product already exists in cart
      int existingIndex = _cartItems.indexWhere((item) => item.product['name'] == product['name']);
      
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(CartItem(
          product: product,
          taxRate: _guessTaxRateForProduct(product),
        ));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeCart();
    _addKeyboardListener();
  }

  @override
  void dispose() {
    _scanDebounce?.cancel();
    _removeKeyboardListener();
    super.dispose();
  }

  void _addKeyboardListener() {
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  void _removeKeyboardListener() {
    RawKeyboard.instance.removeListener(_handleKeyEvent);
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;
      // If Enter pressed, treat as end-of-scan
      if (key == LogicalKeyboardKey.enter) {
        _scanDebounce?.cancel();
        if (_scanBuffer.isNotEmpty) {
          final String data = _scanBuffer.toString();
          _scanBuffer.clear();
          _onScanCompleted(data);
        }
        return;
      }
      
      // Manual keyboard shortcuts (ignore during scanning sequence)
      if (_scanBuffer.isEmpty && key == LogicalKeyboardKey.digit1) {
        _addProductByCode('COFFEE001', 'コーヒー', 25.0);
      } else if (_scanBuffer.isEmpty && key == LogicalKeyboardKey.digit2) {
        _addProductByCode('SANDWICH001', 'サンドイッチ', 35.0);
      }

      // Collect printable characters from HID scanner
      final String? ch = event.character;
      if (ch != null && ch.isNotEmpty) {
        final int code = ch.codeUnitAt(0);
        final bool isPrintable = code >= 32 && code != 127;
        if (isPrintable) {
          _scanBuffer.write(ch);
          _scanDebounce?.cancel();
          _scanDebounce = Timer(const Duration(milliseconds: 100), () {
            if (_scanBuffer.isNotEmpty) {
              final String data = _scanBuffer.toString();
              _scanBuffer.clear();
              _onScanCompleted(data);
            }
          });
        }
      }
    }
  }

  void _onScanCompleted(String data) {
    final String code = data.trim().toUpperCase();
    if (code.contains('COFFEE001')) {
      _addProductByCode('COFFEE001', 'コーヒー', 25.0);
      return;
    }
    if (code.contains('SANDWICH001')) {
      _addProductByCode('SANDWICH001', 'サンドイッチ', 35.0);
      return;
    }
    // Fallback: map single-key scans
    if (code == '1') {
      _addProductByCode('COFFEE001', 'コーヒー', 25.0);
      return;
    }
    if (code == '2') {
      _addProductByCode('SANDWICH001', 'サンドイッチ', 35.0);
      return;
    }
  }

  Future<void> _initializeCart() async {
    if (_isInitialized) return;
    
    try {
      final cartData = await ApiService.createCart(
        transactionType: 101,
        userId: "99",
        userName: "POS User",
      );
      
      if (cartData != null) {
        setState(() {
          _cartId = cartData['cartId'];
          _isInitialized = true;
        });
        
        // Show success message in Japanese
        if (mounted) {
          _showSuccessMessage();
        }
        // Fetch tax info for display
        await _refreshTaxRateFromApi();
      } else {
        // Show error message
        if (mounted) {
          _showErrorMessage();
        }
      }
    } catch (e) {
      print('Error initializing cart: $e');
      if (mounted) {
        _showErrorMessage();
      }
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'カートが正常に作成されました。商品の登録を開始してください。',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'カートの作成に失敗しました。もう一度お試しください。',
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

  Future<void> _addProductByCode(String itemCode, String itemName, double unitPrice) async {
    if (_cartId == null) {
      _showErrorMessage();
      return;
    }

    try {
      final cartData = await ApiService.addItemToCart(
        cartId: _cartId!,
        itemCode: itemCode,
        quantity: 1,
        unitPrice: unitPrice,
      );

      if (cartData != null) {
        // Add item to local cart display
        final product = {
          'name': itemName,
          'price': unitPrice.toInt(),
          'code': itemCode,
        };
        _addToCart(product);

         // Refresh tax rate from API (to ensure correct tax-inclusive display)
         await _refreshTaxRateFromApi();
         
         // Show success message
         _showProductAddedMessage(itemName);
      } else {
        _showProductErrorMessage(itemName);
      }
    } catch (e) {
      print('Error adding product $itemCode: $e');
      _showProductErrorMessage(itemName);
    }
  }

  void _showProductAddedMessage(String itemName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$itemNameを追加しました。',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showProductErrorMessage(String itemName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$itemNameの追加に失敗しました。',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
        children: [
          // Top navigation bar
          Container(
            height: 80,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Center title
                const Center(
                  child: Text(
                    '商品登録',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Left controls
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Staff call button
                      Container(
                        width: 100,
                        height: 40,
                                          decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                      onTap: null,
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
                      const SizedBox(width: 20),
                      // No barcode products button
                      Container(
                        width: 140,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A6FA5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final selectedProduct = await Navigator.push<Map<String, dynamic>>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NoBarcodeProductsPage(),
                                ),
                              );
                              
                              if (selectedProduct != null) {
                                _addToCart(selectedProduct);
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Center(
                              child: Text(
                                'バーコードが\nない商品',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Right controls
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Action buttons
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
                            onTap: _handleCancelShopping,
                            borderRadius: BorderRadius.circular(8),
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
                        ),
                      ),
                    const SizedBox(width: 20),
                    Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: null,
                      borderRadius: BorderRadius.circular(8),
                      child: const Center(
                        child: Text(
                          'チャージ\n確認',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                    ),
                    const SizedBox(width: 20),
                                     // Trial badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TRIAL',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                  ],
                ), // end Row (right controls)
              ), // end Align (right)
            ], // end Stack children
          ), // end Stack
        ), // end Container
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Conditional content based on cart status
                  if (_cartItems.isEmpty) ...[
                    // Original scanning instruction when cart is empty
                    const Text(
                      '商品のバーコードをスキャンしてください',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Keyboard shortcuts info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: const Text(
                        'キーボード操作: 1キー = コーヒー追加, 2キー = サンドイッチ追加',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Scanning areas
                    Expanded(
                      child: Row(
                        children: [
                          // Left side - Barcode products
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const Text(
                                  'バーコードが ある 商品',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        // Product image with barcode
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(20),
                                            child: Stack(
                                              children: [
                                                // Product package background
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[100],
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                // Barcode highlight
                                                Positioned(
                                                  bottom: 20,
                                                  left: 40,
                                                  right: 40,
                                                  child: Container(
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.red,
                                                        width: 3,
                                                      ),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: List.generate(8, (index) {
                                                        return Container(
                                                          height: 2,
                                                          color: Colors.black,
                                                          margin: const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 1,
                                                          ),
                                                        );
                                                      }),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Scanner device
                                        Container(
                                          height: 100,
                                          margin: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.qr_code_scanner,
                                              size: 50,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 40),
                          
                          // Right side - No barcode products area (showing apple without red border)
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                const SizedBox(height: 47), // Space to align with left side title
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        const Text(
                                          'バーコードが無い商品',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // Apple image
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(20),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.apple,
                                                  size: 100,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Cart items list when there are items
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          return _buildCartItem(_cartItems[index], index);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Bottom section - Shopping info and progress
          Container(
            height: _cartItems.isEmpty ? 120 : 60, // 动态调整高度：有商品时60，无商品时120
            color: Colors.grey[600],
            child: Column(
              children: [
                // Shopping info
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        '点数    : $_totalItemCount点',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 100),
                      Text(
                        'お買物金額: $_totalAmountTaxIncluded円(税込)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      // Item cancel button
                      Container(
                        width: 80,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: null,
                            borderRadius: BorderRadius.circular(8),
                            child: const Center(
                              child: Text(
                                '商品\n取消',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Next step button
                      Container(
                        width: 120,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              if (_cartItems.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BagSelectionPage(
                                      cartItems: _cartItems,
                                      totalAmount: _totalAmount,
                                      cartId: _cartId,
                                    ),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Center(
                              child: Text(
                                'お会計へ',
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
                    ],
                  ),
                ),
                
                // Progress bar - 只在没有商品时显示
                if (_cartItems.isEmpty)
                  Container(
                    height: 60,
                    color: const Color(0xFF4A6FA5),
                    child: Row(
                      children: [
                        // Step 1 - Active
                        Expanded(
                          child: Container(
                            color: Colors.orange,
                            child: const Center(
                              child: Text(
                                '商品登録',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Arrow
                        Container(
                          width: 30,
                          height: 60,
                          color: Colors.orange,
                          child: CustomPaint(
                            painter: ArrowPainter(),
                          ),
                        ),
                        // Step 2
                        Expanded(
                          child: Container(
                            color: Colors.orange[300],
                            child: const Center(
                              child: Text(
                                'レジ袋\n選択',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Arrow
                        Container(
                          width: 30,
                          height: 60,
                          color: Colors.orange[300],
                          child: CustomPaint(
                            painter: ArrowPainter(),
                          ),
                        ),
                        // Step 3
                        Expanded(
                          child: Container(
                            color: Colors.orange[200],
                            child: const Center(
                              child: Text(
                                '従業員\n確認',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Arrow
                        Container(
                          width: 30,
                          height: 60,
                          color: Colors.orange[200],
                          child: CustomPaint(
                            painter: ArrowPainter(),
                          ),
                        ),
                        // Step 4
                        Expanded(
                          child: Container(
                            color: Colors.orange[100],
                            child: const Center(
                              child: Text(
                                '支払(会計)\n方法選択',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Arrow
                        Container(
                          width: 30,
                          height: 60,
                          color: Colors.orange[100],
                          child: CustomPaint(
                            painter: ArrowPainter(),
                          ),
                        ),
                        // Step 5
                        Expanded(
                          child: Container(
                            color: Colors.grey[400],
                            child: const Center(
                              child: Text(
                                'お会計',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Arrow
                        Container(
                          width: 30,
                          height: 60,
                          color: Colors.grey[400],
                          child: CustomPaint(
                            painter: ArrowPainter(),
                          ),
                        ),
                        // Step 6
                        Expanded(
                          child: Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text(
                                '完了',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
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
        ],
      ),
      ),
    );
  }

  Future<void> _handleCancelShopping() async {
    if (_cartId == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('お買物を中止しています...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 30),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await ApiService.cancelCart(_cartId!);

      ScaffoldMessenger.of(context).clearSnackBars();
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('お買物の中止に失敗しました。もう一度お試しください。'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildCartItem(CartItem cartItem, int index) {
    final product = cartItem.product;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product name
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                // Product badges
                Wrap(
                  spacing: 8,
                  children: _getProductBadges(product['name']),
                ),
              ],
            ),
          ),
          
          // Quantity
          Expanded(
            flex: 1,
            child: Text(
              '${cartItem.quantity}点',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          // Price
          Expanded(
            flex: 1,
            child: Text(
              '${_calculateLineTotalWithTax(cartItem)}円',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          
          // Arrow and remove button
          Column(
            children: [
              // Up arrow
              GestureDetector(
                onTap: () => _addToCart(product),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Down arrow
              GestureDetector(
                onTap: () => _removeFromCart(index),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.pink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _getProductBadges(String productName) {
    List<Widget> badges = [];
    
    // Add badges based on product name (simulating different product types)
    if (productName.contains('赤兎馬') || productName.contains('梅酒')) {
      badges.add(_buildBadge('20禁', const Color(0xFF6B9BD8)));
      badges.add(_buildBadge('防犯', Colors.green));
    } else if (productName.contains('シャツ')) {
      badges.add(_buildBadge('値引', Colors.pink));
    } else if (productName.contains('田舎わっぱ飯')) {
      badges.add(_buildBadge('10倍', Colors.yellow));
      badges.add(_buildBadge('キャンペーン', Colors.orange));
    } else if (productName.contains('和風弁当')) {
      badges.add(_buildBadge('10P', Colors.yellow));
    } else if (productName.contains('婦人シューズ')) {
      badges.add(_buildBadge('お試し', Colors.orange));
    }
    
    return badges;
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.7, size.height * 0.5);
    path.lineTo(0, size.height * 0.7);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 