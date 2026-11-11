
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final user = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    user.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  // 入力欄の共通デザイン
  InputDecoration inputStyle({Widget? icon}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: Color(0xFF17394A),
          width: 2,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: Color(0xFF4CA632),
          width: 2,
        ),
      ),
      suffixIcon: icon,
    );
  }

  // パスワード表示ボタン
  Widget eyeButton(bool visible, VoidCallback onPressed) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 35,
        minHeight: 35,
      ),
      icon: Icon(
        visible ? Icons.visibility_off : Icons.visibility,
        color: Colors.black,
        size: 25,
      ),
      onPressed: onPressed,
    );
  }

  // 入力欄
  Widget inputField(String label, TextEditingController controller,
      {TextInputType type = TextInputType.text,
      Widget? icon,
      bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 5),
        SizedBox(
          height: 35,
          child: TextField(
            controller: controller,
            keyboardType: type,
            obscureText: obscure,
            decoration: inputStyle(icon: icon),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 390,
              constraints: const BoxConstraints(minHeight: 555),
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF17394A),
                  width: 2,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(75),
                  topRight: Radius.circular(75),
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  // 戻るボタンとタイトル
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.maybePop(context);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'さんさるトーク!!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // アイコン画像
                  Container(
                    width: 170,
                    height: 108,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CA632),
                      border: Border.all(
                        color: const Color(0xFF315C26),
                        width: 2,
                       ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/icon.png',
                        width: 170,
                        height: 108,
                        fit: BoxFit.cover,
                       ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  // 見出し
                  const Text(
                    '新規登録',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 入力フォーム
                  SizedBox(
                    width: 290,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ユーザ名
                        inputField('ユーザ名', user),

                        const SizedBox(height: 10),

                        // メールアドレス
                        inputField(
                          'メールアドレス',
                          email,
                          type: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 10),

                        // パスワード
                        inputField(
                          'パスワード',
                          password,
                          obscure: !showPassword,
                          icon: eyeButton(
                            showPassword,
                            () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        // パスワード確認
                        inputField(
                          'パスワード(確認用)',
                          confirmPassword,
                          obscure: !showConfirmPassword,
                          icon: eyeButton(
                            showConfirmPassword,
                            () {
                              setState(() {
                                showConfirmPassword =
                                    !showConfirmPassword;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 15),

                        // 新規登録ボタン
                        SizedBox(
                          width: double.infinity,
                          height: 29,
                          child: ElevatedButton(
                            onPressed: () {
                              if (user.text.isEmpty ||
                                  email.text.isEmpty ||
                                  password.text.isEmpty ||
                                  confirmPassword.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('すべての項目を入力してください'),
                                  ),
                                );
                              } else if (password.text !=
                                  confirmPassword.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('パスワードが一致しません'),
                                  ),
                                );
                              } else {
                                print('新規登録処理');
                                print(user.text);
                                print(email.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFFF24),
                              foregroundColor: Colors.red,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text(
                              '新規登録',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
