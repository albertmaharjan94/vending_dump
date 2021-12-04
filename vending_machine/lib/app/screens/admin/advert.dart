import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:vending_machine/app/models/product/advert.dart';
import 'package:vending_machine/app/screens/size_config.dart';

class AdvertScreen extends StatefulWidget {
  const AdvertScreen({Key? key}) : super(key: key);

  @override
  _AdvertScreenState createState() => _AdvertScreenState();
}

class _AdvertScreenState extends State<AdvertScreen> {

  List<Advert> _adverts = [];
  final ImagePicker _picker = ImagePicker();
  final databaseRef =
  FirebaseDatabase.instance.reference(); //database reference object
  void addData({required String url}) {
    print("ADD " + url.toString());
    databaseRef
        .child("adverts")
        .push()
        .set({"url": url});
  }
  void delete(String id) {
    databaseRef.child("adverts").child(id).remove();
  }

  @override
  void initState() {
    super.initState();
    databaseRef.child("adverts").onChildRemoved.listen((event) {
      setState(() {
        _adverts.removeWhere((element) => element.id==event.snapshot.key.toString());
      });
    });
    databaseRef.child("adverts").onChildAdded.listen((event) {
      Map<dynamic, dynamic> values = event.snapshot.value;
      values["id"] = event.snapshot.key;
      Advert p = Advert.fromJson(values);
      setState(() {
        _adverts.add(p);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Advert"),
        backgroundColor: Colors.blue.withOpacity(0.5),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          XFile? _image = null;
          Alert(
              context: context,
              title: "Add Adverts",
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      children: <Widget>[

                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: _image == null
                              ? InkWell(
                              onTap: () async {
                                final XFile? selected = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                if (selected != null &&
                                    selected.path.isNotEmpty) {
                                  print(selected.toString());
                                  setState(() {
                                    _image = selected;
                                  });
                                }
                              },
                              child: Icon(
                                Icons.image_outlined,
                                size: 100,
                              ))
                              : InkWell(
                            onTap: () async {
                              final XFile? selected = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              if (selected != null &&
                                  selected.path.isNotEmpty) {
                                print(selected.toString());
                                setState(() {
                                  _image = selected;
                                });
                              }
                            },
                            child: Image.file(
                              File(_image!.path),
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
              buttons: [
                DialogButton(
                  onPressed: () {
                      FirebaseStorage storage = FirebaseStorage.instance;
                      Reference ref = storage
                          .ref()
                          .child("image1" + DateTime.now().toString());
                      UploadTask uploadTask = ref.putFile(File(_image!.path));
                      uploadTask.then((res) async {
                        String url = await res.ref.getDownloadURL();
                        print(url.toString());
                        addData(url: url);
                      });
                    setState(() {
                      _image = null;
                    });
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
          FirebaseDatabase.instance.reference().child('adverts').get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {

            return Container(

              child:
              snapshot.connectionState == ConnectionState.waiting ? Center(child: CircularProgressIndicator()) :
              _adverts.length==0? Center(child: Text("No Data")) :
              ListView(
                shrinkWrap: true,
                children: [
                  ..._adverts.map((e) => Container(
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 8,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Image.network(
                                    e.url,
                                    fit: BoxFit.cover,
                                    height: 150,
                                    width: double.infinity,
                                  ),
                                ),
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
