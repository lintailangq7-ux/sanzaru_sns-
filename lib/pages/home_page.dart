import 'package:flutter/material.dart';
import '../api_client.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  ///HTML部分
  @override
  Widget build(BuildContext context) {
    final user = ApiClient.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('ホーム')),
      body: Center(child: Text('${user?['displayName']} さん、ようこそ(準備中)')),
    );
  }
}