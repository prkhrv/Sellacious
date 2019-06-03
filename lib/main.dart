import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'webView.dart';
import 'menu.dart';
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


class _MyHomePageState extends State<MyHomePage> {

  TextEditingController roomController;
  @override
  void initState() {
    super.initState();
    roomController = new TextEditingController(text:"https://");
  }

  String result ;


  void _navigateToWebView(String url){

    Navigator.push(context, MaterialPageRoute(builder: (context)=> MyWebView(url: url),
    ),
    );
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
    return new Scaffold(

      appBar: new AppBar(
        title: const Text('Sellacious'),
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

    );
  }

}
