import 'package:flutter/material.dart';
import 'post.dart';
import 'search_result.dart';

void main() => runApp(const MyApp());

// ============================================================
// 【1】文字：画面に出す文字はここだけ書き換えればOK
// ============================================================
class Texts {
  static const placeholder = 'テキスト検索';
  static const imageSearch1 = 'ここで';
  static const imageSearch2 = '画像検索';
  static const voiceSearch1 = 'マイクで';
  static const voiceSearch2 = '音声検索';
  static const candidateTitle = '検索画像候補';
  static const appTitle = '検索画面';
}

// ============================================================
// 【2】色：色はここだけ書き換えればOK
// ============================================================
class Palette {
  static const Color line = Colors.black; // 枠線
  static const Color text = Colors.black; // 文字
  static const Color bg = Colors.white; // 背景

  // 画像検索ボタンの四角形の色
  static const Color imageSearchBox = Color(0xFFE57373);

  // 履歴の「画像」行の四角形の色
  static const Color historyImageBox = Color(0xFF64B5F6);

  // 検索画像候補の四角形の色(9個。数を変えたら中身も増減する)
  static const List<Color> candidates = [
    Color(0xFFE57373), // 赤
    Color(0xFFFFB74D), // オレンジ
    Color(0xFFFFF176), // 黄
    Color(0xFF81C784), // 緑
    Color(0xFF4DB6AC), // 青緑
    Color(0xFF64B5F6), // 青
    Color(0xFF9575CD), // 紫
    Color(0xFFF06292), // ピンク
    Color(0xFFA1887F), // 茶
  ];
}

// ============================================================
// 【3】サイズ：大きさ・すき間はここだけ書き換えればOK
// ============================================================
class Sizes {
  // 全体
  static const double gap = 16; // 横のすき間
  static const double mainLeft = gap; // メイン領域の左位置(ツールバー削除後)

  // 検索バー
  static const double searchBarHeight = 68;
  static const double backButtonWidth = 56;
  static const double backButtonHeight = 40;
  static const double searchIcon = 36;
  static const double dropdownWidth = 44;
  static const double dropdownHeight = 36;

  // 履歴リスト
  static const double historyTop = 12 + 44; // 検索バーの下
  static const double historyLeft = mainLeft + backButtonWidth + gap + 48;
  static const double historyRight = gap + 48;
  static const double historyRowHeight = 34;
  static const double historyImageWidth = 28; // 「画像」行の四角形
  static const double historyImageHeight = 32;

  // 画像検索 / 音声検索ボタン
  static const double modeIconWidth = 86; // 画像検索ボタンの四角形
  static const double modeIconHeight = 100;
  static const double modeButtonRadius = 32;

  // 検索画像候補
  static const int candidateColumns = 3; // 横に並べる数
  static const double candidateSpacing = 12;
  static const double candidateAspect = 140 / 150; // 横÷縦
  static const double candidateRadius = 2;
}

// ============================================================
// 【4】データ：履歴・下部メニューの中身はここで書き換える
// ============================================================
enum HistoryKind { text, voice, image }

class HistoryItem {
  final HistoryKind kind;
  final String sub; // 左の小さい文字(音声の時間など)
  final String label; // 表示する文字
  const HistoryItem(this.kind, this.sub, this.label);
}

const List<HistoryItem> historyItems = [
  HistoryItem(HistoryKind.text, '', 'イタリアンレストラン'),
  HistoryItem(HistoryKind.voice, '1:20', '音声'),
  HistoryItem(HistoryKind.image, '', '画像'),
];

// 下部メニュー(ホーム画面と同じ並び。順番を変えたら _onNavTap の番号も合わせる)
class NavIndex {
  static const int home = 0;
  static const int search = 1;
  static const int post = 2;
  static const int myPage = 3;

  static const int current = search; // この画面で選ばれている項目
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
      home: const SearchPage(),
    );
  }
}

