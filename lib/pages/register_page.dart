import 'package:flutter/material.dart';
import '../api_client.dart';
import 'reveal_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _displayName = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return; // 入力のチェック
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ApiClient.register(
          _username.text.trim(), _displayName.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const RevealPage()));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新規登録')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _username,
              decoration: const InputDecoration(labelText: 'ユーザー名(英数字と_ 3〜20文字)'),
              validator: (v) => RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch((v ?? '').trim())
                  ? null
                  : '英数字と_で3〜20文字にしてください',
            ),
            TextFormField(
              controller: _displayName,
              maxLength: 50,
              decoration: const InputDecoration(labelText: '表示名(省略するとユーザー名)'),
            ),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'パスワード(8文字以上)'),
              validator: (v) => (v ?? '').length >= 8 ? null : '8文字以上にしてください',
            ),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'パスワード(確認)'),
              validator: (v) => v == _password.text ? null : 'パスワードが一致しません',
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
                onPressed: _busy ? null : _register, child: const Text('登録する')),
          ]),
        ),
      ),
    );
  }
}