import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;

/// Thin wrapper around the FastAPI backend. Base URL is the only thing that
/// changes between local dev, staging and the hackathon demo deployment.
/// 10.0.2.2 is the Android emulator's alias for the host machine's localhost;
/// on Chrome/desktop debug this should be overridden to plain localhost.
class ApiClient {
  ApiClient({this.baseUrl = 'http://localhost:8000'});

  final String baseUrl;

  /// Uploads the farmer's photo so /diagnoses can run vision inference on it
  /// server-side — the app itself only ever holds a local/blob path, never
  /// something the backend can read directly. Returns the server-side
  /// `image_ref` to pass to [createDiagnosis].
  Future<String> uploadImage(Uint8List bytes, {required String filename, required String contentType}) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/images/upload'))
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename, contentType: MediaType.parse(contentType)));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['image_ref'] as String;
  }

  Future<Map<String, dynamic>> createDiagnosis({
    required String farmerId,
    required String cropId,
    String? imageRef,
    Map<String, dynamic>? symptoms,
    String source = 'online',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/diagnoses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'farmer_id': farmerId,
        'crop_id': cropId,
        'image_ref': imageRef,
        'symptoms': symptoms,
        'source': source,
      }),
    );
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDiagnosis(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/diagnoses/$id'));
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getFieldWorkerQueue() async {
    final response = await http.get(Uri.parse('$baseUrl/field-worker/queue'));
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> resolveReview(String diagnosisId, String notesBn) async {
    final response = await http.post(
      Uri.parse('$baseUrl/field-worker/reviews/$diagnosisId/resolve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'notes_bn': notesBn}),
    );
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDemoContext() async {
    final response = await http.get(Uri.parse('$baseUrl/demo/context'));
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDashboardTrends() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard/trends'));
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}
