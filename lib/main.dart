import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 動かす先によって、サーバーのアドレスが変わる
String get baseUrl {
  if (kIsWeb) return 'http://localhost:8080/SaruSNS';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8080/SaruSNS';   // Androidエミュレーターから見た「PC自身」
  }
  return 'http://localhost:8080/SaruSNS';
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(home: PingPage());
}

class PingPage extends StatefulWidget {
  const PingPage({super.key});
  @override
  State<PingPage> createState() => _PingPageState();
}

class _PingPageState extends State<PingPage> {
  String _result = '未接続';

  Future<void> _ping() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/ping'));
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      setState(() => _result = '${res.statusCode}: ${data['status']}');
    } catch (e) {
      setState(() => _result = 'エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('接続テスト')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_result),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _ping, child: const Text('サーバーに接続')),
          ],
        ),
      ),
    );
  }
}