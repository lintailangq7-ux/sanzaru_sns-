import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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

  //ログイン
  static Future<Map<String, dynamic>> login(String username, String password) =>
      _authenticate('/api/login', {'username': username, 'password': password}, 200);

  //新規登録
  static Future<Map<String, dynamic>> register(
          String username, String displayName, String password) =>
      _authenticate('/api/register',
          {'username': username, 'displayName': displayName, 'password': password}, 201);

  /// 投稿一覧を取得
  static Future<List<Map<String, dynamic>>> fetchPosts() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/posts'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
     },
    );

    if (res.statusCode != 200) {
     throw ApiException('投稿の取得に失敗しました');
    }

    final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
    return data.cast<Map<String, dynamic>>();
  }        

  ///投稿を作成
  static Future<int> createPost({
    required String body,
    required String visibility,
    required List<XFile> images,
    required List<PlatformFile> audios,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/posts'),
    );

    // ヘッダー
    if (token != null && token!.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }

    // テキスト部分
    req.fields['body'] = body;
    req.fields['visibility'] = visibility;

    // 画像を追加（複数）
    for (var image in images) {
      req.files.add(await http.MultipartFile.fromPath(
        'images',
        image.path,
        filename: image.name,
      ));
    }

    // 音声を追加（複数）
    for (var audio in audios) {
      req.files.add(await http.MultipartFile.fromPath(
        'audios', 
        audio.path!,
        filename: audio.name,
      ));
    }

    // 送信実行
    final http.Response res;
    try {
      final streamed = await req.send();
      res = await http.Response.fromStream(streamed);
    } catch (_) {
      throw ApiException('サーバーに接続できませんでした');
    }

    // レスポンス解析
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

  /// 投稿編集
static Future<bool> updatePost(int postId, String newBody) async {
  final uri = Uri.parse('$baseUrl/api/posts/$postId');
  final res = await http.put(
    uri,
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {'body': newBody},
  );

  if (res.statusCode == 200) {
    return true;
  } else {
    final data = jsonDecode(res.body);
    throw ApiException(data['error'] ?? '編集に失敗しました');
  }
}

/// 投稿削除
static Future<bool> deletePost(int postId) async {
  final uri = Uri.parse('$baseUrl/api/posts/$postId');
  final res = await http.delete(
    uri,
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (res.statusCode == 200) {
    return true;
  } else {
    final data = jsonDecode(res.body);
    throw ApiException(data['error'] ?? '削除に失敗しました');
  }
}
  /// 履歴を取得  mode: 閲覧=1 いいね=2 ブックマーク=3
  static Future<List<Map<String, dynamic>>> fetchHistory({
    required int userId,
    required int mode,
  }) async {
    final uri = Uri.parse('$baseUrl/HistoryServlet').replace(
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

/// マイページ情報取得
static Future<Map<String, dynamic>> fetchMyPage({int? userId}) async {
  final uri = userId == null
      ? Uri.parse('$baseUrl/api/mypage/')
      : Uri.parse('$baseUrl/api/mypage/$userId');

  final res = await http.get(
    uri,
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (res.statusCode != 200) {
    final data = jsonDecode(res.body);
    throw ApiException(data['error'] ?? '情報の取得に失敗しました');
  }

  return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
}

/// プロフィール編集
static Future<Map<String, dynamic>> updateProfile({
  required String displayName,
  required String bio,
}) async {
  final uri = Uri.parse('$baseUrl/api/profile');
  final res = await http.put(
    uri,
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'displayName': displayName,
      'bio': bio,
    },
  );

  if (res.statusCode == 200) {
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  } else {
    final data = jsonDecode(res.body);
    throw ApiException(data['error'] ?? '更新に失敗しました');
  }
}

/// アカウント削除
static Future<void> deleteAccount() async {
  final uri = Uri.parse('$baseUrl/api/mypage/');
  final res = await http.delete(
    uri,
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  if (res.statusCode != 200) {
    final data = jsonDecode(res.body);
    throw ApiException(data['error'] ?? 'アカウント削除に失敗しました');
  }
  
  // 削除成功時：トークンをクリア
  token = null;
}
}



