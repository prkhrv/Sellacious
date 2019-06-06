import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'webView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onesignal/onesignal.dart';

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
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  String _debugLabelString = "";
  String _emailAddress;
  String _externalUserId;
  bool _enableConsentButton = false;

  bool _requireConsent = false;
  



  @override
  void initState() {
    super.initState();

    initPlatformState();

    _firebaseMessaging.configure(
      onLaunch: (Map<String,dynamic> msg){
        print("onLaunch");

      },
      onResume: (Map<String,dynamic> msg){
        print("onResume");
      },
      onMessage: (Map<String,dynamic> msg){
        print("onMessage");
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true,
            alert: true,
            badge: true
        )
    );

    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings setting){
      print("IOS setting");
    });

    _firebaseMessaging.getToken().then((token){
      print("Token: $token");
    });


    getUrl();
    roomController = new TextEditingController(text:"https://");
  }


  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted){
      print("Accepted permission: $accepted");
    });
    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationReceivedHandler((notification) {
      this.setState(() {
        _debugLabelString =
        "Received notification: \n${notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {


          String payload = result.notification.payload.additionalData['targetUrl'];
          if(result.notification.payload.additionalData.containsKey('targetUrl')){
            _navigateToNotificationWebView(payload);

          }
          else{
            print("HELLO WORLD #####");
          }



    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setEmailSubscriptionObserver(
            (OSEmailSubscriptionStateChanges changes) {
          print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
        });

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    await OneSignal.shared
        .init("ebe55351-e7e2-4f00-899a-79479e6d13e0", iOSSettings: settings);

    OneSignal.shared
        .setInFocusDisplayType(OSNotificationDisplayType.notification);

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    this.setState(() {
      _enableConsentButton = requiresConsent;
    });
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



  void _navigateToNotificationWebView(String url){

    var route = new MaterialPageRoute(
        builder: (BuildContext context)=>new MyWebView(url: url,)
    );
    Navigator.of(context).push(route);

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
