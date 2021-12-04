import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'auth.dart';

class HomePage extends StatefulWidget {
  // const HomePage({Key? key}) : super(key: key);
  HomePage({required this.auth, required this.onSignOut});
  final BaseAuth auth;
  final VoidCallback onSignOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final databaseRef =
  FirebaseDatabase.instance.reference(); //database reference object
  int money = 0;

  servoRequest(String product, String servo, String price){
    databaseRef.child("products").child(product).once().then((value) async {
      await databaseRef.child("servo").set(int.parse(servo));
      await databaseRef.child("user-detail").child(user).set({"money": money-int.parse(price)}).then((value){
        setState(() {
          money = money-int.parse(price);
        });
      });
      await databaseRef.child("products").child(product).once().then((value){
        int new_price = int.parse(value.value["quantity"])-1;
        databaseRef.child("products").child(product).update({"quantity": new_price.toString()});
      });
    });
  }
  bool showing=false;
  String user = "";
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result= null;
  QRViewController? controller;
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    widget.auth.currentUser().then((value){
      databaseRef.child("user-detail").child(value)
          .once().then((ud){

        setState(() {
          print("USER DETAIL :: "+ud.value.toString());
          print("USER DETAIL :: "+ud.value["money"].toString());
          user = ud.key.toString();
          if(ud.value==null){
            databaseRef.child("user-detail").child(value).set({"money": 0});
            money = 0;
          }else{
            money = int.parse(ud.value["money"].toString());
          }
        });
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    print(money);
    // databaseRef.child("user-detail").child(auth.currentUser).once().then((value) {
    //   databaseRef.child("servo").set(value.value["servo"]);
    // });


    void _signOut() async {
      try {
        await widget.auth.signOut();
        widget.onSignOut();
      } catch (e) {
        print(e);
      }

    }
    return new Scaffold(
        appBar: new AppBar(
          actions: <Widget>[
            new FlatButton(
                onPressed: _signOut,
                child: new Text('Logout', style: new TextStyle(fontSize: 17.0, color: Colors.white))
            )
          ],
        ),
        body: new Center(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Text("Amount ${money}")),
                Expanded(
                  flex: 3,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: _onQRViewCreated,
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Center(
                //     child: (result != null)
                //         ? Text(
                //         'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}' )
                //         : Text('Scan a code'),
                //   ),
                // )
              ],
            ),
          ),
        )
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() async {
        result = scanData;
        dynamic _decode = jsonDecode(result!.code.toString());
        String id = _decode["id"];
        String price = _decode["price"];
        String servo = _decode["servo"];
        String quantity = _decode["quantity"];
        print("QUANTITY :: " +quantity.toString());
        if(quantity==null || int.parse(quantity)==0){
          Alert(title: "No quantity left", context: context);
        }
        else if(showing==false){
          Alert(

              onWillPopActive: true,
              closeFunction: (){
                setState(() {
                  showing = false;
                });
              },
              context: context,
              title: "QR SCAN DONE",
              content: Column(
                children: [
                  Text("Your product is ready"),
                  Text("Price " + price.toString()),
                ],
              ),
              buttons: [
                DialogButton(
                  onPressed: () {
                    if(money>int.parse(price)){
                      servoRequest(id, servo, price);
                    }
                    setState(() {
                      showing = false;
                    });
                    Navigator.pop(context);
                  }, child: Text(money>int.parse(price) ? "Yes" : "Not enough money",
                  style: TextStyle(color: Colors.white, fontSize: 20),),

                ),
                DialogButton(
                  onPressed: (){Navigator.pop(context);

                  setState(() {
                    showing = false;
                  });
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ]).show();
          setState(() {
            showing = true;
          });
        }

        // await databaseRef.child("products").child(id).once().then((value) => print(value.value["servo"].toString()));

      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }


}

//
// class HomePage extends StatelessWidget {
//
//
//
// }