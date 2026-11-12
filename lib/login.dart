import 'register.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: LoginPage(),
));

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showPassword = false;

  final email = TextEditingController();
  final password = TextEditingController();

  // 入力欄の共通デザイン
  InputDecoration inputStyle({Widget? icon}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 7, vertical: 4),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFF17394A), width: 2)),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color(0xFF4CA632), width: 2)),
      suffixIcon: icon,
    );
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(15, 25, 15, 40),
                child: Column(
                  children: [
                    const Text(
                      'さんさるトーク!!',
                      style: TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 28),

                    // アイコン画像
                    Container(
                      width: 205,
                      height: 130,
                      margin: const EdgeInsets.only(bottom: 19),
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
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const Text(
                      'ログイン',
                      style: TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: 290,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'メールアドレス',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 5),

                          SizedBox(
                            height: 40,
                            child: TextField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: inputStyle(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'パスワード',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 5),

                          SizedBox(
                            height: 40,
                            child: TextField(
                              controller: password,
                              obscureText: !showPassword,
                              enableInteractiveSelection: true,
                              decoration: inputStyle(
                                icon: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 35,
                                    minHeight: 35,
                                  ),
                                  icon: Icon(
                                    showPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showPassword = !showPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ログインボタン
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                print(email.text);
                                print(password.text);
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
                                'ログイン',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          // リンク
                          Center(
                            child: Column(
                              children: [
                                link('パスワードを忘れた方'),
                                const SizedBox(height: 15),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'アカウントを作成する',
                                    style: TextStyle(
                                      color: Color(0xFF5799ED),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

  // リンクの共通デザイン
  //
  Widget link(String text) {
    return GestureDetector(
      onTap: () => print('$text をクリック'),
      child: Text(text,
        style: const TextStyle(
          color: Color(0xFF5799ED), fontSize: 14)),
    );
  }
}