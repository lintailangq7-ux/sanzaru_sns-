
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'Search.dart';
import 'pages/home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const green = Color(0xFF4CA632);

  final ImagePicker picker = ImagePicker();

  Uint8List? postImageBytes;

  // 画像を選択する
  Future<void> selectImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    if (!mounted) return;

    setState(() {
      postImageBytes = bytes;
    });
  }

  // プロフィール画像
  Widget avatar(double size) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: green,
      shape: BoxShape.circle,
    ),
  );

  // アイコンボタン
  Widget actionIcon(IconData icon, Color color, String name) =>
      IconButton(
        onPressed: () => debugPrint(name),
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.only(right: 10),
        icon: Icon(icon, color: color),
      );

  // 下部メニュー
  Widget bottomIcon(IconData icon, double size, String name) =>
      IconButton(
        onPressed: () => debugPrint(name),
        icon: Icon(icon, size: size),
      );

  // 投稿画像
  Widget postImage(BuildContext context) => Center(
    child: Container(
      width: MediaQuery.sizeOf(context).width * 0.45,
      height: 138,
      color: postImageBytes == null ? green : Colors.transparent,
      child: postImageBytes == null
          ? const Center(
              child: Text(
                '画像未選択',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Image.memory(
              postImageBytes!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 138,
            ),
    ),
  );

  // プロフィール編集ボタン
  Widget editButton() => OutlinedButton(
    onPressed: () => debugPrint('プロフィール編集'),
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(color: Colors.black),
      shape: const StadiumBorder(),
    ),
    child: const Text('プロフィール編集'),
  );

  // 投稿操作
  Widget postActions() => Row(
    children: [
      actionIcon(Icons.favorite, Colors.red, 'いいね'),
      actionIcon(Icons.chat_bubble_outline, Colors.black, 'コメント'),
      actionIcon(Icons.bookmark_border, Colors.black54, 'ブックマーク'),
      const Spacer(),
      TextButton(
        onPressed: () => debugPrint('投稿削除'),
        child: const Text(
          '削除',
          style: TextStyle(color: Colors.red),
        ),
      ),
      TextButton(
        onPressed: () => debugPrint('投稿編集'),
        child: const Text(
          '編集',
          style: TextStyle(color: Colors.black),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 戻るボタン
                    IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),

                    // プロフィール
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              avatar(60),
                              const Spacer(),
                              editButton(),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text('アカウント名'),
                          const SizedBox(height: 5),
                          const Text(
                            '🐵 一言投稿 文字が見えません',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 15),
                          const Row(
                            children: [
                              Text('0 フォロー中'),
                              SizedBox(width: 15),
                              Text('0 フォロワー'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('ポスト'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Divider(color: Colors.black26, height: 1),

                    // 投稿
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 投稿者
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                avatar(34),
                                const SizedBox(width: 12),
                                const Text('アカウント名'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 投稿した文章
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'ここに投稿した人が入力した文章が表示されます',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // 投稿画像
                          postImage(context),

                          // 投稿操作
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: postActions(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 下部メニュー
            Container(
              height: 48,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black, width: 1.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  bottomIcon(Icons.search, 30, '検索'),
                  bottomIcon(Icons.home, 32, 'ホーム'),
                  bottomIcon(Icons.person, 30, 'マイページ'),
                ],
              ),
            ),
          ],
        ),
      ),

      // 投稿追加・画像選択ボタン
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.cyan,
        onPressed: selectImage,
        child: const Icon(
          Icons.add,
          color: Colors.yellow,
          size: 35,
        ),
      ),
    );
  }
}
