import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:io';

class ApiService {
  static String? _baseUrl;
  static String? _apiKey;
  static String? _terminalId;
  static bool _configLoaded = false;

  // Printer config
  static String? _printerServiceUrl; // e.g., http://<host>/cgi-bin/epos/service.cgi
  static String? _printerDeviceId; // e.g., local_printer
  static int? _printerTimeoutMs; // e.g., 10000

  /// Load configuration from config.json file
  static Future<void> _loadConfig() async {
    if (_configLoaded) return;

    try {
      String configContent;
      bool loadedFromLocal = false;
      
      // First try to load from local file (for production)
      try {
        final file = File('config.json');
        if (await file.exists()) {
          configContent = await file.readAsString();
          loadedFromLocal = true;
          print('Configuration loaded from local file: config.json');
        } else {
          throw Exception('Local config.json not found');
        }
      } catch (e) {
        print('Failed to load local config.json: $e');
        // Fallback to assets (for development)
        try {
          configContent = await rootBundle.loadString('config.json');
          print('Configuration loaded from assets: config.json');
        } catch (assetError) {
          throw Exception('config.json not found in local directory or assets: $assetError');
        }
      }

      final config = jsonDecode(configContent);
      final apiConfig = config['api'];
      
      _baseUrl = apiConfig['baseUrl'];
      _apiKey = apiConfig['apiKey'];
      _terminalId = apiConfig['terminalId'];

      // Printer
      final printerConfig = config['printer'] ?? {};
      _printerServiceUrl = printerConfig['serviceUrl'];
      _printerDeviceId = printerConfig['deviceId'];
      _printerTimeoutMs = printerConfig['timeoutMs'];

      _configLoaded = true;
      
      print('Configuration loaded successfully from ${loadedFromLocal ? 'local file' : 'assets'}');
      print('Base URL: $_baseUrl');
      if (_printerServiceUrl != null) {
        print('Printer service: $_printerServiceUrl (device=$_printerDeviceId, timeoutMs=$_printerTimeoutMs)');
      }
    } catch (e) {
      print('Error loading configuration: $e');
      // Fallback to default values
      _baseUrl = 'http://localhost:8003/api/v1';
      _apiKey = '1px1jTk-rSxJVQB0A89o_N4stNUN_hi22gj9fqtnw4U';
      _terminalId = 'demo_tenant-STORE001-1';

      // Printer defaults (optional)
      _printerServiceUrl = null;
      _printerDeviceId = null;
      _printerTimeoutMs = 10000;

      _configLoaded = true;
      print('Using default configuration values');
    }
  }

  /// Get base URL, loading config if necessary
  static Future<String> get baseUrl async {
    await _loadConfig();
    return _baseUrl!;
  }

  /// Get API key, loading config if necessary
  static Future<String> get apiKey async {
    await _loadConfig();
    return _apiKey!;
  }

  /// Get terminal ID, loading config if necessary
  static Future<String> get terminalId async {
    await _loadConfig();
    return _terminalId!;
  }

  // Printer getters
  static Future<String?> get printerServiceUrl async {
    await _loadConfig();
    return _printerServiceUrl;
  }

  static Future<String?> get printerDeviceId async {
    await _loadConfig();
    return _printerDeviceId;
  }

  static Future<int?> get printerTimeoutMs async {
    await _loadConfig();
    return _printerTimeoutMs;
  }

