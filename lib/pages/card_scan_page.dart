import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pin_input_page.dart';
import 'dart:async';

class CardScanPage extends StatefulWidget {
  const CardScanPage({super.key});

  @override
  State<CardScanPage> createState() => _CardScanPageState();
}

class _CardScanPageState extends State<CardScanPage> {
  // Buffer and timing for USB HID scanner input
  final StringBuffer _scanBuffer = StringBuffer();
  Timer? _scanDebounce;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Add keyboard listener
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    _scanDebounce?.cancel();
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Enter key: treat as end-of-scan or manual continue
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _scanDebounce?.cancel();
        if (_scanBuffer.isNotEmpty) {
          final String data = _scanBuffer.toString();
          _scanBuffer.clear();
          _onScanCompleted(data);
        } else {
          _goNext();
        }
        return;
      }

      // Collect printable characters (typical for HID scanners)
      final String? ch = event.character;
      if (ch != null && ch.isNotEmpty) {
        // Filter non-printable control characters
        final int code = ch.codeUnitAt(0);
        final bool isPrintable = code >= 32 && code != 127;
        if (isPrintable) {
          _scanBuffer.write(ch);
          // Debounce to decide end-of-scan when input pauses briefly
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
    // For login, scanner data content is not required; trigger same action as Enter
    _goNext();
  }

  void _goNext() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinInputPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: Scaffold(
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center title (always centered regardless of left/right content)
                    const Center(
                      child: Text(
                        'ログイン',
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
              
              const SizedBox(height: 40),
              
              // Main instruction text
              const Text(
                'トライアルカードのバーコードを\nスキャンしてください',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Instruction for Enter key
              const Text(
                'Press Enter to continue to PIN input',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Card scanner image area
              Expanded(
                child: Center(
                  child: Container(
                    width: 400,
                    height: 500,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Scanner device
                          Expanded(
                            flex: 3,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  // Scanner top part
                                  Container(
                                    height: 60,
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'カードをスキャンできます',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Scanner opening
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Trial card
                          Container(
                            width: 200,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF4A6FA5),
                                  Color(0xFF2B5797),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'TRIAL',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'PREPAID CARD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Bottom area with coins
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                // Coin section
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Coins
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFD4AF37),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '500',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFD4AF37),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '100',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFD4AF37),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '50',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Arrow
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 20),
                                // Yen symbol and amount display
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '￥',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(4),
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
                ),
              ),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
} 