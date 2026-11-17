import 'package:flutter/material.dart';
import 'api_client.dart'; // サーバーとの通信
import 'post.dart'; // 投稿作成画面(PostPage / PostData)
import 'search.dart' show SearchPage; // 検索画面

void main() => runApp(const MyApp());

// ============================================================
// 【1】文字：画面に出す文字はここだけ書き換えればOK
// ============================================================
class Texts {
  static const appTitle = '履歴';
  static const pageTitle = '履歴';

  // タブの名前(3つ。順番は 閲覧 / いいね / ブックマーク)
  static const tabs = ['閲覧', 'いいね', 'ブックマーク'];

  // 制限されているときの表示
  static const noText = 'ここには文がありますが、あなたは読めません';
  static const noImage = 'ここには画像がありますが、あなたは見えません';
  static const noAudio = 'ここには音声がありますが、あなたは聞こえません';

  // 仮の本文・画像の中の文字
  static const sampleBody = 'ここに投稿の文章が入ります。\n改行もできます。';
  static const imageLabel = '画像';

  // 読み込みの表示
  static const emptyText = '履歴がありません';
  static const retry = '再読み込み';
  static const sampleName = 'アカウント名'; // 仮(サーバーが投稿者名を返すようになったら差し替え)
}

// ============================================================
// 【2】色：色はここだけ書き換えればOK
// ============================================================
class Palette {
  static const Color line = Colors.black; // 投稿の区切り線
  static const Color text = Colors.black; // 文字
  static const Color bg = Colors.white; // 背景
  static const Color accent = Color(0xFF1A9AD6); // アカウントID・タブ下線の色
  static const Color tabInactive = Color(0xFFEEEEEE); // 選ばれていないタブ
  static const Color tabBorder = Color(0xFFCCCCCC); // タブの下線
  static const Color columnBorder = Color(0xFFDDDDDD); // 列の左右の線
  static const Color avatar = Color(0xFFFF0000); // アイコンの色(仮)
  static const Color box = Color(0xFF112233); // 画像・音声・注意書きの枠
  static const Color icon = Color(0xFF333333); // いいね・コメント・保存
  static const Color delete = Color(0xFFDD0000); // 削除ボタン
  static const Color error = Color(0xFFDD0000); // 読み込み失敗の文字
}

// ============================================================
// 【3】サイズ：大きさ・すき間はここだけ書き換えればOK
// ============================================================
class Sizes {
  static const double columnWidth = 600; // 投稿の列の最大幅(画面が狭いときは自動で縮む)

  // 上に張り付く部分
  static const double backRowHeight = 64; // 戻るボタンの行
  static const double backButtonWidth = 56;
  static const double backButtonHeight = 40;
  static const double tabHeight = 52; // タブの行

  // 投稿1件
  static const double postPadding = 12;
  static const double avatar = 44;
  static const double headFont = 13;
  static const double imageAspect = 21 / 10; // 画像の横÷縦
  static const double imageRadius = 28;
  static const double boxRadius = 24; // 音声・注意書きの角の丸み
  static const double boxBorder = 2;
  static const double actionIcon = 26;
  static const double actionGap = 20;
}

// ============================================================
// 【4】データ：サーバーから読み込んだ履歴1件分
//   hidden = この投稿で「見えなくする」もの(今は全部見える。制限を付けるときに使う)
//     none=全部見える / text=文が読めない / audio=音声が聞こえない / image=画像が見えない
// ============================================================
enum Hidden { none, text, audio, image }

class PostItem {
  final int postId; // 投稿ID
  final String name; // アカウント名
  final String id; // アカウントID(今は「投稿ID: ○」)
  final String date; // 日時(閲覧した日時 / いいねした日時 / 保存した日時)
  final Hidden hidden;
  const PostItem(this.postId, this.name, this.id, this.date, this.hidden);

  /// HistoryServlet のJSON { user_id, post_id, viewed_at } から作る
  factory PostItem.fromJson(Map<String, dynamic> j) {
    final postId = (j['post_id'] as num).toInt();
    return PostItem(
      postId,
      Texts.sampleName,
      '投稿ID: $postId',
      _formatDate(j['viewed_at'] as String?),
      Hidden.none,
    );
  }
}

