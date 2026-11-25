import 'package:flutter/material.dart';
import 'post_card.dart';

/// 画像検索・音声検索の結果を、ホームと同じカードで一覧にする画面
class MediaSearchResultPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> posts;
  const MediaSearchResultPage({
    super.key,
    required this.title,
    required this.posts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: posts.isEmpty
          ? const Center(child: Text('見つかりませんでした'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (context, i) => PostCard(post: posts[i]),
            ),
    );
  }
}