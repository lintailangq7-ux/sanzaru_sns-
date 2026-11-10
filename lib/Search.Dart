import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// ============================================================
// 【書き換えポイント1】画面に出す文字・データはここにまとめる
// ============================================================
const String placeholderText = 'テキスト検索';
const String imageSearchLabel1 = 'ここで';
const String imageSearchLabel2 = '画像検索';
const String voiceSearchLabel1 = 'マイクで';
const String voiceSearchLabel2 = '音声検索';
const String candidateTitle = '検索画像候補';

// 入力中に出る履歴(type: text=文字 / voice=音声 / image=画像)
// { type, 左の小さい文字(音声の時間など), 表示する文字 }
const List<List<String>> history = [
  ['text', '', 'イタリアンレストラン'],
  ['voice', '1:20', '音声'],
  ['image', '', '画像'],
];

// 検索画像候補(今は仮の色。後で画像パスに差し替える)
// 画像にするときは下の Candidate ウィジェットのコメント部分を有効にする
const List<Color> candidates = [
  Color(0xFF5B4A8A), Color(0xFF5A9AD6), Color(0xFF4A4A7A),
  Color(0xFF8A5A7A), Color(0xFF2F3B6B), Color(0xFF6AB0E0),
  Color(0xFF7A6A4A), Color(0xFF4A7A6A), Color(0xFFA06A5A),
];

// ============================================================
// 【書き換えポイント2】サイズ・色はここだけ変えればOK
// ============================================================
const double toolbarWidth = 180; // ツールバーの幅
const Color lineColor = Colors.black; // 枠線の色
const Color textColor = Colors.black;
const Color bgColor = Colors.white;
const double gap = 16;

