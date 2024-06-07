import 'package:flutter/material.dart';
import 'beach_info/beach_info_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BeachInfoPage(),
    );
  }
}