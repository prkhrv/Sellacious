import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';


class MyWebView extends StatefulWidget {
  final String url;
  MyWebView({Key key,this.url}):super(key:key);
  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      appBar: AppBar(
        title: Text("Sellacious"),
      ),
        url: widget.url,
    );
  }
}