/// "2026-11-11T11:02:34" → "2026-11-11 11:02"
String _formatDate(String? raw) {
  if (raw == null) return '';
  final t = DateTime.tryParse(raw);
  if (t == null) return raw;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}';
}

// どのタブで何を見せるか
class TabIndex {
  static const int viewed = 0; // 閲覧
  static const int liked = 1; // いいね
  static const int bookmarked = 2; // ブックマーク(削除ボタンつき)

  /// サーバーの HistoryMode (閲覧=1 いいね=2 ブックマーク=3)
  static int modeOf(int tab) => tab + 1;
}

// ★ 仮：ログインしていないときに使うユーザーID(動作確認用)
class Dev {
  static const int fallbackUserId = 1;
}

// ============================================================
// 【5】下部メニュー(検索画面と同じもの)
//   順番を変えたら _onNavTap の番号も合わせる
// ============================================================
class NavIndex {
  static const int home = 0;
  static const int search = 1;
  static const int post = 2;
  static const int myPage = 3;

  static const int current = myPage; // この画面で選ばれている項目
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
  int _tab = TabIndex.viewed; // 今選ばれているタブ
  List<PostItem> _items = []; // 読み込んだ履歴
  bool _loading = true; // 読み込み中か
  String? _error; // 読み込みに失敗したときのメッセージ
  int _seq = 0; // タブを素早く切り替えたとき、古い結果を捨てるための番号

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ログイン中のユーザーID(ログインしていなければ仮のID)
  int get _userId =>
      (ApiClient.currentUser?['id'] as num?)?.toInt() ?? Dev.fallbackUserId;

  // ---------- 今のタブの履歴をサーバーから読み込む ----------
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
      if (!mounted || seq != _seq) return; // 別のタブに切り替わっていたら捨てる
      setState(() {
        _items = rows.map(PostItem.fromJson).toList();
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

  // ---------- タブを切り替えたとき ----------
  void _onSelectTab(int i) {
    if (i == _tab) return;
    setState(() => _tab = i);
    _load();
  }

  // ---------- 投稿作成画面へ移動 ----------
  Future<void> _openPostPage() async {
    await Navigator.push<PostData>(
      context,
      MaterialPageRoute(builder: (context) => const PostPage(userName: 'YourUserName')),
    );
  }

  // ---------- 検索画面へ移動 ----------
  void _openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  // ---------- 下部メニューを押したとき ----------
  void _onNavTap(int index) {
    switch (index) {
      case NavIndex.search:
        _openSearchPage();
        break;
      case NavIndex.post:
        _openPostPage();
        break;
      // 他の画面ができたら、ここに移動の処理を足す
      case NavIndex.home:
      case NavIndex.myPage:
        break;
    }
  }

  // ---------- 一覧の部分(読み込み中 / 失敗 / 0件 / 一覧) ----------
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
    final showDelete = _tab == TabIndex.bookmarked;
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, i) =>
          _PostCard(item: _items[i], showDelete: showDelete),
    );
  }

  // ---------- 画面全体の組み立て ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // 投稿の列を、画面の上側・中央に置く
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
                  // 戻るボタンの行(固定。投稿だけがスクロールする)
                  const SizedBox(
                    height: Sizes.backRowHeight,
                    child: _BackRow(),
                  ),
                  // タブ(固定)
                  SizedBox(
                    height: Sizes.tabHeight,
                    child: _TabRow(
                      selected: _tab,
                      onSelect: _onSelectTab,
                    ),
                  ),
                  // 投稿の一覧(ここだけスクロール)
                  Expanded(child: _buildList()),
                ],
              ),
            ),
          ),
        ),
      ),

      // 下部メニュー
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

