import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_client.dart'; // baseUrl・ApiClient・ApiException を使う

// ★ 確認用のログイン(開発用。本番では使わない)
class SearchDev {
  static const String mail = 'saru01@example.com';
  static const String password = 'password123';
}

/// テキスト検索 (GET /api/search)  SearchMode: テキスト=1 画像=2 音声=3
Future<List<Map<String, dynamic>>> searchPosts(String keyword) async {
  if (ApiClient.token == null) {
    try {
      await ApiClient.login(SearchDev.mail, SearchDev.password);
    } catch (e) {
      throw ApiException('ログインに失敗しました: $e');
    }
  }

  final uri = Uri.parse('$baseUrl/api/search')
      .replace(queryParameters: {'q': keyword, 'SearchMode': '1'});
  final http.Response res;
  try {
    res = await http.get(uri, headers: {
      'Authorization': 'Bearer ${ApiClient.token}',
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

/// 検索結果画面(仮)：見つかった投稿を単純に並べるだけ
class SearchResultPage extends StatefulWidget {
  final String keyword;
  const SearchResultPage({super.key, required this.keyword});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late final Future<List<Map<String, dynamic>>> _future =
      searchPosts(widget.keyword);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('「${widget.keyword}」の検索結果')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('${snap.error}'));
          }
          final posts = snap.data!;
          if (posts.isEmpty) {
            return const Center(child: Text('見つかりませんでした'));
          }
          return ListView.separated(
            itemCount: posts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = posts[i];
              return ListTile(
                title: Text('${p['body'] ?? ''}'),
                subtitle: Text('${p['userName'] ?? ''}  ${p['timeAgo'] ?? ''}'),
              );
            },
          );
        },
      ),
    );
  }
}