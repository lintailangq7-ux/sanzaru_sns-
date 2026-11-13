import 'package:flutter/material.dart';
import '../api_client.dart';
import 'post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // 投稿一覧
  List<PostData> posts = [];

  // ★ここから追加: サーバーから取得した投稿
  List<Map<String, dynamic>> serverPosts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ApiClient.fetchPosts();
      if (!mounted) return;
      setState(() {
        serverPosts = result;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '投稿の読み込みに失敗しました';
        _loading = false;
      });
    }
  }
  // ★ここまで追加

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

          // ★サーバーから取得した投稿
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Column(
              children: [
                Text(_error!),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadPosts,
                  child: const Text('再読み込み'),
                ),
              ],
            )
          else if (serverPosts.isEmpty)
            const Center(child: Text('まだ投稿がありません'))
          else
            ...serverPosts.map((post) {
              final user = post['user'] as Map<String, dynamic>? ?? {};
              final name = user['displayName'] ?? user['username'] ?? '不明';
              final content = post['content'] ?? post['text'] ?? '';
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name.toString()),
                  subtitle: Text(content.toString()),
                ),
              );
            }),
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

void main() {
  runApp(const MaterialApp(home: HomePage()));
}