/// 戻るボタン + 「履歴」の見出し
class _BackRow extends StatelessWidget {
  const _BackRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.bg,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          // 戻るボタン：投稿作成画面・検索画面と同じ標準の矢印。
          // 押すと前の画面に戻る(戻る先がなければ何もしない)
          const SizedBox(
            width: Sizes.backButtonWidth,
            height: Sizes.backButtonHeight,
            child: BackButton(color: Palette.text),
          ),
          const SizedBox(width: 16),
          const Text(
            Texts.pageTitle,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// タブの行(閲覧 / いいね / ブックマーク)
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

/// タブ1つ(選ばれているときは下に青い線)
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

/// 投稿1件
class _PostCard extends StatelessWidget {
  final PostItem item;
  final bool showDelete; // ブックマークのタブだけ削除ボタンを出す
  const _PostCard({required this.item, required this.showDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.postPadding),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Palette.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アイコン(仮)
          Container(
            width: Sizes.avatar,
            height: Sizes.avatar,
            decoration: BoxDecoration(
              color: Palette.avatar,
              shape: BoxShape.circle,
              border: Border.all(color: Palette.line),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                const SizedBox(height: 4),
                _body(),
                const SizedBox(height: 14),
                _actions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // アカウント名・ID・日時
  Widget _header() {
    return Wrap(
      spacing: 16,
      children: [
        Text(item.name, style: const TextStyle(fontSize: Sizes.headFont)),
        Text(
          item.id,
          style: const TextStyle(fontSize: Sizes.headFont, color: Palette.accent),
        ),
        Text(item.date, style: const TextStyle(fontSize: Sizes.headFont)),
      ],
    );
  }

  // 文 → 画像 → 音声(制限されているものは注意書きに差し替える)
  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        item.hidden == Hidden.text
            ? const _NoticeBox(Texts.noText)
            : const Text(Texts.sampleBody),
        const SizedBox(height: 12),
        item.hidden == Hidden.image
            ? const _NoticeBox(Texts.noImage)
            : const _PostImage(),
        const SizedBox(height: 12),
        item.hidden == Hidden.audio
            ? const _NoticeBox(Texts.noAudio)
            : const _AudioBar(),
      ],
    );
  }

  // いいね・コメント・保存(+ 削除)
  Widget _actions() {
    return Row(
      children: [
        const _ActionIcon(Icons.favorite_border),
        const SizedBox(width: Sizes.actionGap),
        const _ActionIcon(Icons.chat_bubble_outline),
        const SizedBox(width: Sizes.actionGap),
        const _ActionIcon(Icons.bookmark_border),
        if (showDelete) ...[
          const SizedBox(width: Sizes.actionGap),
          const _ActionIcon(Icons.delete_outline, color: Palette.delete),
        ],
      ],
    );
  }
}

/// いいね・コメント・保存・削除のボタン(見かけだけ)
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _ActionIcon(this.icon, {this.color = Palette.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Icon(icon, size: Sizes.actionIcon, color: color),
    );
  }
}

/// 画像の枠(本物の画像にするときは、中の Text を Image に差し替える)
class _PostImage extends StatelessWidget {
  const _PostImage();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: Sizes.imageAspect,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Palette.box, width: Sizes.boxBorder),
          borderRadius: BorderRadius.circular(Sizes.imageRadius),
        ),
        // 例: child: ClipRRect(..., child: Image.asset('assets/images/xxx.png', fit: BoxFit.cover))
        child: const Text(Texts.imageLabel, style: TextStyle(fontSize: 28)),
      ),
    );
  }
}

/// 音声バー(見かけだけ。本物にするときは audioplayers などに差し替える)
class _AudioBar extends StatelessWidget {
  const _AudioBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Palette.box, width: Sizes.boxBorder),
        borderRadius: BorderRadius.circular(Sizes.boxRadius),
      ),
      child: const Row(
        children: [
          Icon(Icons.play_arrow, size: 24),
          SizedBox(width: 8),
          Expanded(child: LinearProgressIndicator(value: 0)),
          SizedBox(width: 8),
          Text('0:00', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

/// 制限されているときの注意書き
class _NoticeBox extends StatelessWidget {
  final String message;
  const _NoticeBox(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Palette.box, width: Sizes.boxBorder),
        borderRadius: BorderRadius.circular(Sizes.boxRadius),
      ),
      child: Text(message),
    );
  }
}