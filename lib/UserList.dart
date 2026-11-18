import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'api_client.dart'; // baseUrl を使う(lib/pages の中なら '../api_client.dart')

// 単独で動かして確認するための入口
void main() => runApp(const UserListApp());

class UserListApp extends StatelessWidget {
  const UserListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: UserTexts.pageTitle,
      theme: ThemeData(scaffoldBackgroundColor: UserPalette.bg),
      home: const UserListPage(),
    );
  }
}

// ============================================================
// 【1】文字
// ============================================================
class UserTexts {
  static const pageTitle = 'ユーザー一覧(確認用)';
  static const retry = '再読み込み';
  static const emptyText = 'ユーザーがいません';
  static const noBio = '(自己紹介なし)';
  static const noValue = '(未設定)';

  // account_type の表示名
  static const accountTypes = {
    'mizaru': '見ざる',
    'iwazaru': '言わざる',
    'kikazaru': '聞かざる',
  };
}

// ============================================================
// 【2】色
// ============================================================
class UserPalette {
  static const Color bg = Colors.white;
  static const Color text = Colors.black;
  static const Color sub = Color(0xFF666666); // 小さい文字
  static const Color line = Color(0xFFDDDDDD); // カードの枠
  static const Color accent = Color(0xFF1A9AD6);
  static const Color iconBg = Color(0xFFE0E0E0); // 画像が無いときの背景
  static const Color error = Color(0xFFDD0000);
}

// ============================================================
// 【3】サイズ
// ============================================================
class UserSizes {
  static const double columnWidth = 600;
  static const double avatar = 56;
  static const double cardPadding = 12;
}

// ============================================================
// 【3-2】画像の置き場所
//   icon_path がファイル名だけのとき、この中の画像として表示する
// ============================================================
class UserImages {
  static const String dir = 'assets/images/';
}

// ============================================================
// 【4】データ：usersテーブル1行分
// ============================================================
class UserRow {
  final int id;
  final String mail;
  final String name;
  final String? bio;
  final String? birthday;
  final String? iconPath;
  final String accountType;
  final String createdAt;
  const UserRow({
    required this.id,
    required this.mail,
    required this.name,
    this.bio,
    this.birthday,
    this.iconPath,
    required this.accountType,
    required this.createdAt,
  });

  factory UserRow.fromJson(Map<String, dynamic> j) => UserRow(
        id: (j['id'] as num).toInt(),
        mail: (j['user_mail'] ?? '') as String,
        name: (j['user_name'] ?? '') as String,
        bio: j['bio'] as String?,
        birthday: j['birthday'] as String?,
        iconPath: j['icon_path'] as String?,
        accountType: (j['account_type'] ?? '') as String,
        createdAt: (j['created_at'] ?? '') as String,
      );
}

/// ユーザー一覧を取得 (GET /UserListServlet)
/// ユーザー一覧を取得 (GET /api/users)
Future<List<UserRow>> fetchUsers() async {
  // ★ 確認用：トークンが無ければ、ここでログインする
  if (ApiClient.token == null) {
    try {
      await ApiClient.login(UserDev.mail, UserDev.password);
    } catch (e) {
      throw ApiException('ログインに失敗しました: $e');
    }
  }

  final http.Response res;
  try {
    res = await http.get(Uri.parse('$baseUrl/api/users'), headers: {
      'Authorization': 'Bearer ${ApiClient.token}',
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
        ((data as Map)['error'] ?? 'ユーザーの取得に失敗しました') as String);
  }
  return (data as List)
      .cast<Map<String, dynamic>>()
      .map(UserRow.fromJson)
      .toList();
}

// ============================================================
// ユーザー一覧ページ
// ============================================================
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Future<List<UserRow>> _future = fetchUsers();

  void _reload() => setState(() => _future = fetchUsers());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UserTexts.pageTitle),
        actions: [
          IconButton(
            tooltip: UserTexts.retry,
            icon: const Icon(Icons.refresh),
            onPressed: _reload,
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: UserSizes.columnWidth),
          child: FutureBuilder<List<UserRow>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${snap.error}',
                          style: const TextStyle(color: UserPalette.error)),
                      const SizedBox(height: 12),
                      OutlinedButton(
                          onPressed: _reload,
                          child: const Text(UserTexts.retry)),
                    ],
                  ),
                );
              }
              final users = snap.data!;
              if (users.isEmpty) {
                return const Center(child: Text(UserTexts.emptyText));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: users.length,
                itemBuilder: (context, i) => _UserCard(user: users[i]),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 画面の部品
// ============================================================

/// ユーザー1人分のカード
class _UserCard extends StatelessWidget {
  final UserRow user;
  const _UserCard({required this.user});

  String _orNone(String? v) =>
      (v == null || v.isEmpty) ? UserTexts.noValue : v;

  @override
  Widget build(BuildContext context) {
    final typeLabel =
        UserTexts.accountTypes[user.accountType] ?? user.accountType;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(UserSizes.cardPadding),
      decoration: BoxDecoration(
        border: Border.all(color: UserPalette.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserIcon(path: user.iconPath),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('${user.id}',
                        style: const TextStyle(color: UserPalette.sub)),
                    Text(user.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: UserPalette.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(typeLabel,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(user.mail,
                    style: const TextStyle(color: UserPalette.sub)),
                const SizedBox(height: 4),
                Text(user.bio == null || user.bio!.isEmpty
                    ? UserTexts.noBio
                    : user.bio!),
                const SizedBox(height: 4),
                Text('誕生日: ${_orNone(user.birthday)}',
                    style: const TextStyle(
                        fontSize: 12, color: UserPalette.sub)),
                Text('登録: ${user.createdAt}',
                    style: const TextStyle(
                        fontSize: 12, color: UserPalette.sub)),
                Text('icon_path: ${_orNone(user.iconPath)}',
                    style: const TextStyle(
                        fontSize: 12, color: UserPalette.sub)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 丸いアイコン画像
///  icon_path が
///   - http(s):// で始まる → ネットの画像として表示
///   - assets/ で始まる    → アプリ内の画像(assets)として表示
///   - それ以外(ファイル名だけ。例: treeMonkey.png)
///                         → assets/images/ の中の画像として表示
///  NULL・空・読めないときは、人型のマークを出す
class _UserIcon extends StatelessWidget {
  final String? path;
  const _UserIcon({required this.path});

  Widget get _placeholder => Container(
        width: UserSizes.avatar,
        height: UserSizes.avatar,
        color: UserPalette.iconBg,
        child: const Icon(Icons.person, color: Colors.white, size: 32),
      );

  @override
  Widget build(BuildContext context) {
    final p = path?.trim();
    Widget child;
    if (p == null || p.isEmpty) {
      child = _placeholder;
    } else if (p.startsWith('http://') || p.startsWith('https://')) {
      child = Image.network(p,
          width: UserSizes.avatar,
          height: UserSizes.avatar,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder);
    } else if (p.startsWith('assets/')) {
      child = Image.asset(p,
          width: UserSizes.avatar,
          height: UserSizes.avatar,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder);
    } else {
      // ファイル名だけなら assets/images/ の画像として表示
      child = Image.asset('${UserImages.dir}$p',
          width: UserSizes.avatar,
          height: UserSizes.avatar,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder);
    }
    return ClipOval(child: child);
  }
}
// ============================================================
// 【3-3】確認用のログイン情報(開発用。本番では使わない)
// ============================================================
class UserDev {
  static const String mail = 'saru01@example.com';
  static const String password = 'password123';
}