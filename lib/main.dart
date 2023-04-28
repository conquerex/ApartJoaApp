import 'package:apart_joa_app/src/webview_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Delete the package:webview_flutter/webview_flutter.dart import
import 'src/web_view_stack.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //전역에 webview controller get 세팅
  Get.put(WebviewMainController());

  //Getx controller는 get find로 가져올 수 있다.
  //controller 안에 'get to => Get.find()'를 사용하면 Get put으로 세팅한 값들을 가져올 수 있다.

  runApp(
    const MaterialApp(
      home: SafeArea(child: WebViewMain()),
    ),
  );
}
