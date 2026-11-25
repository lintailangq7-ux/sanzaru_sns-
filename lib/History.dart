import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'api_client.dart'; // サーバーとの通信
import 'post.dart'; // 投稿作成画面(PostPage / PostData)
import 'search.dart' show SearchPage; // 検索画面
import 'pages/home_page.dart' show PostActions; // ホーム画面と同じいいね・コメント部品

void main() => runApp(const MyApp());

// ============================================================
// 【1】文字
// ============================================================
class Texts {
  static const appTitle = '履歴';
  static const pageTitle = '履歴';

  // タブの名前(順番は 閲覧 / いいね / ブックマーク)
  static const tabs = ['閲覧', 'いいね', 'ブックマーク'];
  // タブごとの日時ラベル
  static const dateLabels = ['閲覧日時', 'いいね日時', '保存日時'];

  static const emptyText = '履歴がありません';
  static const retry = '再読み込み';
  static const postNotFound = '投稿が見つかりません';
}

// ============================================================
// 【2】色
// ============================================================
class Palette {
  static const Color text = Colors.black;
  static const Color bg = Colors.white;
  static const Color accent = Color(0xFF1A9AD6);
  static const Color tabInactive = Color(0xFFEEEEEE);
  static const Color tabBorder = Color(0xFFCCCCCC);
  static const Color columnBorder = Color(0xFFDDDDDD);
  static const Color delete = Color(0xFFDD0000);
  static const Color error = Color(0xFFDD0000);
}

// ============================================================
// 【3】サイズ
// ============================================================
class Sizes {
  static const double columnWidth = 600;
  static const double backRowHeight = 64;
  static const double backButtonWidth = 56;
  static const double backButtonHeight = 40;
  static const double tabHeight = 52;
}

// ============================================================
// 【4】データ
//   history = HistoryServlet の1行 { user_id, post_id, viewed_at }
//   post    = fetchPosts() の投稿(見つからなければ null)
// ============================================================
class HistoryItem {
  final int postId;
  final String date;
  final Map<String, dynamic>? post;
  const HistoryItem(this.postId, this.date, this.post);
}

/// "2026-11-11T11:02:34" → "2026-11-11 11:02"
String _formatDate(String? raw) {
  if (raw == null) return '';
  final t = DateTime.tryParse(raw);
  if (t == null) return raw;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
}

class TabIndex {
  static const int viewed = 0;
  static const int liked = 1;
  static const int bookmarked = 2; // 削除ボタンつき

  /// サーバーの HistoryMode (閲覧=1 いいね=2 ブックマーク=3)
  static int modeOf(int tab) => tab + 1;
}

class Dev {
  static const int fallbackUserId = 1;
}

// ============================================================
// 【5】下部メニュー
// ============================================================
class NavIndex {
  static const int home = 0;
  static const int search = 1;
  static const int post = 2;
  static const int myPage = 3;

  static const int current = myPage;
}

const List<BottomNavigationBarItem> bottomNavItems = [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
  BottomNavigationBarItem(icon: Icon(Icons.search), label: '検索'),
  BottomNavigationBarItem(icon: Icon(Icons.add_box), label: '投稿'),
  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
];

// ============================================================
// アプリ本体
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: Texts.appTitle,
      theme: ThemeData(
        scaffoldBackgroundColor: Palette.bg,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: Palette.text,
              displayColor: Palette.text,
            ),
      ),
      home: const HistoryPage(),
    );
  }
}

