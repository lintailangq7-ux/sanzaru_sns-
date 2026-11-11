import 'package:flutter/material.dart';
import '../api_client.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final posts = await ApiClient.fetchPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '投稿の読み込みに失敗しました';
        _loading = false;
      });
    }
  }
  
  ///html部分
  @override
  Widget build(BuildContext context) {
    final user = ApiClient.currentUser;
    final displayName = user?['displayName'] ?? user?['username'] ?? 'ユーザー';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SaruSNS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
            tooltip: '更新',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'ログアウト',
          ),
        ],
      ),
      body: _buildBody(displayName),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '検索'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('投稿機能はこれから実装します')),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildBody(String displayName) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const Center(child: Text('検索画面（これから実装）'));
      case 2:
        return _buildMyPageTab(displayName);
      default:
        return const SizedBox.shrink();
    }
  }

  // 投稿一覧
  Widget _buildHomeTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPosts,
              child: const Text('再読み込み'),
            ),
          ],
        ),
      );
    }
    if (_posts.isEmpty) {
      return const Center(child: Text('まだ投稿がありません'));
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          final user = post['user'] as Map<String, dynamic>? ?? {};
          final content = post['content'] ?? post['text'] ?? '';
          final createdAt = post['createdAt'] ?? post['created_at'] ?? '';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        child: Text(
                          (user['displayName'] ?? user['username'] ?? '?')
                              .toString()
                              .characters
                              .first
                              .toUpperCase(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['displayName'] ?? user['username'] ?? '不明',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '@${user['username'] ?? ''}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        createdAt.toString(),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(content.toString()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // マイページ
  Widget _buildMyPageTab(String displayName) {
    final user = ApiClient.currentUser;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '@${user?['username'] ?? ''}',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('プロフィール編集'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('プロフィール編集はこれから実装します')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('ログアウト'),
          onTap: _logout,
        ),
      ],
    );
  }

  void _logout() {
    ApiClient.token = null;
    ApiClient.currentUser = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}