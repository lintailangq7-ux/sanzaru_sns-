import 'package:flutter/material.dart';
import 'home_page.dart';
import 'post.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userName: 'テストユーザー',),
    ),
  );
}