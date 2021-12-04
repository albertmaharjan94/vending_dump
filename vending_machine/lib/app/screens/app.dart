import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vending_machine/app/screens/admin/admin.dart';
import 'package:vending_machine/app/screens/components/ads.dart';
import 'package:vending_machine/app/screens/components/contact.dart';
import 'package:vending_machine/app/screens/components/item.dart';
import 'package:vending_machine/app/screens/size_config.dart';

import 'credentials.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("VENDING MACHINE"),
          backgroundColor: Colors.green.withOpacity(0.5),
          leading: Icon(Icons.local_hospital),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                  icon: Icon(Icons.admin_panel_settings),
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        TextEditingController _pin = TextEditingController();
                        FocusNode _node = FocusNode();
                        _node.requestFocus();
                        return AlertDialog(
                          contentPadding: EdgeInsets.zero,
                          title: Column(
                            children: [
                              TextField(
                                decoration: InputDecoration(
                                  hintText: "Admin Pin"
                                ),
                                controller: _pin,
                                focusNode: _node,
                                maxLines: 1,keyboardType:TextInputType.number,),
                            ],
                          ),
                          actions: [
                            ElevatedButton(onPressed: (){

                              if(_pin.value.text.toString() == pin.toString()){
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AdminScreen())).then((value) => setState(() {}));
                                _node.unfocus();
                              }else{
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pin Mismatch"),backgroundColor: Colors.red,));
                              }
                            }, child: Text("Submit")),
                            ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text("Cancel"))
                          ],
                        );
                      })),
            )
          ],
        ),
        body: SafeArea(
          child: Container(
              child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Item()),
                    Expanded(flex: 1, child: ContactWidget()),
                  ],
                ),
              ),
              Expanded(child: Ads())
            ],
          )),
        ));
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  dialog() {
    showAlertDialog(BuildContext context) {
      // set up the button
      Widget okButton = TextButton(
        child: Text("OK"),
        onPressed: () {},
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: Text("My title"),
        content: Text("This is my message."),
        actions: [
          okButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }
}
