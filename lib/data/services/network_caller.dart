import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/network_response.dart';

/// Reusable HTTP client service supporting GET, POST, PATCH, and DELETE with request timeout.
class NetworkCaller {
  static const Duration _timeoutDuration = Duration(seconds: 15);

  /// Execute GET Request
  static Future<NetworkResponse> getRequest({
    required String url,
    String? token,
  }) async {
    try {
      log('GET Request: $url');
      final response = await http
          .get(
            Uri.parse(url),
            headers: _buildHeaders(token),
          )
          .timeout(_timeoutDuration);

      log('Response [${response.statusCode}]: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      log('GET Error on $url: $e');
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Execute POST Request
  static Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      log('POST Request: $url, Body: $body');
      final response = await http
          .post(
            Uri.parse(url),
            headers: _buildHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(_timeoutDuration);

      log('Response [${response.statusCode}]: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      log('POST Error on $url: $e');
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Execute PATCH Request
  static Future<NetworkResponse> patchRequest({
    required String url,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      log('PATCH Request: $url, Body: $body');
      final response = await http
          .patch(
            Uri.parse(url),
            headers: _buildHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(_timeoutDuration);

      log('Response [${response.statusCode}]: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      log('PATCH Error on $url: $e');
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Execute DELETE Request
  static Future<NetworkResponse> deleteRequest({
    required String url,
    String? token,
  }) async {
    try {
      log('DELETE Request: $url');
      final response = await http
          .delete(
            Uri.parse(url),
            headers: _buildHeaders(token),
          )
          .timeout(_timeoutDuration);

      log('Response [${response.statusCode}]: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      log('DELETE Error on $url: $e');
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  static Map<String, String> _buildHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'token': token,
    };
  }

  static NetworkResponse _handleResponse(http.Response response) {
    try {
      final decodedData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: true,
          responseData: decodedData,
        );
      } else {
        return NetworkResponse(
          statusCode: response.statusCode,
          isSuccess: false,
          errorMessage: decodedData is Map && decodedData.containsKey('msg')
              ? decodedData['msg']
              : (decodedData is Map && decodedData.containsKey('message')
                  ? decodedData['message']
                  : 'Request failed with status: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return NetworkResponse(
        statusCode: response.statusCode,
        isSuccess: false,
        errorMessage: 'Failed to parse server response.',
      );
    }
  }
}
