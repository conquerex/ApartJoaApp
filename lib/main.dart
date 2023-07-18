import 'package:apart_joa_app/src/webview_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Delete the package:webview_flutter/webview_flutter.dart import
import 'src/web_view_page.dart';
import 'src/web_view_stack.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //전역에 webview controller get 세팅
  Get.put(WebviewMainController());

  //Getx controller는 get find로 가져올 수 있다.
  //controller 안에 'get to => Get.find()'를 사용하면 Get put으로 세팅한 값들을 가져올 수 있다.

  runApp(
    const MaterialApp(
      // home: SafeArea(child: WebViewMain()),
      home: SafeArea(child: WebViewPage()),
    ),
  );
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // WebviewMainController의 controller를 호출
//     late final controller = WebviewMainController.to.getController();
//
//     return MaterialApp(
//         home: Scaffold(
//       appBar: PreferredSize(
//           // 앱 바는 필요하지 않았기에 0으로
//           preferredSize: const Size.fromHeight(0),
//           // elevation = 필요하지 않은 그림자 효과
//           child: AppBar(elevation: 0)),
//       //WebViewWidget에 controller를 parameter로 넘겨준다
//       body: WebViewWidget(controller: controller),
//     ));
//   }
// }