  /// Create a new cart
  static Future<Map<String, dynamic>?> createCart({
    int transactionType = 101,
    String userId = "99",
    String userName = "John Doe",
  }) async {
    try {
      final baseUrlValue = await baseUrl;
      final terminalIdValue = await terminalId;
      final apiKeyValue = await apiKey;

      final urlString = '$baseUrlValue/carts?terminal_id=$terminalIdValue';
      final url = Uri.parse(urlString);

      final headers = {
        'X-API-Key': apiKeyValue,
        'Content-Type': 'application/json',
      };
      final bodyMap = {
        'transaction_type': transactionType,
        'user_id': userId,
        'user_name': userName,
      };
      final body = jsonEncode(bodyMap);

      final maskedKey = apiKeyValue.length > 8
          ? apiKeyValue.substring(0, 4) + '...' + apiKeyValue.substring(apiKeyValue.length - 4)
          : '***';
      print('[ApiService.createCart] URL: ' + urlString);
      print('[ApiService.createCart] Headers: ' + jsonEncode({'X-API-Key': maskedKey, 'Content-Type': headers['Content-Type']}));
      print('[ApiService.createCart] Body: ' + body);

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      print('[ApiService.createCart] Status: ' + response.statusCode.toString());
      print('[ApiService.createCart] Response: ' + response.body);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      print('Failed to create cart. Status: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('Error creating cart: $e');
      return null;
    }
  }

  /// Add items to cart
  static Future<Map<String, dynamic>?> addItemToCart({
    required String cartId,
    required String itemCode,
    required int quantity,
    required double unitPrice,
  }) async {
    try {
      final baseUrlValue = await baseUrl;
      final terminalIdValue = await terminalId;
      final apiKeyValue = await apiKey;

      final urlString = '$baseUrlValue/carts/$cartId/lineItems?terminal_id=$terminalIdValue';
      final url = Uri.parse(urlString);

      final headers = {
        'X-API-Key': apiKeyValue,
        'Content-Type': 'application/json',
      };
      final bodyMap = [
        {
          'item_code': itemCode,
          'quantity': quantity,
          'unit_price': unitPrice,
        }
      ];
      final body = jsonEncode(bodyMap);

      final maskedKey = apiKeyValue.length > 8
          ? apiKeyValue.substring(0, 4) + '...' + apiKeyValue.substring(apiKeyValue.length - 4)
          : '***';
      print('[ApiService.addItemToCart] URL: ' + urlString);
      print('[ApiService.addItemToCart] Headers: ' + jsonEncode({'X-API-Key': maskedKey, 'Content-Type': headers['Content-Type']}));
      print('[ApiService.addItemToCart] Body: ' + body);

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      print('[ApiService.addItemToCart] Status: ' + response.statusCode.toString());
      print('[ApiService.addItemToCart] Response: ' + response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      print('Failed to add item to cart. Status: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('Error adding item to cart: $e');
      return null;
    }
  }

  /// Get cart details
  static Future<Map<String, dynamic>?> getCart(String cartId) async {
    try {
      final baseUrlValue = await baseUrl;
      final terminalIdValue = await terminalId;
      final apiKeyValue = await apiKey;

      final urlString = '$baseUrlValue/carts/$cartId?terminal_id=$terminalIdValue';
      final url = Uri.parse(urlString);

      final headers = {
        'X-API-Key': apiKeyValue,
      };

      final maskedKey = apiKeyValue.length > 8
          ? apiKeyValue.substring(0, 4) + '...' + apiKeyValue.substring(apiKeyValue.length - 4)
          : '***';
      print('[ApiService.getCart] URL: ' + urlString);
      print('[ApiService.getCart] Headers: ' + jsonEncode({'X-API-Key': maskedKey}));

      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 10));

      print('[ApiService.getCart] Status: ' + response.statusCode.toString());
      print('[ApiService.getCart] Response: ' + response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      print('Failed to get cart. Status: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('Error getting cart: $e');
      return null;
    }
  }

  /// Calculate subtotal for cart
  static Future<Map<String, dynamic>?> calculateSubtotal(String cartId) async {
    try {
      final baseUrlValue = await baseUrl;
      final terminalIdValue = await terminalId;
      final apiKeyValue = await apiKey;

      final urlString = '$baseUrlValue/carts/$cartId/subtotal?terminal_id=$terminalIdValue';
      final url = Uri.parse(urlString);

      final headers = {
        'X-API-Key': apiKeyValue,
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({});

      final maskedKey = apiKeyValue.length > 8
          ? apiKeyValue.substring(0, 4) + '...' + apiKeyValue.substring(apiKeyValue.length - 4)
          : '***';
      print('[ApiService.calculateSubtotal] URL: ' + urlString);
      print('[ApiService.calculateSubtotal] Headers: ' + jsonEncode({'X-API-Key': maskedKey, 'Content-Type': headers['Content-Type']}));
      print('[ApiService.calculateSubtotal] Body: ' + body);

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      print('[ApiService.calculateSubtotal] Status: ' + response.statusCode.toString());
      print('[ApiService.calculateSubtotal] Response: ' + response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      print('Failed to calculate subtotal. Status: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('Error calculating subtotal: $e');
      return null;
    }
  }

  /// Add payment to cart
  static Future<Map<String, dynamic>?> addPayment({
    required String cartId,
    required String paymentCode,
    required double amount,
    required String detail,
  }) async {
    try {
      final baseUrlValue = await baseUrl;
      final terminalIdValue = await terminalId;
      final apiKeyValue = await apiKey;

      final urlString = '$baseUrlValue/carts/$cartId/payments?terminal_id=$terminalIdValue';
      final url = Uri.parse(urlString);

      final headers = {
        'X-API-Key': apiKeyValue,
        'Content-Type': 'application/json',
      };
      final bodyMap = [
        {
          'paymentCode': paymentCode,
          'amount': amount,
          'detail': detail,
        }
      ];
      final body = jsonEncode(bodyMap);

      final maskedKey = apiKeyValue.length > 8
          ? apiKeyValue.substring(0, 4) + '...' + apiKeyValue.substring(apiKeyValue.length - 4)
          : '***';
      print('[ApiService.addPayment] URL: ' + urlString);
      print('[ApiService.addPayment] Headers: ' + jsonEncode({'X-API-Key': maskedKey, 'Content-Type': headers['Content-Type']}));
      print('[ApiService.addPayment] Body: ' + body);

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      print('[ApiService.addPayment] Status: ' + response.statusCode.toString());
      print('[ApiService.addPayment] Response: ' + response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      print('Failed to add payment. Status: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('Error adding payment: $e');
      return null;
    }
  }

  /// Generate bill for cart
  static Future<Map<String, dynamic>?> generateBill(String cartId) async {
    try {
      final baseUrlValue = await baseUrl;
      final terminalIdValue = await terminalId;
      final apiKeyValue = await apiKey;

      final urlString = '$baseUrlValue/carts/$cartId/bill?terminal_id=$terminalIdValue';
      final url = Uri.parse(urlString);

      final headers = {
        'X-API-Key': apiKeyValue,
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({});

      // Debug logs (mask API key)
      final maskedKey = apiKeyValue.length > 8
          ? apiKeyValue.substring(0, 4) + '...' + apiKeyValue.substring(apiKeyValue.length - 4)
          : '***';
      print('[ApiService.generateBill] URL: ' + urlString);
      print('[ApiService.generateBill] Headers: ' + jsonEncode({'X-API-Key': maskedKey, 'Content-Type': headers['Content-Type']}));
      print('[ApiService.generateBill] Body: ' + body);

      final response = await http
          .post(
            url,
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      print('[ApiService.generateBill] Status: ' + response.statusCode.toString());
      print('[ApiService.generateBill] Response: ' + response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }

      print('Failed to generate bill. Status: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('Error generating bill: $e');
      return null;
    }
  }

  /// Add bags to cart
  static Future<Map<String, dynamic>?> addBagToCart({
    required String cartId,
    required int quantity,
    required double unitPrice,
  }) async {
    try {
      final baseUrlValue = await baseUrl;
      final terminalIdValue = await terminalId;
      final apiKeyValue = await apiKey;

      final urlString = '$baseUrlValue/carts/$cartId/lineItems?terminal_id=$terminalIdValue';
      final url = Uri.parse(urlString);

      final headers = {
        'X-API-Key': apiKeyValue,
        'Content-Type': 'application/json',
      };
      final bodyMap = [
        {
          'item_code': 'BAG001',
          'quantity': quantity,
          'unit_price': unitPrice,
        }
      ];
      final body = jsonEncode(bodyMap);

      final maskedKey = apiKeyValue.length > 8
          ? apiKeyValue.substring(0, 4) + '...' + apiKeyValue.substring(apiKeyValue.length - 4)
          : '***';
      print('[ApiService.addBagToCart] URL: ' + urlString);
      print('[ApiService.addBagToCart] Headers: ' + jsonEncode({'X-API-Key': maskedKey, 'Content-Type': headers['Content-Type']}));
      print('[ApiService.addBagToCart] Body: ' + body);

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      print('[ApiService.addBagToCart] Status: ' + response.statusCode.toString());
      print('[ApiService.addBagToCart] Response: ' + response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      print('Failed to add bag to cart. Status: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('Error adding bag to cart: $e');
      return null;
    }
  }

  /// Resume item entry for cart (change state from Paying back to EnteringItem)
  static Future<Map<String, dynamic>?> resumeItemEntry(String cartId) async {
    try {
      final baseUrlValue = await baseUrl;
      final terminalIdValue = await terminalId;
      final apiKeyValue = await apiKey;

      final urlString = '$baseUrlValue/carts/$cartId/resume-item-entry?terminal_id=$terminalIdValue';
      final url = Uri.parse(urlString);

      final headers = {
        'X-API-Key': apiKeyValue,
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({});

      final maskedKey = apiKeyValue.length > 8
          ? apiKeyValue.substring(0, 4) + '...' + apiKeyValue.substring(apiKeyValue.length - 4)
          : '***';
      print('[ApiService.resumeItemEntry] URL: ' + urlString);
      print('[ApiService.resumeItemEntry] Headers: ' + jsonEncode({'X-API-Key': maskedKey, 'Content-Type': headers['Content-Type']}));
      print('[ApiService.resumeItemEntry] Body: ' + body);

      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      print('[ApiService.resumeItemEntry] Status: ' + response.statusCode.toString());
      print('[ApiService.resumeItemEntry] Response: ' + response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      print('Failed to resume item entry. Status: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('Error resuming item entry: $e');
      return null;
    }
  }
} 