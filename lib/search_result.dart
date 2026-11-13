import 'package:flutter/material.dart';
import 'api_client.dart';

/// 検索結果画面(仮)：見つかった投稿を単純に並べるだけ
class SearchResultPage extends StatefulWidget {
  final String keyword;
  const SearchResultPage({super.key, required this.keyword});

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late final Future<List<Map<String, dynamic>>> _future =
      ApiClient.searchPosts(widget.keyword);

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