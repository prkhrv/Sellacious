import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';




class MyWebView extends StatefulWidget {
  final String url;
  MyWebView({Key key,this.url}):super(key:key);
  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {

  final flutterWebViewPlugin = FlutterWebviewPlugin();

  static Future<void> pop() async {
    await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
  }

  void checkAction(String choices) {
    if(choices=="Unlink QR") {
      clearUrl();
    }
  }


  clearUrl() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("savedUrl");
    pop();
  }


  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return WillPopScope(
        onWillPop: () => pop(),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(top: statusBarHeight),
          child: WebviewScaffold(
            url : widget.url,
            bottomNavigationBar: BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      flutterWebViewPlugin.goBack();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      flutterWebViewPlugin.goForward();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.autorenew),
                    onPressed: () {
                      flutterWebViewPlugin.reload();
                    },
                  ),
                  new FloatingActionButton.extended(
                    backgroundColor: Colors.white,
                    label: Text("Unlink QR"),
                    elevation: 0.0,
                    icon: Icon(Icons.link_off),
                    onPressed: () {
                      clearUrl();
                    },


                  ),
                ],
              ),
            ),
          ),

        )
    );
  }
}
