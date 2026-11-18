import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api_client.dart'; // baseUrl・ApiClient・ApiException を使う

// 単独で動かして確認するための入口(履歴画面と同じ作り)。
// 本体アプリ(main.dart)から使うだけなら、この main は使われない。
void main() => runApp(const CommentApp());

class CommentApp extends StatelessWidget {
  const CommentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: CommentTexts.pageTitle,
      theme: ThemeData(scaffoldBackgroundColor: CommentPalette.bg),
      home: const CommentPage(postId: CommentDev.demoPostId),
    );
  }
}

// ============================================================
// 【0】開発用の仮設定(本番では使わない)
// ============================================================
class CommentDev {
  static const int demoPostId = 1; // 単独起動のときに開く投稿のID
  static const int fallbackUserId = 1; // ログインしていないときに使うユーザーID
}

// ============================================================
// 【1】文字：画面に出す文字はここだけ書き換えればOK
// ============================================================

class CommentTexts {
  static const demoText = 'ここには文がありますが、あなたは読めません。';
  static const demoUserName = '正木智也';
  static const comenusiName = 'イッチ';
  static const demoCommentUserName = 'コメント一男';
  static const demoCommentUser = 'ここには音声がありますが、あなたは聞こえません';
  static const pageTitle = 'コメント';
  static const sectionTitle = 'コメント';
  static const reply = '返信';
  static const send = '送信';
  static const inputHint = 'コメント入力';
  static const sampleName = 'アカウント名'; // 仮(サーバーが名前を返すようになったら差し替え)
  static const imageLabel = '画像'; // 投稿画像の仮の文字
  static const emptyText = 'まだコメントがありません';
  static const retry = '再読み込み';
}

// ============================================================
// 【2】色：色はここだけ書き換えればOK(History.dart と同じ値を含む)
//   History.dart の Palette と同じ値のものを、ここにまとめて持つ
// ============================================================
class CommentPalette {
  // --- History.dart の Palette と同じ値 ---
  static const Color line = Colors.black;
  static const Color text = Colors.black;
  static const Color bg = Colors.white;
  static const Color accent = Color(0xFF1A9AD6);
  static const Color icon = Color(0xFF333333);
  // --- コメント画面だけの色 ---
  static const Color heartOn = Color(0xFFE60000); // 押したハート(赤)
  static const Color avatarPoster = Color(0xFF9C27B0); // 投稿者アイコン(仮・紫)
  static const Color avatarOther = Color(0xFF1AAAE6); // コメントしたアカウント(仮・水色)
  static const Color avatarOther2 = Color(0xFFFFC107); // 〃(仮・黄色)
  static const Color avatarMe = Color(0xFF4CAF50); // 自分のアイコン(仮・緑)
  static const Color divider = Color(0xFF1A5C8A); // 投稿とコメントの間の線
  static const Color commentBox = Color(0xFFDDE6F0); // コメント内容の枠
  static const Color sendButton = accent; // 送信ボタン
  static const Color imageMissing = Color(0xFFE0E0E0); // 画像が読めないときの灰色
  static const Color error = Color(0xFFDD0000); // 読み込み失敗の文字
}

class CommentImages {
  static const String _dir = 'assets/images/';

  //コメントする投稿の画像（仮）
  static const String imageImageBase = '${_dir}Yama.png';

  //アイコン画像
  static const String imageAicon = '${_dir}Man.png';
  static const String imageUserAion = '${_dir}MrDOG.png';
  static const String imageNothingMonkey = '${_dir}treeMonkey.png';
}

// ============================================================
// 【3】サイズ：大きさ・すき間はここだけ書き換えればOK(History.dart と同じ値を含む)
// ============================================================
class CommentSizes {
  // --- History.dart の Sizes と同じ値 ---
  static const double columnWidth = 600;
  static const double backRowHeight = 64;
  static const double backButtonWidth = 56;
  static const double backButtonHeight = 40;
  static const double headFont = 13;
  static const double boxBorder = 2;
  static const double actionGap = 20;
  // --- コメント画面だけのサイズ ---
  static const double avatar = 32; // 小さいアイコン(コメント・入力欄)
  static const double posterAvatar = 44; // 投稿者アイコン(履歴画面と同じ)
  static const double imageAspect = 17 / 10; // 投稿画像の横÷縦
  static const double actionIcon = 30; // ハート・コメント・保存
  static const double smallHeart = 22; // 各コメントのハート
  static const double sidePadding = 16;
  static const double sendWidth = 56;
  static const double sendHeight = 34;
}

// ============================================================
// 【4】データ：コメント1件分
//   サーバー(CommentServlet)のJSONから fromJson で作る
// ============================================================
class CommentItem {
  final int id; // コメントID
  final String name; // アカウント名
  final String body; // コメント内容
  final String timeAgo; // 「1時間前」など
  final Color avatarColor; // アイコンの色(仮)
  bool liked; // ハートを押したか
  CommentItem({
    this.id = 0,
    required this.name,
    required this.body,
    required this.timeAgo,
    this.avatarColor = CommentPalette.avatarOther,
    this.liked = false,
  });

