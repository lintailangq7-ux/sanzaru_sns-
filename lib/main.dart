import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'package:srusns_frontend/pages/home_page.dart';
import 'api_client.dart';
import 'media_search_result_page.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: LoginPage());
}