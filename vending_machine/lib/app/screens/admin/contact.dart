import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:vending_machine/app/models/product/contact.dart';
import 'package:vending_machine/app/models/product/product.dart';
import 'package:vending_machine/app/screens/size_config.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {

  List<Contact> _contacts = [];
  final databaseRef =
  FirebaseDatabase.instance.reference(); //database reference object
  void addData({required String name, required String contact,required String address,required String description, required String lat, required String lon}) {
    databaseRef
        .child("contacts")
        .push()
        .set({"name": name, "contact": contact,"address": address,"description": description, "lat": lat, "lon":lon});
  }
  void delete(String id) {
    databaseRef.child("contacts").child(id).remove();
  }

  @override
  void initState() {
    super.initState();
    databaseRef.child("contacts").onChildRemoved.listen((event) {
      setState(() {
        _contacts.removeWhere((element) => element.id==event.snapshot.key.toString());
      });
    });
    databaseRef.child("contacts").onChildAdded.listen((event) {
      Map<dynamic, dynamic> values = event.snapshot.value;
      print("Values" + values.toString());
      values["id"] = event.snapshot.key;
      Contact c = Contact.fromJson(values);
      setState(() {
        _contacts.add(c);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact"),
        backgroundColor: Colors.blue.withOpacity(0.5),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController _name = TextEditingController();
          TextEditingController _contact = TextEditingController();
          TextEditingController _address = TextEditingController();
          TextEditingController _lat = TextEditingController();
          TextEditingController _lon = TextEditingController();
          TextEditingController _description = TextEditingController();
          Alert(
              context: context,
              title: "Add contacts",
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      children: <Widget>[
                        TextField(
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: 'Name',
                          ),
                        ),TextField(
                          controller: _address,
                          decoration: InputDecoration(
                            labelText: 'Address',
                          ),
                        ),
                        TextField(
                          controller: _contact,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Contact',
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _lat,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Latitude',
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: TextField(
                                controller: _lon,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Longitude',
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _description,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                      ],
                    );
                  }),
              buttons: [
                DialogButton(
                  onPressed: () {
                    if (_name.value.text == "" ||
                        _address.value.text == "" ) {
                      print("error");
                    } else {
                        addData(name: _name.text, address: _address.text, description: _description.text,lat: _lat.text, lon: _lon.text, contact: _contact.text);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                DialogButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )
              ]).show();
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: FutureBuilder(

          future:
          FirebaseDatabase.instance.reference().child('contacts').get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {

            return Container(

              child:
              snapshot.connectionState == ConnectionState.waiting ? Center(child: CircularProgressIndicator()) :
              _contacts.length==0? Center(child: Text("No Data")) :
              ListView(
                shrinkWrap: true,
                children: [
                  ..._contacts.map((e) => Container(
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [

                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${e.name}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                        getProportionateScreenHeight(48)),
                                  ),
                                  Text(
                                    "${e.address}",
                                    style: TextStyle(
                                        fontSize:
                                        getProportionateScreenHeight(52)),
                                  ),Text(
                                    "${e.contact}",
                                    style: TextStyle(
                                        fontSize:
                                        getProportionateScreenHeight(32), color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: (){
                                        Alert(
                                            context: context,
                                            title: "Delete",
                                            content: Text("Are you sure you want to delete?"),
                                            buttons: [
                                              DialogButton(
                                                onPressed: () {
                                                  delete(e.id);
                                                  Navigator.pop(context);
                                                }, child: Text("Yes",
                                                style: TextStyle(color: Colors.white, fontSize: 20),),

                                              ),
                                              DialogButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                                ),
                                              )
                                            ]).show();
                                        // delete(e.id);
                                        },
                                        iconSize: getProportionateScreenHeight(100),
                                      color: Colors.red.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ); //just add value here
          },
        ),
      ),
    );
  }
}
