import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'webView.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sellacious',
      theme: ThemeData(

        primarySwatch: Colors.lightGreen,
      ),
      home: MyHomePage(title: 'Sellacious App'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum AuthStatus{
  notSignedIn,
  signedIn,
}



class _MyHomePageState extends State<MyHomePage> {

  AuthStatus authStatus = AuthStatus.notSignedIn;
  TextEditingController roomController;
  String _flag ;
  String result ;



  @override
  void initState() {
    super.initState();
    getUrl();
    roomController = new TextEditingController(text:"https://");
  }


  getUrl() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String myUrl = prefs.getString("savedUrl") ?? 'null' ;
//    print("MY URL :$myUrl");
    setState(() {
      _flag = myUrl;
    });

//    print("FLAG: $_flag");

    if(_flag != 'null'){
      setState(() {
        authStatus = AuthStatus.signedIn;
      });
    }
    else if(_flag == 'null'){
      setState(() {
        authStatus = AuthStatus.notSignedIn;
      });
    }
  }



  static Future<void> pop() async {
    await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');
  }



  Future<bool> setUrl(String url) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString("savedUrl",url);

  }


  void _navigateToWebView(String url){
    setUrl(url);
    var route = new MaterialPageRoute(
        builder: (BuildContext context)=>new MyWebView(url: url,)
    );
    Navigator.of(context).push(route);
    }




  Future _scanQR()async{

    try{
      String qrResult = await BarcodeScanner.scan();
      setState(() {
        result = qrResult;
        roomController.text = result;
        _navigateToWebView(result);


      });

    }on PlatformException catch(ex){
      if(ex.code == BarcodeScanner.CameraAccessDenied){
        setState(() {
          result = "CAMERA ACCESS DENIED";
        });
      }else{
        setState(() {
          result = "Error unknown $ex";
        });
      }
    }


  }

  @override
  Widget build(BuildContext context) {

    switch(authStatus){
      case AuthStatus.notSignedIn:

        return new WillPopScope(
          onWillPop: ()=> pop() ,
          child:Scaffold(
          appBar: new AppBar(
            title: const Text('Sellacious'),
            automaticallyImplyLeading: false,
          ),

          body: new Center(
              child: Stack(
                children: <Widget>[

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      Form(
                          child: Theme(
                              data: new ThemeData(
                                  primaryColor: Colors.black,
                                  brightness: Brightness.light,
                                  primarySwatch: Colors.lightGreen,
                                  inputDecorationTheme: new InputDecorationTheme(
                                      labelStyle: new TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0
                                      )
                                  )
                              ),
                              child: Container(
                                  padding: const EdgeInsets.all(40.0),
                                  child: new Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        FlutterLogo(
                                          size: 100.0,
                                        ),
                                        Padding(
                                            padding:const EdgeInsets.symmetric(vertical: 16.0)
                                        ),
                                        new TextFormField(
                                          controller: roomController,
                                          decoration: new InputDecoration(
                                            contentPadding: EdgeInsets.all(15.0),
                                            border: new OutlineInputBorder(
                                                borderSide: new BorderSide(color: Colors.black,width: 5.0)
                                            ),
                                            labelText: "Enter the Url",
                                            labelStyle: new TextStyle(fontFamily: 'Lato'),
                                          ),
                                          keyboardType: TextInputType.text,
                                          cursorColor: Colors.black,
                                        ),
                                        new Padding(
                                            padding: const EdgeInsets.only(top: 15.0 )
                                        ),
                                        new Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: <Widget>[
                                              new Padding(padding: EdgeInsets.only(left: 150.0)),
                                              new MaterialButton(
                                                height: 50.0,
                                                minWidth: 50.0,
                                                color: Colors.lightGreen,
                                                textColor: Colors.black,
                                                child: new Text(
                                                  "Go",
                                                  style: new TextStyle(fontFamily: 'Lato'),

                                                ),
                                                onPressed: (){
                                                  _navigateToWebView(roomController.text);
                                                },
                                                splashColor: Colors.green,
                                              )
                                            ]
                                        ),
                                        new Padding(
                                            padding: const EdgeInsets.only(top: 20.0)
                                        ),
                                        Text("Or Scan The QR code",
                                          style: new TextStyle(fontSize: 20.0,color: Colors.black,fontWeight: FontWeight.bold,fontFamily:'Lato'),
                                        ),
                                        new Padding(
                                            padding: const EdgeInsets.only(top: 20.0)
                                        ),
                                        new FloatingActionButton.extended(
                                          label: Text("Scan"),
                                          icon: Icon(Icons.settings_overscan),
                                          onPressed: () {
                                            _scanQR();
                                          },
                                          tooltip: 'Scan the QRCode',

                                        ),
                                      ]
                                  )
                              )
                          )
                      ),

                    ],
                  ),

                ],
              )
          ),

        )
        );
      case AuthStatus.signedIn:
        return new MyWebView(url: _flag,
        );

    }

  }

}
