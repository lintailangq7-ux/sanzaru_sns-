import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/post.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  );
}