  /// CommentServlet のJSON { id, userName, body, timeAgo, liked, ... } から作る
  factory CommentItem.fromJson(Map<String, dynamic> j) {
    return CommentItem(
      id: (j['id'] as num).toInt(),
      name: (j['userName'] ?? CommentTexts.sampleName) as String,
      body: (j['body'] ?? '') as String,
      timeAgo: (j['timeAgo'] ?? '') as String,
      liked: (j['liked'] ?? false) as bool,
    );
  }
}

// ============================================================
// 【4-2】サーバーとの通信
//   ※ api_client.dart を変えないため、コメントの通信はこの中に置いている
// ============================================================

/// 見ている人のID(ログインしていなければ仮のID)
int get _viewerId =>
    (ApiClient.currentUser?['id'] as num?)?.toInt() ??
    CommentDev.fallbackUserId;

/// コメント一覧を取得 (GET /CommentServlet)
Future<List<CommentItem>> fetchComments(int postId) async {
  final uri = Uri.parse('$baseUrl/CommentServlet').replace(
      queryParameters: {'Post_id': '$postId', 'user_id': '$_viewerId'});
  final http.Response res;
  try {
    res = await http.get(uri, headers: {
      if (ApiClient.token != null) 'Authorization': 'Bearer ${ApiClient.token}',
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
        ((data as Map)['error'] ?? 'コメントの取得に失敗しました') as String);
  }
  return (data as List)
      .cast<Map<String, dynamic>>()
      .map(CommentItem.fromJson)
      .toList();
}

/// コメントを送信 (POST /CommentServlet)
Future<void> sendComment(int postId, String body) async {
  final http.Response res;
  try {
    res = await http.post(
      Uri.parse('$baseUrl/CommentServlet'),
      headers: {
        if (ApiClient.token != null)
          'Authorization': 'Bearer ${ApiClient.token}',
      },
      body: {
        'Post_id': '$postId',
        'user_id': '$_viewerId',
        'body': body,
      }, // フォーム形式で送る
    );
  } catch (_) {
    throw ApiException('サーバーに接続できませんでした');
  }
  if (res.statusCode != 201) {
    String message = 'コメントを送信できませんでした';
    try {
      message = (jsonDecode(utf8.decode(res.bodyBytes)) as Map)['error']
              as String? ??
          message;
    } catch (_) {}
    throw ApiException(message);
  }
}

// ============================================================
// コメント画面
//   postId を渡すと、どの投稿のコメントか分かる
// ============================================================
class CommentPage extends StatefulWidget {
  final int postId;
  const CommentPage({super.key, this.postId = CommentDev.demoPostId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _controller = TextEditingController();
  bool _postLiked = true; // 投稿のハート(見本では押した状態)
  bool _postSaved = false; // 投稿の保存

  List<CommentItem> _comments = []; // 読み込んだコメント
  bool _loading = true; // 読み込み中か
  bool _sending = false; // 送信中か
  String? _error; // 読み込みに失敗したときのメッセージ

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------- コメントをサーバーから読み込む ----------
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await fetchComments(widget.postId);
      if (!mounted) return;
      setState(() {
        _comments = rows;
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
        _error = 'コメントを読み込めませんでした';
        _loading = false;
      });
    }
  }

  // ---------- 送信ボタン ----------
  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await sendComment(widget.postId, text);
      _controller.clear();
      await _load(); // 保存できたら読み込み直す
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ---------- 返信ボタン(入力欄に「@名前 」を入れる) ----------
  void _reply(CommentItem c) {
    _controller.text = '@${c.name} ';
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
  }

  // ---------- コメント一覧の部分(読み込み中 / 失敗 / 0件 / 一覧) ----------
  List<Widget> _commentWidgets() {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (_error != null) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Text(_error!,
                  style: const TextStyle(color: CommentPalette.error)),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: _load, child: const Text(CommentTexts.retry)),
            ],
          ),
        ),
      ];
    }
    if (_comments.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text(CommentTexts.emptyText)),
        ),
      ];
    }
    return [
      for (final c in _comments)
        _CommentTile(
          item: c,
          onLike: () => setState(() => c.liked = !c.liked),
          onReply: () => _reply(c),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: CommentSizes.columnWidth),
            child: Column(
              children: [
                // 戻るボタンの行(固定)
                const SizedBox(
                  height: CommentSizes.backRowHeight,
                  child: _BackRow(),
                ),
                // 投稿 + コメント一覧(ここだけスクロール)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: CommentSizes.sidePadding),
                    children: [
                      const _PosterRow(),
                      const SizedBox(height: 12),
                      const _PostImage(),
                      const SizedBox(height: 12),
                      _postActions(),
                      const SizedBox(height: 8),
                      const Divider(
                          color: CommentPalette.divider, thickness: 2),
                      const SizedBox(height: 8),
                      const Text(CommentTexts.sectionTitle),
                      const SizedBox(height: 12),
                      ..._commentWidgets(),
                    ],
                  ),
                ),
                // コメント入力欄(固定)
                _InputRow(controller: _controller, onSend: _send),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ハート・コメント・保存
  Widget _postActions() {
    return Row(
      children: [
        _ActionIcon(
          _postLiked ? Icons.favorite : Icons.favorite_border,
          color: _postLiked ? CommentPalette.heartOn : CommentPalette.icon,
          onTap: () => setState(() => _postLiked = !_postLiked),
        ),
        const SizedBox(width: CommentSizes.actionGap),
        const _ActionIcon(Icons.chat_bubble_outline),
        const SizedBox(width: CommentSizes.actionGap),
        _ActionIcon(
          _postSaved ? Icons.bookmark : Icons.bookmark_border,
          onTap: () => setState(() => _postSaved = !_postSaved),
        ),
      ],
    );
  }
}

