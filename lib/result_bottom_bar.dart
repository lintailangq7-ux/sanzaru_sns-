import 'package:flutter/material.dart';
import 'pages/home_page.dart';

/// 検索結果画面の下部バー(検索 / ホーム / マイページ)
class ResultBottomBar extends StatelessWidget {
  const ResultBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, // この画面は「検索」の続き
      onTap: (index) {
        switch (index) {
          case 0: // 検索:検索画面に戻る
            Navigator.pop(context);
            break;
          case 1: // ホーム
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
            break;
          case 2: // マイページ(まだ無い)
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('マイページは準備中です')));
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: '検索'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
      ],
    );
  }
}