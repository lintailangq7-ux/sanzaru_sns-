import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'result_bottom_bar.dart';
import 'api_client.dart'; // baseUrl・ApiClient・ApiException を使う
import 'post_card.dart'; // ホームと同じ投稿カード

/// テキスト検索 (GET /api/search?q=...)
Future<List<Map<String, dynamic>>> searchPosts(String keyword) async {
  if (ApiClient.token == null) {
    throw ApiException('ログインが必要です');
  }

  final uri = Uri.parse('$baseUrl/api/search')
      .replace(queryParameters: {'q': keyword});
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

/// 検索結果画面:見つかった投稿を、ホームと同じカードで並べる
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
      bottomNavigationBar: const ResultBottomBar(), 
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
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, i) => PostCard(post: posts[i]),
          );
        },
      ),
    );
  }
}