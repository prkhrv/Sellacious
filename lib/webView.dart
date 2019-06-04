import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart';


class MyWebView extends StatefulWidget {
  final String url;
  MyWebView({Key key,this.url}):super(key:key);
  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {


  static Future<void> pop() async {
    await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
  }




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => pop(),
        child:WebviewScaffold(
      appBar: AppBar(
        title: Text("Sellacious"),
        automaticallyImplyLeading: false,
      ),
        url: widget.url,
    ),
    );
  }
}

