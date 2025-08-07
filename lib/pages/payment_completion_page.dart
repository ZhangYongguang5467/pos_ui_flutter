import 'package:flutter/material.dart';

class PaymentCompletionPage extends StatefulWidget {
  final int totalAmount;
  final int prepaidAmount;
  final int pointsUsed;
  final int cashAmount;

  const PaymentCompletionPage({
    super.key,
    required this.totalAmount,
    required this.prepaidAmount,
    this.pointsUsed = 0,
    this.cashAmount = 0,
  });

  @override
  State<PaymentCompletionPage> createState() => _PaymentCompletionPageState();
}

class _PaymentCompletionPageState extends State<PaymentCompletionPage> {
  int _remainingSeconds = 5;

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
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
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Thank you message
                    const Text(
                      'ご利用ありがとうございました。',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Receipt message
                    const Text(
                      '『領収証』をお取りください',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                    
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
                        
                        const SizedBox(width: 100),
                        
                        // Female staff
                        _buildStaffAvatar(
                          hairColor: const Color(0xFF8B4513),
                          shirtColor: Colors.white,
                          apronColor: const Color(0xFF4A6FA5),
                          isMale: false,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 80),
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
      width: 200,
      height: 250,
      child: Column(
        children: [
          // Head
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDBB5), // Skin color
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                // Hair
                Positioned(
                  top: 0,
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: hairColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                  ),
                ),
                // Eyes
                Positioned(
                  top: 25,
                  left: 20,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: 25,
                  right: 20,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Mouth (smile)
                Positioned(
                  top: 45,
                  left: 30,
                  right: 30,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Body
          Container(
            width: 120,
            height: 160,
            child: Stack(
              children: [
                // Shirt
                Container(
                  width: 120,
                  height: 100,
                  decoration: BoxDecoration(
                    color: shirtColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Apron
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: apronColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
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
                // Arms
                Positioned(
                  top: 20,
                  left: -20,
                  child: Container(
                    width: 30,
                    height: 80,
                    decoration: BoxDecoration(
                      color: shirtColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: -20,
                  child: Container(
                    width: 30,
                    height: 80,
                    decoration: BoxDecoration(
                      color: shirtColor,
                      borderRadius: BorderRadius.circular(15),
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