// ============================================================
// 検索画面
// ============================================================
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _historyOpen = false;

  bool get _hasText => _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // 入力したら▼と履歴を出す／空に戻したら隠す(見かけだけの動き)
    _controller.addListener(() {
      setState(() => _historyOpen = _hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------- テキスト検索を実行 ----------
  void _search() {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;
    _focusNode.unfocus();
    setState(() => _historyOpen = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultPage(keyword: keyword),
      ),
    );
  }

  // ---------- 投稿作成画面へ移動 ----------
  Future<void> _openPostPage() async {
    await Navigator.push<PostData>(
      context,
      MaterialPageRoute(builder: (context) => PostPage(userName: 'exampleUser')),
    );
  }

  // ---------- 下部メニューを押したとき ----------
  void _onNavTap(int index) {
    switch (index) {
      case NavIndex.post:
        _openPostPage();
        break;
      // 他の画面ができたら、ここに移動の処理を足す
      case NavIndex.home:
      case NavIndex.search:
      case NavIndex.myPage:
        break;
    }
  }

  // ---------- 画面全体の組み立て ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          // 検索欄の外をタップしたら履歴を閉じる
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_historyOpen) setState(() => _historyOpen = false);
            _focusNode.unfocus();
          },
          child: Stack(
            children: [
              // メイン領域
              Positioned.fill(
                left: Sizes.mainLeft,
                right: Sizes.gap,
                child: _buildMain(),
              ),
              // 履歴リスト(検索バーの下に重ねる)
              if (_historyOpen && _hasText)
                const Positioned(
                  top: Sizes.historyTop,
                  left: Sizes.historyLeft,
                  right: Sizes.historyRight,
                  child: _HistoryList(items: historyItems),
                ),
            ],
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

  // ---------- メイン(スクロールで流れる部分) ----------
  Widget _buildMain() {
    return CustomScrollView(
      slivers: [
        // 検索バー：スクロールしても上に張り付く
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            height: Sizes.searchBarHeight,
            child: _buildSearchRow(),
          ),
        ),
        // 画像検索 / 音声検索ボタン
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: _ModeRow(),
          ),
        ),
        // 「検索画像候補」の見出し
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 24, 0, 8),
            child: Text(
              Texts.candidateTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // 検索画像候補(色付き四角形)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Sizes.candidateColumns,
              mainAxisSpacing: Sizes.candidateSpacing,
              crossAxisSpacing: Sizes.candidateSpacing,
              childAspectRatio: Sizes.candidateAspect,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => ColorBox(
                color: Palette.candidates[i],
                radius: Sizes.candidateRadius,
              ),
              childCount: Palette.candidates.length,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- 検索バー(戻る + 検索欄) ----------
  Widget _buildSearchRow() {
    return Container(
      color: Palette.bg,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // 戻るボタン：投稿作成画面(post.dart の AppBar)と同じ標準の矢印。
          // 押すと前の画面に戻る(戻る先がなければ何もしない)
          const SizedBox(
            width: Sizes.backButtonWidth,
            height: Sizes.backButtonHeight,
            child: BackButton(color: Palette.text),
          ),
          const SizedBox(width: Sizes.gap),
          Expanded(child: _buildSearchField()),
        ],
      ),
    );
  }

  // ---------- 検索欄(虫めがね + 入力 + ▼) ----------
  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Palette.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // 虫めがね：押すとテキスト検索を実行
          GestureDetector(
            onTap: _search,
            child: const _SearchIcon(size: Sizes.searchIcon),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search, // キーボードの「検索」キー
              onSubmitted: (_) => _search(), // Enter / 検索キーで実行
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: Texts.placeholder,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          // ▼ボタン：文字が入ると出る。押すと履歴を開閉
          if (_hasText)
            InkWell(
              onTap: () => setState(() => _historyOpen = !_historyOpen),
              child: Container(
                width: Sizes.dropdownWidth,
                height: Sizes.dropdownHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Palette.line),
                  color: Palette.bg,
                ),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(36, 30),
                  painter: _TrianglePainter(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// 画面の部品
// ============================================================

/// 入力中の履歴リスト(見かけだけ：選んでも何も起きない)
class _HistoryList extends StatelessWidget {
  final List<HistoryItem> items;
  const _HistoryList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Palette.bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [for (final item in items) _HistoryRow(item: item)],
      ),
    );
  }
}

/// 履歴の1行
class _HistoryRow extends StatelessWidget {
  final HistoryItem item;
  const _HistoryRow({required this.item});

