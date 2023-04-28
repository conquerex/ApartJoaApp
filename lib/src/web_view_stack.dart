import 'package:apart_joa_app/src/webview_controller.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'only_one_pointer_recognizer_widget.dart';

class WebViewMain extends StatefulWidget {
  const WebViewMain({Key? key}) : super(key: key);

  @override
  State<WebViewMain> createState() => _WebViewMainState();
}

class _WebViewMainState extends State<WebViewMain> {
  final controller = WebviewMainController.to.getController();

  @override
  void initState() {
    super.initState();
    // controller.loadRequest(Uri.parse('http://43.200.37.141/user/login/'));
    controller.enableZoom(false);
  }

  //home으로 가는 버튼 함수
  void goHome() {
    controller.loadRequest(Uri.parse('http://43.200.37.141/user/login/'));
  }

  //앱 나가기 전 dialog
  Future<bool> showExitPopup() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('앱을 종료하시겠습니까?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                // => false 리턴
                child: const Text('아니오'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true), // => true 리턴
                child: const Text('네'),
              ),
            ],
          ),
        ) ??
        false;
  }

  //뒤로가기 로직(핸드폰 뒤로가기 버튼 클릭시)
  Future<bool> onGoBack() async {
    if (await controller.canGoBack()) {
      // => Webview의 뒤로가기가 가능하면
      controller.goBack(); // => Webview 뒤로가기
      return Future.value(false); // => onWillPop은 false면 앱을 끄지 않는다.
    } else {
      Future<bool> dialogResult = showExitPopup();
      return Future.value(dialogResult); // => true이면 앱 끄기;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WillPopScope(
            child: WebViewWidget(controller: controller),
            onWillPop: () => onGoBack(),
          ),
          const OnlyOnePointerRecognizerWidget()
        ],
      ),
    );
  }
}
