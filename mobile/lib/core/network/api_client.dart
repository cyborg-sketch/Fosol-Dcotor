import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;

import '../../features/offline/offline_cache.dart';

/// Thin wrapper around the FastAPI backend. Base URL is the only thing that
/// changes between local dev, staging and the hackathon demo deployment.
/// Defaults to the laptop's hotspot IP (10.177.56.48:8000) or user-configured IP.
class ApiClient {
  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? _defaultBaseUrl;

  final String baseUrl;

  static String get _defaultBaseUrl {
    final saved = OfflineCache.getServerUrl();
    if (saved != null && saved.trim().isNotEmpty) {
      return saved.trim();
    }
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    if (!kIsWeb && Platform.isAndroid) {
      // 10.177.56.48 is the laptop's IP on the mobile phone hotspot network.
      return 'http://10.177.56.48:8000';
    }
    return 'http://localhost:8000';
  }

  static const _timeout = Duration(seconds: 15);

  /// Uploads the farmer's photo so /diagnoses can run vision inference on it
  /// server-side — the app itself only ever holds a local/blob path, never
  /// something the backend can read directly. Returns the server-side
  /// `image_ref` to pass to [createDiagnosis].
  Future<String> uploadImage(Uint8List bytes, {required String filename, required String contentType}) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/images/upload'))
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename, contentType: MediaType.parse(contentType)));
    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed).timeout(_timeout);
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['image_ref'] as String;
  }

  Future<Map<String, dynamic>> createDiagnosis({
    required String farmerId,
    String? cropId,
    String? imageRef,
    Map<String, dynamic>? symptoms,
    String source = 'online',
  }) async {
    final payload = <String, dynamic>{
      'farmer_id': farmerId,
      'image_ref': imageRef,
      'symptoms': symptoms,
      'source': source,
    };
    if (cropId != null) {
      payload['crop_id'] = cropId;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/diagnoses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(_timeout);
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDiagnosis(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/diagnoses/$id')).timeout(_timeout);
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getFieldWorkerQueue() async {
    final response = await http.get(Uri.parse('$baseUrl/field-worker/queue')).timeout(_timeout);
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
    ).timeout(_timeout);
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getCrops() async {
    final response = await http.get(Uri.parse('$baseUrl/crops')).timeout(_timeout);
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getDemoContext() async {
    final response = await http.get(Uri.parse('$baseUrl/demo/context')).timeout(_timeout);
    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDashboardTrends() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard/trends')).timeout(_timeout);
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
