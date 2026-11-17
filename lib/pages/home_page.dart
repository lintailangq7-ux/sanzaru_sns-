import 'package:flutter/material.dart';
import 'package:srusns_frontend/Search.Dart' as search;
import '../api_client.dart';
import 'package:srusns_frontend/pages/post.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});
  

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  //投稿一覧のスクロール管理
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose(){
    _scrollController.dispose();
    super.dispose();
  }
  //検索画面へ遷移
  void openSearchPage() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const search.SearchPage(),
    ),
  );
}
 //選択中のタブ(おすすめ、フォロー中)
   int selectedTab = 0;

//共通メニューの選択状態
   int selectedIndex = 0;
   
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('投稿しました'),),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('さんさるトーク'),
      ),

      body: IndexedStack(
        index: selectedIndex,
        children: [
          ListView(
            children: [

            
          
        //タブボタン
        Row(children: [Expanded(child: ElevatedButton(onPressed:(){
          setState(() {
            selectedTab = 0;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: 
          selectedTab == 0 ? Colors.blue : Colors.grey[300],
          foregroundColor: 
          selectedTab == 0 ? Colors.white : Colors.black,
        ),
        child: const Text('おすすめ'),
        ),
        ),
        const SizedBox(width: 8),
        Expanded(child: ElevatedButton(
          onPressed: (){
            setState(() {
              selectedTab = 1 ;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: 
            selectedTab == 1 ? Colors.blue : Colors.grey[300],
            foregroundColor: 
            selectedTab == 1 ? Colors.white : Colors.black,
          ),
          child: const Text('フォロー中'),
        ),
        ),

        ],
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
      search.SearchPage(),
      PostPage(),
      const Center(
        child: Text('マイページ'),
      ),
        ],
      ),

      // 下部メニュー
      bottomNavigationBar: selectedIndex == 1
      ? null
      : BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //現在選択しているメニュー
        currentIndex: selectedIndex,
        //メニューを押したときの処理
        onTap: (index) {
          if(index == 2){
            openPostPage();
          }else{

          
          setState(() {
            selectedIndex = index;
          });
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

//投稿日時の表示
String formatPostTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'たった今';
  } else if (difference.inHours < 1) {
    return '${difference.inMinutes}分前';
  } else if (difference.inDays < 1) {
    return '${difference.inHours}時間前';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}日前';
  } else {
    return '${dateTime.year}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }
}
//いいね・コメント機能


class PostActions extends StatefulWidget {
  final DateTime createdAt;
  final int initialLikeCount;
  final List<String> initialComments;
  
  const PostActions({
    super.key,
    required this.createdAt,
    this.initialLikeCount = 0,
    this.initialComments = const [],
    
  });

  @override
  State<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<PostActions> {
  bool isLiked = false;
  bool showComments = false;

  late int likeCount;
  late List<String> comments;

  final TextEditingController commentController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    likeCount = widget.initialLikeCount;
    comments = List<String>.from(widget.initialComments);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  // コメント追加
  void addComment() {
    final text = commentController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      comments.add(text);
      commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),

        // 投稿日時
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            formatPostTime(widget.createdAt),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // いいね・コメント
        Row(
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  isLiked = !isLiked;
                  likeCount += isLiked ? 1 : -1;
                });
              },
              icon: Icon(
                isLiked
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: isLiked ? Colors.red : Colors.grey,
              ),
            ),

            Text('$likeCount'),

            const SizedBox(width: 20),

            IconButton(
              onPressed: () {
                setState(() {
                  showComments = !showComments;
                });
              },
              icon: const Icon(
                Icons.comment_outlined,
                color: Colors.blue,
              ),
            ),

            Text('${comments.length}'),
          ],
        ),

        // コメント欄
        if (showComments) ...[
          const Divider(),

          ...comments.map((comment) {
            return ListTile(
              dense: true,
              leading: const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person, size: 18),
              ),
              title: Text(comment),
            );
          }),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: 'コメントを入力...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),

              IconButton(
                onPressed: addComment,
                icon: const Icon(
                  Icons.send,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

