
import 'package:flutter/material.dart';
import '../api_client.dart';
import 'login.dart';
import '../post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // 投稿一覧
  List<PostData> posts = [];

  // 投稿画面へ移動して、投稿内容を受け取る
  Future<void> openPostPage() async {
    final newPost = await Navigator.push<PostData>(
      context,
      MaterialPageRoute(
        builder: (context) => const PostPage(),
      ),
    );

    if (!mounted) return;

    // 投稿内容をホーム画面に追加
    if (newPost != null) {
      setState(() {
        posts.insert(0, newPost);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('さんさるトーク'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            '投稿一覧',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // 新しく投稿した内容を表示
          ...posts.map((post) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // アカウント表示（現在は仮）
                    const Row(
                      children: [
                        CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'ユーザー名',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // 公開範囲
                    Text(
                      post.visibility,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // テキスト
                    if (post.text.isNotEmpty)
                      Text(post.text),

                    // 画像
                    if (post.images.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: post.images.map((image) {
                          return FutureBuilder(
                            future: image.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  child: Image.memory(
                                    snapshot.data!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }

                              return const SizedBox(
                                width: 100,
                                height: 100,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),

                    // 音声
                    ...post.audios.map((audio) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.audio_file,
                          color: Colors.blue,
                        ),
                        title: Text(
                          audio.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),

          // 既存のサンプル投稿
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: const Text('ユーザー１'),
              subtitle: const Text('こんにちは！'),
            ),
          ),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: const Text('ユーザー２'),
              subtitle: const Text('今日もいい天気ですね'),
            ),
          ),
        ],
      ),

      // 下部メニュー
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,

        onTap: (index) {
          if (index == 2) {
            openPostPage();
          }
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '検索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: '投稿',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'マイページ',
          ),
        ],
      ),
    );
  }
}
