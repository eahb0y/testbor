import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:testbor/core/errors/app_exception.dart';

class GraphqlHttpClient {
  GraphqlHttpClient({required http.Client httpClient})
    : _httpClient = httpClient;

  final http.Client _httpClient;

  Future<Map<String, dynamic>> request({
    required String endpoint,
    required String document,
    Map<String, dynamic> variables = const {},
    String? bearerToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (bearerToken != null && bearerToken.isNotEmpty)
        'Authorization': 'Bearer $bearerToken',
    };

    late http.Response response;
    try {
      response = await _httpClient.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode(<String, dynamic>{
          'query': document,
          'variables': variables,
        }),
      );
    } catch (error) {
      throw NetworkException('Network error: $error');
    }

    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw NetworkException(
        'Invalid server response (${response.statusCode})',
      );
    }

    if (response.statusCode != 200) {
      throw NetworkException(
        'Request failed with status ${response.statusCode}',
      );
    }

    final errors = payload['errors'];
    if (errors is List && errors.isNotEmpty) {
      final parsedErrors = errors.whereType<Map<String, dynamic>>().map((raw) {
        final extensions = raw['extensions'];
        final code = extensions is Map<String, dynamic>
            ? extensions['code'] as String?
            : null;
        return GraphqlError(
          message: raw['message'] as String? ?? 'Unknown GraphQL error',
          code: code,
        );
      }).toList();
      throw GraphqlException(errors: parsedErrors);
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw NetworkException('GraphQL data payload is missing');
    }

    return data;
  }
}