// 画像検索ボタンのアイコン画像(assets に置いて pubspec.yaml に登録)
const String micImagePath = 'assets/images/マイク.png';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '検索画面',
      theme: ThemeData(
        scaffoldBackgroundColor: bgColor,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: textColor,
              displayColor: textColor,
            ),
      ),
      home: const SearchPage(),
    );
  }
}

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
              // ---------- メイン領域 ----------
              Positioned.fill(
                left: toolbarWidth + 24,
                right: gap,
                child: _buildMain(),
              ),
              // ---------- ツールバー(仮)：スクロールしても動かない ----------
              Positioned(
                top: 8,
                left: 8,
                bottom: 8,
                width: toolbarWidth,
                child: _buildToolbar(),
              ),
              // ---------- 履歴リスト(検索バーの下に重ねる) ----------
              if (_historyOpen && _hasText)
                Positioned(
                  top: 12 + 44, // 検索バーの下
                  left: toolbarWidth + 24 + 56 + gap + 48,
                  right: gap + 48,
                  child: _buildHistory(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- ツールバー(仮) ----------
  Widget _buildToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: lineColor),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: const _VerticalText('ツールバー', fontSize: 28),
    );
  }

  // ---------- メイン(スクロールで流れる部分) ----------
  Widget _buildMain() {
    return CustomScrollView(
      slivers: [
        // 検索バー：スクロールしても上に張り付く
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(height: 68, child: _buildSearchRow()),
        ),
        // 画像検索 / 音声検索ボタン(見かけだけ)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _buildModeRow(),
          ),
        ),
        // 検索画像候補
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 24, 0, 8),
            child: Text(candidateTitle,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 140 / 150,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) => Candidate(color: candidates[i], index: i),
              childCount: candidates.length,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- 検索バー ----------
  Widget _buildSearchRow() {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // 戻るボタン(見かけだけ)
          SizedBox(
            width: 56,
            height: 40,
            child: InkWell(
              onTap: () {},
              child: CustomPaint(painter: _BackArrowPainter()),
            ),
          ),
          const SizedBox(width: gap),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: lineColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const _SearchIcon(size: 36),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: placeholderText,
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
                        width: 44,
                        height: 36,
                        decoration: BoxDecoration(
                          border: Border.all(color: lineColor),
                          color: bgColor,
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
            ),
          ),
        ],
      ),
    );
  }

  // ---------- 入力中の履歴リスト(見かけだけ：選んでも何も起きない) ----------
  Widget _buildHistory() {
    return Material(
      color: bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final h in history)
            Container(
              height: 34,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: lineColor)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Row(
                      children: [
                        if (h[0] == 'text')
                          const _SearchIcon(size: 26)
                        else if (h[0] == 'voice') ...[
                          const _MicIcon(width: 18, height: 24, stroke: 9),
                          const SizedBox(width: 4),
                          Text(h[1], style: const TextStyle(fontSize: 11)),
                        ] else
                          Container(width: 28, height: 32, decoration: _thumbDecoration()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(h[2],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------- 画像検索 / 音声検索ボタン(見かけだけ) ----------
  Widget _buildModeRow() {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            icon: Image.asset(
              micImagePath,
              width: 86,
              height: 100,
              // 画像がまだ無いときは仮のグラデーションを表示
              errorBuilder: (_, __, ___) =>
                  Container(width: 86, height: 100, decoration: _thumbDecoration()),
            ),
            label1: imageSearchLabel1,
            label2: imageSearchLabel2,
          ),
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: _ModeButton(
            icon: _MicIcon(width: 80, height: 100, stroke: 7),
            label1: voiceSearchLabel1,
            label2: voiceSearchLabel2,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 部品
// ============================================================

BoxDecoration _thumbDecoration() => const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2F2F66), Color(0xFF8A5A7A), Color(0xFF3A4A6A)],
        stops: [0, 0.55, 1],
      ),
    );

/// 画像検索 / 音声検索ボタン
class _ModeButton extends StatelessWidget {
  final Widget icon;
  final String label1;
  final String label2;
  const _ModeButton(
      {required this.icon, required this.label1, required this.label2});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {}, // 見かけだけ
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: lineColor),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            SizedBox(height: 100, child: Center(child: icon)),
            Text(
              '$label1\n$label2',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }
}

/// 検索画像候補1枚
class Candidate extends StatelessWidget {
  final Color color;
  final int index;
  const Candidate({super.key, required this.color, required this.index});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      // 画像に差し替えるとき：下の Container をやめて、Image.asset の行を有効にする
      // child: Image.asset(candidatePaths[index], fit: BoxFit.cover),
      child: Container(color: color),
    );
  }
}

/// 縦書きテキスト(ツールバー用)
class _VerticalText extends StatelessWidget {
  final String text;
  final double fontSize;
  const _VerticalText(this.text, {required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final ch in text.characters)
          Padding(
            padding: EdgeInsets.symmetric(vertical: fontSize * 0.2),
            child: Text(ch, style: TextStyle(fontSize: fontSize)),
          ),
      ],
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate old) =>
      old.child != child || old.height != height;
}

// ---------- アイコン(SVGの代わりにCustomPaint) ----------

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
    canvas.drawLine(Offset(24 * s, 24 * s), Offset(36 * s, 36 * s),
        p..strokeWidth = 4 * s);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _MicIcon extends StatelessWidget {
  final double width;
  final double height;
  final double stroke;
  const _MicIcon(
      {required this.width, required this.height, required this.stroke});

  @override
  Widget build(BuildContext context) => CustomPaint(
      size: Size(width, height), painter: _MicPainter(stroke: stroke));
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
          const Rect.fromLTWH(27, 4, 26, 52), const Radius.circular(13)),
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
      ..arcToPoint(const Offset(70, 42),
          radius: const Radius.circular(30), clockwise: false)
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

class _BackArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 56, size.height / 40);
    final p = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(52, 20)
      ..lineTo(8, 20)
      ..moveTo(22, 5)
      ..lineTo(6, 20)
      ..lineTo(22, 35);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

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