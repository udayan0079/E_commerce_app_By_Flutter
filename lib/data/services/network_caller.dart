import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/network_response.dart';

/// Reusable HTTP client service supporting GET, POST, PATCH, and DELETE
/// with generous timeout for cold-starting cloud servers (e.g. Render free tier).
class NetworkCaller {
  static const Duration _timeoutDuration = Duration(seconds: 45);

  /// Execute GET Request
  static Future<NetworkResponse> getRequest({
    required String url,
    String? token,
  }) {
    return _executeRequest(
      method: 'GET',
      url: url,
      request: () => http.get(
        Uri.parse(url),
        headers: _buildHeaders(token),
      ),
    );
  }

  /// Execute POST Request
  static Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    String? token,
  }) {
    return _executeRequest(
      method: 'POST',
      url: url,
      body: body,
      request: () => http.post(
        Uri.parse(url),
        headers: _buildHeaders(token),
        body: jsonEncode(body),
      ),
    );
  }

  /// Execute PATCH Request
  static Future<NetworkResponse> patchRequest({
    required String url,
    Map<String, dynamic>? body,
    String? token,
  }) {
    return _executeRequest(
      method: 'PATCH',
      url: url,
      body: body,
      request: () => http.patch(
        Uri.parse(url),
        headers: _buildHeaders(token),
        body: jsonEncode(body),
      ),
    );
  }

  /// Execute DELETE Request
  static Future<NetworkResponse> deleteRequest({
    required String url,
    String? token,
  }) {
    return _executeRequest(
      method: 'DELETE',
      url: url,
      request: () => http.delete(
        Uri.parse(url),
        headers: _buildHeaders(token),
      ),
    );
  }

  static Future<NetworkResponse> _executeRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    required Future<http.Response> Function() request,
  }) async {
    try {
      log('$method Request: $url${body != null ? ', Body: $body' : ''}');
      final response = await request().timeout(_timeoutDuration);
      log('Response [${response.statusCode}]: ${response.body}');
      return _handleResponse(response);
    } on TimeoutException {
      log('$method Timeout on $url');
      return NetworkResponse(
        statusCode: -1,
        isSuccess: false,
        errorMessage: 'Server is waking up or connection timed out. Please try again.',
      );
    } catch (e) {
      log('$method Error on $url: $e');
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
