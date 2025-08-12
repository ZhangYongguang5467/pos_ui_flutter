import 'package:flutter/material.dart';
import 'shopping_page.dart';

class PinInputPage extends StatefulWidget {
  const PinInputPage({super.key});

  @override
  State<PinInputPage> createState() => _PinInputPageState();
}

class _PinInputPageState extends State<PinInputPage> {
  String _pinInput = '';
  final int _maxPinLength = 4;

  void _onNumberPressed(String number) {
    if (_pinInput.length < _maxPinLength) {
      setState(() {
        _pinInput += number;
      });
      
      // Auto navigate when 4 digits are entered
      if (_pinInput.length == _maxPinLength) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ShoppingPage(),
            ),
          );
        });
      }
    }
  }

  void _onClearPressed() {
    setState(() {
      _pinInput = '';
    });
  }

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
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Center title
                const Center(
                  child: Text(
                    'PIN入力',
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
                    ],
                  ),
                ),
                // Right badge
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
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
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Row(
                children: [
                  // Left side - Card information
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          'PINコードを入力してください',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // PIN display
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: List.generate(4, (index) {
                              return Container(
                                width: 60,
                                height: 80,
                                margin: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    index < _pinInput.length ? '●' : '',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Card display
                        Container(
                          width: 350,
                          height: 220,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TRIAL header
                                Container(
                                  width: double.infinity,
                                  height: 30,
                                  color: Colors.black,
                                  child: const Center(
                                    child: Text(
                                      'TRIAL',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // Card details
                                Row(
                                  children: [
                                    // Left side - barcode lines
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: List.generate(15, (index) {
                                          return Container(
                                            height: 2,
                                            color: Colors.black,
                                            margin: const EdgeInsets.only(bottom: 2),
                                          );
                                        }),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 16),
                                    
                                    // Right side - details and QR
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            children: List.generate(8, (index) {
                                              return Container(
                                                height: 2,
                                                color: Colors.black,
                                                margin: const EdgeInsets.only(bottom: 2),
                                              );
                                            }),
                                          ),
                                          
                                          const SizedBox(height: 8),
                                          
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'カード番号',
                                                      style: TextStyle(fontSize: 10),
                                                    ),
                                                    const Text(
                                                      '0000000000000',
                                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    const Text(
                                                      'PINコード',
                                                      style: TextStyle(fontSize: 10),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Text(
                                                        '0000',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // QR Code
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.black),
                                                ),
                                                child: Column(
                                                  children: List.generate(5, (row) {
                                                    return Expanded(
                                                      child: Row(
                                                        children: List.generate(5, (col) {
                                                          return Expanded(
                                                            child: Container(
                                                              color: (row + col) % 2 == 0 ? Colors.black : Colors.white,
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Bottom section
                                Row(
                                  children: [
                                    const Text(
                                      'NAME',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    // Bottom barcode
                                    Column(
                                      children: List.generate(3, (index) {
                                        return Container(
                                          height: 1,
                                          width: 80,
                                          color: Colors.black,
                                          margin: const EdgeInsets.only(bottom: 1),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                const Text(
                                  '0000000000000',
                                  style: TextStyle(fontSize: 8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 60),
                  
                  // Right side - Number keypad
                  Container(
                    width: 300,
                    child: Column(
                      children: [
                        // Number pad grid
                        for (int row = 0; row < 3; row++)
                          Row(
                            children: [
                              for (int col = 1; col <= 3; col++)
                                Expanded(
                                  child: Container(
                                    height: 80,
                                    margin: const EdgeInsets.all(8),
                                    child: ElevatedButton(
                                      onPressed: () => _onNumberPressed('${row * 3 + col}'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[200],
                                        foregroundColor: const Color(0xFF4A6FA5),
                                        elevation: 4,
                                        shadowColor: Colors.black.withOpacity(0.3),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        '${row * 3 + col}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        
                        // Bottom row with 0 and correction button
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 80,
                                margin: const EdgeInsets.all(8),
                                child: ElevatedButton(
                                  onPressed: () => _onNumberPressed('0'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: const Color(0xFF4A6FA5),
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    '0',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 80,
                                margin: const EdgeInsets.all(8),
                                child: ElevatedButton(
                                  onPressed: _onClearPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.black,
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    '訂正',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
} 