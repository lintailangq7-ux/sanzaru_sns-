import 'package:flutter/material.dart';
import 'pages/login.dart';
import 'package:srusns_frontend/pages/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: HomePage());
}