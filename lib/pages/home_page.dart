import 'package:flutter/material.dart';
import '../api_client.dart';
import 'package:audioplayers/audioplayers.dart';
import 'post.dart';
import '../Search.Dart' as search;





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
//マイページへ遷移

 //選択中のタブ(おすすめ、フォロー中)
   int selectedTab = 0;

//共通メニューの選択状態
   int selectedIndex = 1;
   
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

    int _requestId = 0; // 最新の読み込みだけを使うための番号

  Future<void> _loadPosts() async {
    final myRequest = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // フォロー中タブのときは、フォローしている人の投稿だけ
      final result = await ApiClient.fetchPosts(homeOnly: selectedTab == 1);
      if (!mounted || myRequest != _requestId) return;
      setState(() {
        serverPosts = result;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted || myRequest != _requestId) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || myRequest != _requestId) return;
      setState(() {
        _error = '投稿の読み込みに失敗しました';
        _loading = false;
      });
    }
  }

  // 最新投稿内容を受け取る
  Future<void> openPostPage() async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const PostPage(),
    ),
  );
  // ✅ 投稿後に最新の一覧を再取得
  _loadPosts();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('さんさるトーク'),
      ),
      
      // 投稿作成ボタン（ホーム画面のみ表示）
      floatingActionButton: selectedIndex == 1
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              tooltip: '投稿作成',
              onPressed: openPostPage,
              child: const Icon(
                Icons.add,
                size: 30,
              ),
            )
          : null,

      // メニューバーの上に配置
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,

      body: 
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
            if (selectedTab == 1) return; // すでにフォロー中なら何もしない
            setState(() => selectedTab = 1);
            _loadPosts(); // ← 追加:フォロー中の投稿を読み込み直す
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  selectedTab == 1
                      ? 'フォローしている人の投稿はまだありません'
                      : 'まだ投稿がありません',
                ),
              ),
            )
          else
...serverPosts.map((post) {
  final mediaList = (post['media'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  final images = mediaList.where((m) => m['type'] == 'image').toList();
  final audios = mediaList.where((m) => m['type'] == 'audio').toList();
  
  final userName = post['authorName']?.toString() ?? '不明';
  final content = post['content']?.toString() ?? post['text']?.toString() ?? '';
  final createdAt = DateTime.fromMillisecondsSinceEpoch((post['createdAt'] as int?) ?? 0);
  final textHidden = post['textHidden'] == true;
  // ✅ 自分のIDを正しく取得
  final myUserId = ApiClient.currentUser?['id'] as int? ?? 0;
  final postUserId = (post['userId'] as int?) ?? 0;
  final isMine = postUserId == myUserId;
  final viewerType = ApiClient.currentUser?['accountType']?.toString() ?? 'unknown';

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ユーザー名
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 本文
         


if (textHidden) ...[
  const SizedBox(height: 10),
  const Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
    child: Text(
      '🙊 あなたは本文を見ることができません',
      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
    ),
  ),
] else if (content.isNotEmpty) ...[
  const SizedBox(height: 10),
  Text(content),
],



          // ✅ 画像表示：サーバーの blocked を使う
          if (images.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: images.map((img) {
                final bool blocked = img['blocked'] == true;
                final mediaId = img['id'];

                if (blocked) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '🙈 あなたは画像を見ることができません',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  );
                }

                final imageUrl = '$baseUrl/api/media/$mediaId?token=${ApiClient.token}';
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        width: 100, height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        width: 100, height: 100,
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ],

          // ✅ 音声表示：同じく blocked を使う
          if (audios.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...audios.asMap().entries.map((e) {
              final audio = e.value;
              final bool blocked = audio['blocked'] == true;
              final mediaId = audio['id'];

              if (blocked) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    '🙉 あなたは音声を聞くことができません',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                );
              }

              final audioUrl = '$baseUrl/api/media/$mediaId?token=${ApiClient.token}';
              return _AudioPlayerTile(
                fileName: '音声 ${e.key + 1}',
                audioUrl: audioUrl,
              );
            })
          ],

          const SizedBox(height: 8),
          PostActions(
            createdAt: createdAt,
            initialLikeCount: (post['likeCount'] as int?) ?? 0,
          ),
        ],
      ),
    ),
  );
}),


            
            
        ],
      ),
      
      

      // 下部メニュー
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //現在選択しているメニュー
        currentIndex: selectedIndex,
        //メニューを押したときの処理
        onTap: (index) {
          setState(() {
            selectedIndex = index;  // 先に更新
          });
          if (index == 0) {
            openSearchPage();  // 検索
           
          } else if (index == 1) {//ホーム画面
          
          } else if (index == 2) {
            //マイページ、遷移はホーム画面が表示される、後ほど変更する
           

          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '検索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
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

// ✅ 音声再生用ウィジェット
class _AudioPlayerTile extends StatefulWidget {
  final String fileName;
  final String audioUrl;

  const _AudioPlayerTile({
    required this.fileName,
    required this.audioUrl,
  });

  @override
  State<_AudioPlayerTile> createState() => _AudioPlayerTileState();
}

class _AudioPlayerTileState extends State<_AudioPlayerTile> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _audioPlayer.setSource(UrlSource(widget.audioUrl));
      await _audioPlayer.resume();
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() => _isPlaying = false);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('音声の再生に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: IconButton(
        icon: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _isPlaying ? Icons.pause_circle : Icons.play_circle,
                color: Colors.blue,
                size: 32,
              ),
        onPressed: _isLoading ? null : _togglePlay,
      ),
      title: Text(
        widget.fileName,
        overflow: TextOverflow.ellipsis,
      ),
      dense: true,
    );
  }
}


