import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ShopScreenState();
}

class ShopScreenState extends State<ShopScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SHOP'),
      ),
    );
  }
}