  // 行の左側のアイコン部分
  Widget _leading() {
    switch (item.kind) {
      case HistoryKind.text:
        return const _SearchIcon(size: 26);
      case HistoryKind.voice:
        return Row(
          children: [
            const _MicIcon(width: 18, height: 24, stroke: 9),
            const SizedBox(width: 4),
            Text(item.sub, style: const TextStyle(fontSize: 11)),
          ],
        );
      case HistoryKind.image:
        return const ColorBox(
          width: Sizes.historyImageWidth,
          height: Sizes.historyImageHeight,
          color: Palette.historyImageBox,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Sizes.historyRowHeight,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Palette.line)),
      ),
      child: Row(
        children: [
          SizedBox(width: 44, child: _leading()),
          const SizedBox(width: 10),
          Text(
            item.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// 画像検索 / 音声検索ボタンの行
class _ModeRow extends StatelessWidget {
  const _ModeRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ModeButton(
            icon: ColorBox(
              width: Sizes.modeIconWidth,
              height: Sizes.modeIconHeight,
              color: Palette.imageSearchBox,
            ),
            label1: Texts.imageSearch1,
            label2: Texts.imageSearch2,
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          child: _ModeButton(
            icon: _MicIcon(width: 80, height: 100, stroke: 7),
            label1: Texts.voiceSearch1,
            label2: Texts.voiceSearch2,
          ),
        ),
      ],
    );
  }
}

/// 画像検索 / 音声検索ボタン1つ(見かけだけ)
class _ModeButton extends StatelessWidget {
  final Widget icon;
  final String label1;
  final String label2;
  const _ModeButton({
    required this.icon,
    required this.label1,
    required this.label2,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(Sizes.modeButtonRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Palette.bg,
          border: Border.all(color: Palette.line),
          borderRadius: BorderRadius.circular(Sizes.modeButtonRadius),
        ),
        child: Column(
          children: [
            SizedBox(height: Sizes.modeIconHeight, child: Center(child: icon)),
            Text(
              '$label1\n$label2',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 色付きの四角形(画像の代わり)
/// 本物の画像にするときは、build の中身を
///   Image.asset('assets/images/xxx.png', fit: BoxFit.cover)
/// に差し替えるだけでよい(使っている場所はすべてこの部品を通る)
class ColorBox extends StatelessWidget {
  final Color color;
  final double? width; // 省略すると、置かれた場所いっぱいに広がる
  final double? height;
  final double radius;
  const ColorBox({
    super.key,
    required this.color,
    this.width,
    this.height,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// スクロールしても上に張り付くヘッダー
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;
  _StickyHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate old) =>
      old.child != child || old.height != height;
}

// ============================================================
// アイコン(SVGの代わりにCustomPaint)
// ============================================================

/// 虫めがね
class _SearchIcon extends StatelessWidget {
  final double size;
  const _SearchIcon({required this.size});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _SearchPainter());
}

class _SearchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40; // viewBox 40x40
    final p = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(16 * s, 16 * s), 11 * s, p..strokeWidth = 3.5 * s);
    canvas.drawLine(
        Offset(24 * s, 24 * s), Offset(36 * s, 36 * s), p..strokeWidth = 4 * s);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// マイク
class _MicIcon extends StatelessWidget {
  final double width;
  final double height;
  final double stroke;
  const _MicIcon({
    required this.width,
    required this.height,
    required this.stroke,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(width, height),
        painter: _MicPainter(stroke: stroke),
      );
}

class _MicPainter extends CustomPainter {
  final double stroke;
  _MicPainter({required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 80; // viewBox 80x100
    final sy = size.height / 100;
    canvas.save();
    canvas.scale(sx, sy);

    // マイク本体
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(27, 4, 26, 52),
        const Radius.circular(13),
      ),
      Paint()..color = Colors.black,
    );

    // 受け口・スタンド
    final line = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(10, 42)
      ..arcToPoint(
        const Offset(70, 42),
        radius: const Radius.circular(30),
        clockwise: false,
      )
      ..moveTo(40, 72)
      ..lineTo(40, 90)
      ..moveTo(22, 92)
      ..lineTo(58, 92);
    canvas.drawPath(path, line);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MicPainter old) => old.stroke != stroke;
}

/// ▼
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 34);
    final path = Path()
      ..moveTo(2, 2)
      ..lineTo(38, 2)
      ..lineTo(20, 32)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}