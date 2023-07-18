import 'package:apart_joa_app/src/webview_controller.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'only_one_pointer_recognizer_widget.dart';

class WebViewMain extends StatefulWidget {
  const WebViewMain({Key? key}) : super(key: key);

  @override
  State<WebViewMain> createState() => _WebViewMainState();
}

class _WebViewMainState extends State<WebViewMain> {
  final controller = WebviewMainController.to.getController();
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    // setToken();
    controller.enableZoom(false);
  }

  Future<void> setToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var prefsToken = prefs.getString('login-token');
    if (prefsToken != null && prefsToken.isNotEmpty) {
      // 로그아웃 + SharedPreferences에 token이 있을 때
      logger.d(">>> token : $prefsToken");
      // var script = 'localStorage.setItem("login-token", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsInVzZXJOYW1lIjoi7IaQ7KKF6rWtIiwiYXB0Q29kZSI6ImdoaCIsInJvbGVJZCI6IlNZU1RFTSIsImV4cCI6MTY4ODk3MTc0Nn0.JWrW0_maa6BN7cY8SDCIuhCRiLkBs6VvGnYlm7kx7KQ")';
      var script = 'localStorage.setItem("login-token", $prefsToken)';
      logger.d(">>> script : $script");
      controller.runJavaScript(script);
    }
  }

// 앱 나가기 전 dialog
  Future<bool> showExitPopup() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('앱을 종료하시겠습니까?'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('네'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

// 뒤로가기 로직(핸드폰 뒤로가기 버튼 클릭시)
  Future<bool> onGoBack() async {
    if (await controller.canGoBack()) {
      // => Webview의 뒤로가기가 가능하면
      controller.goBack(); // => Webview 뒤로가기
      return false; // onWillPop은 false면 앱을 끄지 않는다.
    } else {
      final dialogResult = await showExitPopup();
      return dialogResult; // true이면 앱 끄기;
    }
  }

  @override
  Widget build(BuildContext context) {
    logger.d(">>> web_view_stack.dart build()");
    // setToken();
    return Scaffold(
      body: Stack(
        children: [
          WillPopScope(
            child: WebViewWidget(controller: controller),
            onWillPop: () => onGoBack(),
          ),
          const OnlyOnePointerRecognizerWidget(),
        ],
      ),
    );
  }
}
