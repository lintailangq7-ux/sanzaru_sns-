import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'api_client.dart'; // baseUrl・ApiClient・ApiException を使う

// ★ 確認用のログイン（開発用。本番では使わない）
class ImageSearchDev {
  static const String mail = 'saru01@example.com';
  static const String password = 'password123';
}

/// 画像を送って検索
/// POST /api/search
/// SearchMode = 2
Future<List<Map<String, dynamic>>> searchByImage(XFile image) async {
  // ログインしていなければログイン
  if (ApiClient.token == null) {
    try {
      await ApiClient.login(
        ImageSearchDev.mail,
        ImageSearchDev.password,
      );
    } catch (e) {
      throw ApiException('ログインに失敗しました: $e');
    }
  }

  // 画像を読み込む
  final bytes = await image.readAsBytes();

  // MultipartRequestを作成
  final req = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/api/search'),
  );

  req.headers['Authorization'] = 'Bearer ${ApiClient.token}';

  // 画像検索モード
  req.fields['SearchMode'] = '2';

  // 画像を追加
  req.files.add(
    http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: image.name,
    ),
  );

  // リクエスト送信
  final http.Response res;

  try {
    res = await http.Response.fromStream(
      await req.send(),
    );
  } catch (_) {
    throw ApiException('サーバーに接続できませんでした');
  }

  // JSONを解析
  dynamic data;

  try {
    data = jsonDecode(
      utf8.decode(res.bodyBytes),
    );
  } catch (_) {
    throw ApiException(
      'サーバーでエラーが起きました (${res.statusCode})',
    );
  }

  // HTTPエラー
  if (res.statusCode != 200) {
    if (data is Map<String, dynamic>) {
      throw ApiException(
        data['error']?.toString() ?? '画像検索に失敗しました',
      );
    }

    throw ApiException('画像検索に失敗しました');
  }

  // レスポンスがListか確認
  if (data is! List) {
    throw ApiException('サーバーから不正なデータが返されました');
  }

  // Map<String, dynamic> に変換
  return data.map<Map<String, dynamic>>((item) {
    if (item is Map<String, dynamic>) {
      return item;
    }

    return Map<String, dynamic>.from(item as Map);
  }).toList();
}

/// 画像検索の結果画面
class ImageSearchResultPage extends StatefulWidget {
  /// 検索に使った画像
  final XFile image;

  const ImageSearchResultPage({
    super.key,
    required this.image,
  });

  @override
  State<ImageSearchResultPage> createState() =>
      _ImageSearchResultPageState();
}

class _ImageSearchResultPageState
    extends State<ImageSearchResultPage> {
  late final Future<List<Map<String, dynamic>>> _future =
      searchByImage(widget.image);

  late final Future<List<int>> _bytes =
      widget.image.readAsBytes();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('画像検索の結果'),
      ),
      body: Column(
        children: [
          // 検索に使った画像
          Padding(
            padding: const EdgeInsets.all(12),
            child: FutureBuilder<List<int>>(
              future: _bytes,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 120,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snap.hasError || !snap.hasData) {
                  return const SizedBox(
                    height: 120,
                    child: Center(
                      child: Text('画像を読み込めませんでした'),
                    ),
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    Uint8List.fromList(snap.data!),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // 似ていた投稿の一覧
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snap) {
                // 読み込み中
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // エラー
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        '${snap.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final posts = snap.data ?? [];

                // 検索結果なし
                if (posts.isEmpty) {
                  return const Center(
                    child: Text('似た画像は見つかりませんでした'),
                  );
                }

                // 検索結果
                return ListView.separated(
                  itemCount: posts.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final p = posts[i];

                    final body = p['body']?.toString() ?? '';
                    final userName =
                        p['userName']?.toString() ?? '';
                    final timeAgo =
                        p['timeAgo']?.toString() ?? '';
                    final similarity =
                        p['similarity']?.toString() ?? '';

                    return ListTile(
                      title: Text(body),
                      subtitle: Text(
                        '$userName  $timeAgo',
                      ),
                      trailing: Text(
                        '類似度 $similarity%',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
