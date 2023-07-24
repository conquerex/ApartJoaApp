import 'package:flutter/material.dart';

import 'src/web_view_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      // home: SafeArea(child: WebViewMain()),
      home: SafeArea(child: WebViewPage()),
    ),
  );
}
