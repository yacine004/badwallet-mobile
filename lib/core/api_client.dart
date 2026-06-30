import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

/// Client HTTP centralisé : factorise GET/POST, le parsing JSON,
/// et la conversion des erreurs HTTP en ApiException lisibles.
class ApiClient {
  static const Duration _timeout = Duration(seconds: 10);

  static Future<dynamic> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Délai d\'attente dépassé. Le serveur ne répond pas.');
    } on ApiException {
      rethrow;
    } catch (e) {
      // Sur Flutter Web, une erreur CORS ou un serveur injoignable
      // remonte ici comme une exception générique (souvent ClientException).
      throw ApiException(
          'Impossible de joindre le serveur (réseau ou CORS). Détail : $e');
    }
  }

  static Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Délai d\'attente dépassé. Le serveur ne répond pas.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
          'Impossible de joindre le serveur (réseau ou CORS). Détail : $e');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;

    if (status >= 200 && status < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body;
      }
    }

    throw ApiException.fromStatusCode(status, rawBody: response.body);
  }
}
