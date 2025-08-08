import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:io';

class ApiService {
  static String? _baseUrl;
  static String? _apiKey;
  static String? _terminalId;
  static bool _configLoaded = false;

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
      _configLoaded = true;
      
      print('Configuration loaded successfully from ${loadedFromLocal ? 'local file' : 'assets'}');
      print('Base URL: $_baseUrl');
    } catch (e) {
      print('Error loading configuration: $e');
      // Fallback to default values
      _baseUrl = 'http://localhost:8003/api/v1';
      _apiKey = '1px1jTk-rSxJVQB0A89o_N4stNUN_hi22gj9fqtnw4U';
      _terminalId = 'demo_tenant-STORE001-1';
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

  /// Create a new cart
  static Future<Map<String, dynamic>?> createCart({
    int transactionType = 101,
    String userId = "99",
    String userName = "John Doe",
  }) async {
    try {
      // First try the real API
      final baseUrlValue = await baseUrl;
      final terminalIdValue = await terminalId;
      final apiKeyValue = await apiKey;
      
      final url = Uri.parse('$baseUrlValue/carts?terminal_id=$terminalIdValue');
      
      final response = await http.post(
        url,
        headers: {
          'X-API-Key': apiKeyValue,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'transaction_type': transactionType,
          'user_id': userId,
          'user_name': userName,
        }),
      ).timeout(const Duration(seconds: 5));

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
      
      final url = Uri.parse('$baseUrlValue/carts/$cartId/lineItems?terminal_id=$terminalIdValue');
      
      final response = await http.post(
        url,
        headers: {
          'X-API-Key': apiKeyValue,
          'Content-Type': 'application/json',
        },
        body: jsonEncode([
          {
            'item_code': itemCode,
            'quantity': quantity,
            'unit_price': unitPrice,
          }
        ]),
      );

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
      
      final url = Uri.parse('$baseUrlValue/carts/$cartId?terminal_id=$terminalIdValue');
      
      final response = await http.get(
        url,
        headers: {
          'X-API-Key': apiKeyValue,
        },
      );

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
      
      final url = Uri.parse('$baseUrlValue/carts/$cartId/subtotal?terminal_id=$terminalIdValue');
      
      final response = await http.post(
        url,
        headers: {
          'X-API-Key': apiKeyValue,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      ).timeout(const Duration(seconds: 5));

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
      
      final url = Uri.parse('$baseUrlValue/carts/$cartId/payments?terminal_id=$terminalIdValue');
      
      final response = await http.post(
        url,
        headers: {
          'X-API-Key': apiKeyValue,
          'Content-Type': 'application/json',
        },
        body: jsonEncode([
          {
            'paymentCode': paymentCode,
            'amount': amount,
            'detail': detail,
          }
        ]),
      ).timeout(const Duration(seconds: 5));

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
} 