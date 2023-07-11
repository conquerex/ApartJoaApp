import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// `token.length < 10`의 의미
/// -> localStorage에 token 정보가 없음을 의미함. 숫자 10은 큰 의미 없음
class WebviewMainController extends GetxController {
  static WebviewMainController get to => Get.find();
  final basicUrl = 'https://aptjoa.com/';
  final emptyUrl = 'https://aptjoa.com/empty';
  final loginUrl = 'https://aptjoa.com/user/login';
  final homeUrl = 'https://aptjoa.com/user/my-info';
  late WebViewController controller;
  late SharedPreferences prefs;
  final logger = Logger();
  var loginToken = '';
  var isInitController = true;

  WebviewMainController() {
    _initializeController();
  }

  void _initializeController() async {
    prefs = await SharedPreferences.getInstance();
    var prefsToken = prefs.getString('login-token');
    var script = 'localStorage.setItem("login-token", $prefsToken)';
    logger.d(">>>>>>>> before WebViewController : $script");
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            logger.d(">>>>>>>> onPageSTARTED url : $url");
            // if (url.contains(loginUrl)) {
            //   logout();
            // }
          },
          onPageFinished: (String url) {
            logger.d(">>>>>>>> onPageFINISHED url : $url");
            if (url.contains('https://aptjoa.com/category/selectCategory')) {
              testClear();
            }
            if (url == basicUrl || url == emptyUrl) {
              updatePrefs();
            }
            logout();
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    await controller.loadRequest(Uri.parse(basicUrl)); // => 웹뷰에 연결할 URL
    var token = await controller.runJavaScriptReturningResult('localStorage.getItem("login-token")') as String;
    if (prefsToken != null && token.length < 10) {
      logger.d('reload.... 자동 로그인');
      await controller.runJavaScript(script);
      await controller.reload();
    }
  }

  Future<void> updatePrefs() async {
    logger.d(">>>>> onPageFinished::basicUrl");
    var prefsToken = prefs.getString('login-token');
    logger.d('1. prefsToken :::: ${getEndText(prefsToken)}');
    var localToken = await controller.runJavaScriptReturningResult('localStorage.getItem("login-token")') as String;
    logger.d('2. localToken :::: ${getEndText(localToken)}');
    if (localToken.length > 10) {
      if (prefsToken == null || prefsToken != localToken) {
        logger.d('prefs.setString.... 로그인시 prefs 갱신 / ${prefsToken == null} / ${prefsToken != localToken}');
        prefs.setString('login-token', localToken);
      }
    }
    isInitController = false;
  }

  String getEndText(String? text) {
    if (text != null && text.length > 5) {
      return text.substring(text.length - 5, text.length - 1);
    } else {
      return '----';
    }
  }

  Future<void> logout() async {
    logger.d(">>>>> onPageStarted::loginUrl / $isInitController");
    final result = await controller.runJavaScriptReturningResult('localStorage.getItem("login-token")') as String;
    if (result.length < 10 && !isInitController) {
      // 로그아웃한 경우
      logger.d('result nothing......');
      prefs.clear();
    }
  }

  Future<void> testClear() async {
    logger.d(">>>>> onPageFinished::clear - 테스트용 / 제거할 예정");
    await controller.runJavaScriptReturningResult('localStorage.clear()') as String;
    final result = await controller.runJavaScriptReturningResult('localStorage.getItem("login-token")') as String;
    logger.d('result.... $result');
  }

  WebViewController getController() {
    return controller;
  }
}
