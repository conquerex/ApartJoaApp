import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  final GlobalKey webViewKey = GlobalKey();

  // final basicUrl = 'http://43.200.37.141/'; // 개발서버
  final basicUrl = 'https://aptjoa.com/';

  // final basicUrl = 'https://66ba-59-10-74-16.ngrok-free.app/';
  late Uri myUrl;
  late final InAppWebViewController webViewController;
  late SharedPreferences prefs;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    initPrefs();
    myUrl = Uri.parse(basicUrl);
  }

  // prefs 초기화
  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: WillPopScope(
                onWillPop: () => _goBack(context),
                child: Column(children: <Widget>[
                  progress < 1.0 ? LinearProgressIndicator(value: progress, color: Colors.blue) : Container(),
                  Expanded(
                      child: Stack(children: [
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: myUrl),
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          javaScriptCanOpenWindowsAutomatically: true,
                          javaScriptEnabled: true,
                          useOnDownloadStart: true,
                          useOnLoadResource: true,
                          useShouldOverrideUrlLoading: true,
                          mediaPlaybackRequiresUserGesture: true,
                          allowFileAccessFromFileURLs: true,
                          allowUniversalAccessFromFileURLs: true,
                          verticalScrollBarEnabled: true,
                          userAgent:
                              'Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36',
                          supportZoom: false,
                        ),
                        android: AndroidInAppWebViewOptions(
                            useHybridComposition: true,
                            allowContentAccess: true,
                            builtInZoomControls: false,
                            thirdPartyCookiesEnabled: true,
                            allowFileAccess: true,
                            supportMultipleWindows: true),
                        ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                          allowsBackForwardNavigationGestures: true,
                        ),
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        print('>>>>> onWebViewCreated');
                        webViewController = controller;
                        // SharedPreferences prefs = await SharedPreferences.getInstance();
                        if (prefs.containsKey('login-token')) {
                          Fluttertoast.showToast(msg: "onWebViewCreated :: ${prefs.getString('login-token')}");
                          print('>>>>> onWebViewCreated :: ${prefs.getString('login-token')}');
                          // SharedPreferences에 저장된 로그인 토큰을 가져와서 localStorage에 저장
                          controller.evaluateJavascript(source: """
                            localStorage.setItem("login-token", "${prefs.getString('login-token')}");
                          """);
                        }
                        controller.addJavaScriptHandler(
                            handlerName: 'loginToken',
                            callback: (args) {
                              print('>>>>> loginToken : $args');
                              setToken(args[0]);
                            });
                        controller.reload();
                      },
                      onLoadStart: (InAppWebViewController controller, uri) async {
                        print('>>>>> onLoadStart : $uri');
                        setState(() {
                          myUrl = uri!;
                        });
                      },
                      onLoadStop: (InAppWebViewController controller, uri) async {
                        print('>>>>> onLoadStop : $uri');
                        if (uri.toString().contains("${basicUrl}user/login")) {
                          print('>>>>> onLoadStop : login');
                          // 로그인시, 로그인 토큰을 가져와서 SharedPreferences에 저장
                          controller.evaluateJavascript(source: """
                            window.flutter_inappwebview.callHandler('loginToken', localStorage.getItem('login-token'));
                          """);
                          controller.reload();
                        }

                        if (uri.toString() == "${basicUrl}qna/list") {
                          printToken();
                        }

                        if (uri.toString() == "${basicUrl}category/selectCategory") {
                          controller.evaluateJavascript(source: """
                            localStorage.clear();
                          """);
                        }

                        if (uri.toString() == "${basicUrl}user/my-info") {
                          // 로그아웃을 위한 핸들러
                          controller.evaluateJavascript(source: """
                            window.flutter_inappwebview.callHandler('loginToken', localStorage.getItem('login-token'));
                          """);
                        }

                        setState(() {
                          myUrl = uri!;
                        });
                      },
                      onCreateWindow: (controller, createWindowRequest) async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 400,
                                child: InAppWebView(
                                  // Setting the windowId property is important here!
                                  windowId: createWindowRequest.windowId,
                                  initialOptions: InAppWebViewGroupOptions(
                                    android: AndroidInAppWebViewOptions(
                                      builtInZoomControls: false,
                                      thirdPartyCookiesEnabled: true,
                                    ),
                                    crossPlatform: InAppWebViewOptions(
                                      mediaPlaybackRequiresUserGesture: false,
                                      cacheEnabled: true,
                                      javaScriptEnabled: true,
                                      userAgent:
                                          "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36",
                                    ),
                                    ios: IOSInAppWebViewOptions(
                                      allowsInlineMediaPlayback: true,
                                      allowsBackForwardNavigationGestures: true,
                                    ),
                                  ),
                                  onCloseWindow: (controller) async {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                        return true;
                      },
                    )
                  ]))
                ]))));
  }

  /**
   * 로그인 토큰을 SharedPreferences에 저장
   */
  Future<void> setToken(String? loginToken) async {
    print('>>>>> setToken : $loginToken');
    if (loginToken == null || loginToken == '') {
      prefs.clear();
      return;
    }
    prefs.setString('login-token', loginToken);
  }

  Future<void> clearTest() async {
    prefs.clear();
  }

  Future<void> printToken() async {
    print('>>>>> printToken : ${prefs.getString('login-token')}');
  }

  Future<void> callLoginToken(InAppWebViewController controller) async {}

  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
