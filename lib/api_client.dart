import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String get baseUrl {
  if (kIsWeb) return 'http://localhost:8080/SaruSNS';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8080/SaruSNS';
  return 'http://localhost:8080/SaruSNS';
}

/// 画面に出してよいエラー
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  static String? token;
  static Map<String, dynamic>? currentUser;

  static Future<Map<String, dynamic>> _authenticate(
      String path, Map<String, String> body, int okStatus) async {
    final http.Response res;
    try {
      res = await http.post(Uri.parse('$baseUrl$path'), body: body); // フォーム形式で送る
    } catch (_) {
      throw ApiException('サーバーに接続できませんでした');
    }
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('サーバーでエラーが起きました (${res.statusCode})');
    }
    if (res.statusCode != okStatus) {
      throw ApiException((data['error'] ?? 'エラーが発生しました') as String);
    }
    token = data['token'] as String;
    currentUser = data['user'] as Map<String, dynamic>;
    return currentUser!;
  }

  static Future<Map<String, dynamic>> login(String username, String password) =>
      _authenticate('/api/login', {'username': username, 'password': password}, 200);

  static Future<Map<String, dynamic>> register(
          String username, String displayName, String password) =>
      _authenticate('/api/register',
          {'username': username, 'displayName': displayName, 'password': password}, 201);
}