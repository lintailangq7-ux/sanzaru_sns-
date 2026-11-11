import 'package:flutter/material.dart';
import '../api_client.dart';
import 'home_page.dart';

// サーバーの AccountType の key に合わせて書き換える
const typeLabels = {
  'mizaru': '見ざる',
  'iwazaru': '言わざる',
  'kikazaru': '聞かざる',
};

class RevealPage extends StatelessWidget {
  const RevealPage({super.key});


  ///HTML部分
  @override
  Widget build(BuildContext context) {
    final type = ApiClient.currentUser?['type'] as String? ?? '';
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('あなたは…'),
          const SizedBox(height: 16),
          Text(typeLabels[type] ?? type,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage())),
            child: const Text('はじめる'),
          ),
        ]),
      ),
    );
  }
}