import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PrinterService {
  /// Sends a receipt print job to the Epson ePOS printer using SOAP XML.
  ///
  /// The content should be plain text with necessary escape sequences (e.g., \n as line breaks).
  static Future<bool> printReceipt({
    required String textContent,
    String barcodeType = 'ean13',
    String barcodeData = '',
    int barcodeWidth = 2,
    int barcodeHeight = 64,
    String barcodeHri = 'below',
    int feedBeforeCutUnit = 48,
  }) async {
    final serviceUrl = await ApiService.printerServiceUrl;
    final deviceId = await ApiService.printerDeviceId;
    final timeoutMs = await ApiService.printerTimeoutMs ?? 10000;

    if (serviceUrl == null || deviceId == null) {
      print('[PrinterService] Printer configuration missing. serviceUrl=$serviceUrl deviceId=$deviceId');
      return false;
    }

    final url = Uri.parse('$serviceUrl?devid=$deviceId&timeout=$timeoutMs');

    // Build SOAP XML body
    final soapEnvelope = _buildSoapEnvelope(
      textContent: textContent,
      barcodeType: barcodeType,
      barcodeData: barcodeData,
      barcodeWidth: barcodeWidth,
      barcodeHeight: barcodeHeight,
      barcodeHri: barcodeHri,
      feedBeforeCutUnit: feedBeforeCutUnit,
    );

    final headers = {
      'Content-Type': 'application/xml; charset=utf-8',
    };

    print('[PrinterService] URL: $url');
    print('[PrinterService] Headers: ${jsonEncode(headers)}');
    print('[PrinterService] Body: ' + soapEnvelope);

    try {
      final response = await http
          .post(url, headers: headers, body: soapEnvelope)
          .timeout(Duration(milliseconds: timeoutMs));

      print('[PrinterService] Status: ${response.statusCode}');
      print('[PrinterService] Response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('[PrinterService] Error sending print job: $e');
      return false;
    }
  }

  static String _buildSoapEnvelope({
    required String textContent,
    required String barcodeType,
    required String barcodeData,
    required int barcodeWidth,
    required int barcodeHeight,
    required String barcodeHri,
    required int feedBeforeCutUnit,
  }) {
    // Epson ePOS supports XML with <epos-print> namespace. Line breaks can be sent as &#10; or \n.
    // We will convert \n into &#10; entities.
    final encodedText = textContent
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('\n', '&#10;');

    final String barcodeXml = barcodeData.isNotEmpty
        ? '<barcode type="$barcodeType" width="$barcodeWidth" height="$barcodeHeight" hri="$barcodeHri">$barcodeData</barcode>'
        : '';

    return '''<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
  <s:Body>
    <epos-print xmlns="http://www.epson-pos.com/schemas/2011/03/epos-print">
      <text lang="ja" smooth="true">$encodedText</text>
      <feed unit="24"/>
      $barcodeXml
      <feed unit="$feedBeforeCutUnit"/>
      <cut/>
    </epos-print>
  </s:Body>
</s:Envelope>''';
  }
} 