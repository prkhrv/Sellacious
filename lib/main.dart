import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_reader/qr_reader.dart';
import 'package:sellacious_app/webview.dart';
void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Sellacious',
      home: new MyHomePage(),
      theme: ThemeData(
        primaryColor: Colors.lightGreen
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  final Map<String, dynamic> pluginParameters = {
  };

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<String> _barcodeString;
  TextEditingController roomController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    roomController = new TextEditingController(text:"https://");
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
                  minWidth: 20.0,
                  color: Colors.lightGreen,
                  textColor: Colors.white,
                  child: new Text(
                    "Verify",
                    style: new TextStyle(fontFamily: 'Lato'),

                  ),
                  onPressed: (){
                    print(roomController.toString());
                    var route = new MaterialPageRoute(
                    builder: (BuildContext context)=>new WebviewScreen(url: roomController.text,),
                  );
                   Navigator.of(context).push(route);
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
          new FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _barcodeString = new QRCodeReader()
                              .setAutoFocusIntervalInMs(200)
                              .setForceAutoFocus(true)
                              .setTorchEnabled(true)
                              .setHandlePermissions(true)
                              .setExecuteAfterPermissionGranted(true)
                              .scan();
                          
                        });
                      },
                      tooltip: 'Reader the QRCode',
                      child: new Icon(Icons.add_a_photo),
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