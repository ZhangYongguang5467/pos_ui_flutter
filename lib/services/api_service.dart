import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8003/api/v1';
  static const String apiKey = '1px1jTk-rSxJVQB0A89o_N4stNUN_hi22gj9fqtnw4U';
  static const String terminalId = 'demo_tenant-STORE001-1';

  /// Create a new cart
  static Future<Map<String, dynamic>?> createCart({
    int transactionType = 101,
    String userId = "99",
    String userName = "John Doe",
  }) async {
    try {
      // First try the real API
      final url = Uri.parse('$baseUrl/carts?terminal_id=$terminalId');
      
      final response = await http.post(
        url,
        headers: {
          'X-API-Key': apiKey,
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
      final url = Uri.parse('$baseUrl/carts/$cartId/lineItems?terminal_id=$terminalId');
      
      final response = await http.post(
        url,
        headers: {
          'X-API-Key': apiKey,
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
      final url = Uri.parse('$baseUrl/carts/$cartId?terminal_id=$terminalId');
      
      final response = await http.get(
        url,
        headers: {
          'X-API-Key': apiKey,
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
      final url = Uri.parse('$baseUrl/carts/$cartId/subtotal?terminal_id=$terminalId');
      
      final response = await http.post(
        url,
        headers: {
          'X-API-Key': apiKey,
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
      final url = Uri.parse('$baseUrl/carts/$cartId/payments?terminal_id=$terminalId');
      
      final response = await http.post(
        url,
        headers: {
          'X-API-Key': apiKey,
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