// ============================================================
// 画面の部品
// ============================================================

/// 戻るボタンの行(履歴画面と同じ標準の矢印)
class _BackRow extends StatelessWidget {
  const _BackRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CommentPalette.bg,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: const Row(
        children: [
          SizedBox(
            width: CommentSizes.backButtonWidth,
            height: CommentSizes.backButtonHeight,
            child: BackButton(color: CommentPalette.text),
          ),
        ],
      ),
    );
  }
}

/// 投稿者のアイコン + アカウント名
class _PosterRow extends StatelessWidget {
  const _PosterRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _Avatar(
          imagePath: CommentImages.imageAicon, //投稿主のアイコン
          size: CommentSizes.posterAvatar,
        ),
        SizedBox(width: 16),
        Text(CommentTexts.comenusiName, //コメント主のアカウント名
            style: TextStyle(fontSize: CommentSizes.headFont)),
      ],
    );
  }
}

/// 丸いアイコン(画像が読めないときは灰色の丸)
class _Avatar extends StatelessWidget {
  final String imagePath;
  final double size;

  const _Avatar({
    required this.imagePath,
    this.size = CommentSizes.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          width: size,
          height: size,
          color: CommentPalette.imageMissing,
        ),
      ),
    );
  }
}

/// 投稿の画像枠(画像が読めないときは灰色)
class _PostImage extends StatelessWidget {
  const _PostImage();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: CommentSizes.imageAspect,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
              color: CommentPalette.line, width: CommentSizes.boxBorder),
        ),
        child: Image.asset(
          CommentImages.imageImageBase, //投稿主の画像
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) =>
              Container(color: CommentPalette.imageMissing),
        ),
      ),
    );
  }
}

/// ハート・コメント・保存のボタン
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _ActionIcon(this.icon, {this.color = CommentPalette.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Icon(icon, size: CommentSizes.actionIcon, color: color),
    );
  }
}

/// コメント1件
class _CommentTile extends StatelessWidget {
  final CommentItem item;
  final VoidCallback onLike;
  final VoidCallback onReply;
  const _CommentTile({
    required this.item,
    required this.onLike,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Avatar(
            imagePath: CommentImages.imageNothingMonkey, //コメント投稿者のアイコン
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(fontSize: CommentSizes.headFont)),
                const SizedBox(height: 4),
                // コメント内容の枠
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: CommentPalette.commentBox),
                  ),
                  child: Text(item.body),
                ),
                const SizedBox(height: 4),
                // ○時間前 / 返信
                Row(
                  children: [
                    Text(item.timeAgo,
                        style:
                            const TextStyle(fontSize: CommentSizes.headFont)),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: onReply,
                      child: const Text(CommentTexts.reply,
                          style: TextStyle(fontSize: CommentSizes.headFont)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 右端のハート
          InkWell(
            onTap: onLike,
            child: Icon(
              item.liked ? Icons.favorite : Icons.favorite_border,
              size: CommentSizes.smallHeart,
              color: item.liked ? CommentPalette.heartOn : CommentPalette.icon,
            ),
          ),
        ],
      ),
    );
  }
}

/// 下のコメント入力欄 + 送信ボタン
class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputRow({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const _Avatar(
            imagePath: CommentImages
                .imageUserAion, //閲覧している自分のアイコン（コメントを投稿する人のアイコン）
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: CommentTexts.inputHint,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: CommentPalette.line, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: CommentPalette.line, width: 2),
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: CommentSizes.sendWidth,
            height: CommentSizes.sendHeight,
            child: ElevatedButton(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: CommentPalette.sendButton,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text(CommentTexts.send),
            ),
          ),
        ],
      ),
    );
  }
}