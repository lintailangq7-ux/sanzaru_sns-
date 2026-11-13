
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color mainGreen = Color(0xFF4CA632);
  static const Color lineColor = Color(0xFF17394A);

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
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 5),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    // プロフィール情報
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // プロフィール画像
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: mainGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: lineColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),

                              const Spacer(),

                              // プロフィール編集
                              OutlinedButton(
                                onPressed: () {
                                  print('プロフィール編集');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Text('プロフィール編集'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'アカウント名',
                            style: TextStyle(fontSize: 13),
                          ),

                          const SizedBox(height: 5),

                          const Row(
                            children: [
                              Text('🐵 '),
                              Text(
                                '一言投稿',
                                style: TextStyle(
                                  color: Color(0xFF5799ED),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                ' 文字が見えません',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          const Row(
                            children: [
                              Text(
                                '0 フォロー中',
                                style: TextStyle(fontSize: 13),
                              ),
                              SizedBox(width: 15),
                              Text(
                                '0 フォロワー',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'ポスト',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Divider(
                      color: Colors.black26,
                      thickness: 1,
                      height: 1,
                    ),

                    // 投稿一覧
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 投稿者情報
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: mainGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: lineColor,
                                    width: 1.5,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              const Text(
                                'アカウント名',
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          const Center(
                            child: Text(
                              '～～～～～～～～～～～～～～',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // 投稿画像
                          Center(
                            child: Container(
                              width: 198,
                              height: 138,
                              decoration: BoxDecoration(
                                color: mainGreen,
                                border: Border.all(
                                  color: lineColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // 投稿アクション
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  print('いいね');
                                },
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.only(right: 10),
                              ),

                              IconButton(
                                onPressed: () {
                                  print('コメント');
                                },
                                icon: const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.black,
                                ),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.only(right: 10),
                              ),

                              IconButton(
                                onPressed: () {
                                  print('ブックマーク');
                                },
                                icon: const Icon(
                                  Icons.bookmark_border,
                                  color: Colors.black54,
                                ),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),

                              const Spacer(),

                              TextButton(
                                onPressed: () {
                                  print('投稿削除');
                                },
                                child: const Text(
                                  '削除',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  print('投稿編集');
                                },
                                child: const Text(
                                  '編集',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
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
                  IconButton(
                    onPressed: () {
                      print('検索');
                    },
                    icon: const Icon(
                      Icons.search,
                      size: 30,
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      print('ホーム');
                    },
                    icon: const Icon(
                      Icons.home,
                      size: 32,
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      print('マイページ');
                    },
                    icon: const Icon(
                      Icons.person,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 投稿追加ボタン
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.cyan,
        onPressed: () {
          print('投稿追加');
        },
        child: const Icon(
          Icons.add,
          color: Colors.yellow,
          size: 35,
        ),
      ),
    );
  }
}
