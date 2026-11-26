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

/// 送るファイル(中身と名前)
class UploadFile {
  final Uint8List bytes;
  final String name;
  UploadFile(this.bytes, this.name);
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

  //ログイン
  static Future<Map<String, dynamic>> login(String email, String password) =>
      _authenticate('/api/login', {'email': email, 'password': password}, 200);

  //新規登録
  static Future<Map<String, dynamic>> register(
          String email, String displayName, String password) =>
      _authenticate('/api/register',
          {'email': email, 'displayName': displayName, 'password': password}, 201);

  /// 投稿一覧を取得
  static Future<List<Map<String, dynamic>>> fetchPosts({bool homeOnly = false}) async {
final uri = Uri.parse('$baseUrl/api/posts').replace(
    queryParameters: {'homeOnly': homeOnly.toString()},
  );
  final res = await http.get(
    uri,
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  // ✅ デバッグ用：ステータスコードと内容を出力
  print('=== ステータスコード: ${res.statusCode}');
  print('=== レスポンス本文: ${res.body}');

  if (res.statusCode != 200) {
    throw ApiException('投稿の取得に失敗しました (${res.statusCode})');
  }

try {
    final Map<String, dynamic> responseData = jsonDecode(utf8.decode(res.bodyBytes));
    print('=== パース成功: $responseData');
    final List<dynamic> data = responseData['posts'] as List;
    return data.cast<Map<String, dynamic>>();
  } catch (e) {
    print('=== JSONパースエラー: $e');  // 👈 ここを追加！
    throw ApiException('投稿データの読み込みに失敗しました: $e');
  }
}

  ///投稿を作成
  static Future<int> createPost({
    required String body,
    required String visibility,
    List<UploadFile> images = const [],
    List<UploadFile> audios = const [],
  }) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/posts'));
    req.headers['Authorization'] = 'Bearer $token';
    req.fields['body'] = body;
    req.fields['visibility'] = visibility;
    for (final f in images) {
      req.files.add(http.MultipartFile.fromBytes('images', f.bytes, filename: f.name));
    }
    for (final f in audios) {
      req.files.add(http.MultipartFile.fromBytes('audios', f.bytes, filename: f.name));
    }

    final http.Response res;
    try {
      res = await http.Response.fromStream(await req.send());
    } catch (_) {
      throw ApiException('サーバーに接続できませんでした');
    }
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('サーバーでエラーが起きました (${res.statusCode})');
    }
    if (res.statusCode != 201) {
      throw ApiException((data['error'] ?? '投稿に失敗しました') as String);
    }
    return data['id'] as int;
  }

  
  /// テキスト検索 (SearchServlet)  SearchMode: テキスト=1 画像=2 音声=3
  static Future<List<Map<String, dynamic>>> searchPosts(String keyword) async {
    final uri = Uri.parse('$baseUrl/SearchServlet').replace(
        queryParameters: {'SearchText': keyword, 'SearchMode': '1'});
    final http.Response res;
    try {
      res = await http.get(uri, headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      });
    } catch (_) {
      throw ApiException('サーバーに接続できませんでした');
    }
    final dynamic data;
    try {
      data = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      throw ApiException('サーバーでエラーが起きました (${res.statusCode})');
    }
    if (res.statusCode != 200) {
      throw ApiException(
          ((data as Map)['error'] ?? '検索に失敗しました') as String);
    }
    return (data as List).cast<Map<String, dynamic>>();
  }

  /// 画像で検索(似た画像の投稿)
  static Future<List<Map<String, dynamic>>> searchByImage(UploadFile image) =>
      _searchByFile('/api/search/image', 'image', image);

  /// 音声で検索(録音した音に、音色が近い投稿)。WAV を送る
  static Future<List<Map<String, dynamic>>> searchByAudio(UploadFile audio) =>
      _searchByFile('/api/search/audio', 'audio', audio);

  static Future<List<Map<String, dynamic>>> _searchByFile(
      String path, String field, UploadFile file) async {
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    req.headers['Authorization'] = 'Bearer $token';
    req.files.add(http.MultipartFile.fromBytes(field, file.bytes, filename: file.name));
    final http.Response res;
    try {
      res = await http.Response.fromStream(await req.send());
    } catch (_) {
      throw ApiException('サーバーに接続できませんでした');
    }
    final dynamic data;
    try {
      data = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      throw ApiException('サーバーでエラーが起きました (${res.statusCode})');
    }
    if (res.statusCode != 200) {
      throw ApiException(((data as Map)['error'] ?? '検索に失敗しました') as String);
    }
    return (data as List).cast<Map<String, dynamic>>();
  }

    /// 画像・音声の中身を取る(トークン付き)。contentType は音声の再生に使う
  static Future<({Uint8List bytes, String contentType})> fetchMedia(int mediaId) async {
    final http.Response res;
    try {
      res = await http.get(
        Uri.parse('$baseUrl/api/media/$mediaId'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
    } catch (_) {
      throw ApiException('サーバーに接続できませんでした');
    }
    if (res.statusCode == 403) throw ApiException('このアカウントでは見られません');
    if (res.statusCode != 200) throw ApiException('読み込めませんでした (${res.statusCode})');
    return (bytes: res.bodyBytes, contentType: res.headers['content-type'] ?? '');
  }

  /// 履歴を取得 (/api/history)  mode: 閲覧=1 いいね=2 ブックマーク=3
  static Future<List<Map<String, dynamic>>> fetchHistory({
    required int userId,
    required int mode,
  }) async {
    final uri = Uri.parse('$baseUrl/api/history').replace(
        queryParameters: {'user_id': '$userId', 'HistoryMode': '$mode'});
    final http.Response res;
    try {
      res = await http.get(uri, headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      });
    } catch (_) {
      throw ApiException('サーバーに接続できませんでした');
    }
    final dynamic data;
    try {
      data = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      throw ApiException('サーバーでエラーが起きました (${res.statusCode})');
    }
    if (res.statusCode != 200) {
      throw ApiException(
          ((data as Map)['error'] ?? '履歴の取得に失敗しました') as String);
    }
    return (data as List).cast<Map<String, dynamic>>();
    
  }
}