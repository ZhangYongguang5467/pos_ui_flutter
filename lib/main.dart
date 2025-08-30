import 'package:flutter/material.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'pages/self_checkout_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final shorebirdCodePush = ShorebirdCodePush();
  try {
    final isUpdateAvailable = await shorebirdCodePush.isNewPatchAvailableForDownload();
    if (isUpdateAvailable) {
      await shorebirdCodePush.downloadUpdateIfAvailable();
    }
  } catch (e) {
    debugPrint('Shorebird update check failed: $e');
  }
  
  runApp(const POSApp());
}

class POSApp extends StatelessWidget {
  const POSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Self Checkout',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SelfCheckoutPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