// ============================================================
// 履歴画面
// ============================================================
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _tab = TabIndex.viewed;
  List<HistoryItem> _items = [];
  bool _loading = true;
  String? _error;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  int get _userId =>
      (ApiClient.currentUser?['id'] as num?)?.toInt() ?? Dev.fallbackUserId;

  // ---------- 履歴と投稿の中身をサーバーから読み込む ----------
  Future<void> _load() async {
    final seq = ++_seq;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await ApiClient.fetchHistory(
        userId: _userId,
        mode: TabIndex.modeOf(_tab),
      );
      // ホーム画面と同じ投稿データを取り、post_id で突き合わせる
      final allPosts = await ApiClient.fetchPosts();
      final byId = <int, Map<String, dynamic>>{};
      for (final p in allPosts) {
        final id = (p['id'] as num?)?.toInt();
        if (id != null) byId[id] = p;
      }

      if (!mounted || seq != _seq) return;
      setState(() {
        _items = rows.map((j) {
          final postId = (j['post_id'] as num).toInt();
          return HistoryItem(
            postId,
            _formatDate(j['viewed_at'] as String?),
            byId[postId],
          );
        }).toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted || seq != _seq) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || seq != _seq) return;
      setState(() {
        _error = '履歴を読み込めませんでした';
        _loading = false;
      });
    }
  }

  void _onSelectTab(int i) {
    if (i == _tab) return;
    setState(() => _tab = i);
    _load();
  }

  Future<void> _openPostPage() async {
    await Navigator.push<PostData>(
      context,
      MaterialPageRoute(builder: (context) => const PostPage(userName: 'YourUserName')),
    );
  }

  void _openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  void _onNavTap(int index) {
    switch (index) {
      case NavIndex.search:
        _openSearchPage();
        break;
      case NavIndex.post:
        _openPostPage();
        break;
      case NavIndex.home:
      case NavIndex.myPage:
        break;
    }
  }

  // ============================================================
  // 投稿1件(home_page.dart の表示と同じレイアウト)
  // ============================================================
  Widget _buildPostCard(HistoryItem item) {
    final post = item.post;
    final dateLabel = '${Texts.dateLabels[_tab]}: ${item.date}';

    // 投稿が取得できなかった場合
    if (post == null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Text('${Texts.postNotFound} (投稿ID: ${item.postId})',
                  style: const TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      );
    }

    final mediaList =
        (post['media'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final images = mediaList.where((m) => m['type'] == 'image').toList();
    final audios = mediaList.where((m) => m['type'] == 'audio').toList();

    final userName = post['authorName']?.toString() ?? '不明';
    final content =
        post['content']?.toString() ?? post['text']?.toString() ?? '';
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
        (post['createdAt'] as int?) ?? 0);
    final textHidden = post['textHidden'] == true;

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

            // 履歴の日時(閲覧 / いいね / 保存)
            const SizedBox(height: 6),
            Text(dateLabel,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),

            // 本文
            if (textHidden) ...[
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '🙊 あなたは本文を見ることができません',
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ] else if (content.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(content),
            ],

            // 画像
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
                        style: TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                      ),
                    );
                  }

                  final imageUrl =
                      '$baseUrl/api/media/$mediaId?token=${ApiClient.token}';
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
                          width: 100,
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 100,
                          height: 100,
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ],

            // 音声
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
                      style: TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  );
                }

                final audioUrl =
                    '$baseUrl/api/media/$mediaId?token=${ApiClient.token}';
                return HistoryAudioTile(
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

            // ブックマークのタブだけ削除ボタン(見かけだけ)
            if (_tab == TabIndex.bookmarked)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete_outline,
                      color: Palette.delete),
                  label: const Text('削除',
                      style: TextStyle(color: Palette.delete)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- 一覧の部分 ----------
  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Palette.error)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text(Texts.retry)),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text(Texts.emptyText));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _items.length,
      itemBuilder: (context, i) => _buildPostCard(_items[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Sizes.columnWidth),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Palette.columnBorder),
                  right: BorderSide(color: Palette.columnBorder),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: Sizes.backRowHeight,
                    child: _BackRow(),
                  ),
                  SizedBox(
                    height: Sizes.tabHeight,
                    child: _TabRow(
                      selected: _tab,
                      onSelect: _onSelectTab,
                    ),
                  ),
                  Expanded(child: _buildList()),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: NavIndex.current,
        onTap: _onNavTap,
        items: bottomNavItems,
      ),
    );
  }
}

// ============================================================
// 画面の部品
// ============================================================
class _BackRow extends StatelessWidget {
  const _BackRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.bg,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: const Row(
        children: [
          SizedBox(
            width: Sizes.backButtonWidth,
            height: Sizes.backButtonHeight,
            child: BackButton(color: Palette.text),
          ),
          SizedBox(width: 16),
          Text(
            Texts.pageTitle,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TabRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _TabRow({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Palette.bg,
        border: Border(bottom: BorderSide(color: Palette.tabBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < Texts.tabs.length; i++)
            Expanded(
              child: _TabButton(
                label: Texts.tabs[i],
                active: i == selected,
                onTap: () => onSelect(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: active ? Palette.bg : Palette.tabInactive,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(label, style: const TextStyle(fontSize: 14)),
            ),
            if (active)
              Positioned(
                bottom: 6,
                child: Container(
                  width: 56,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Palette.accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 音声再生用ウィジェット(home_page.dart の _AudioPlayerTile と同じ見た目)
// ============================================================
class HistoryAudioTile extends StatefulWidget {
  final String fileName;
  final String audioUrl;

  const HistoryAudioTile({
    super.key,
    required this.fileName,
    required this.audioUrl,
  });

  @override
  State<HistoryAudioTile> createState() => _HistoryAudioTileState();
}

class _HistoryAudioTileState extends State<HistoryAudioTile> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _audioPlayer.setSource(UrlSource(widget.audioUrl));
      await _audioPlayer.resume();
      if (!mounted) return;
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('音声の再生に失敗しました: $e')),
      );
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