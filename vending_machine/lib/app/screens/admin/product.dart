import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:vending_machine/app/models/product/product.dart';
import 'package:vending_machine/app/screens/size_config.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {

  List<Product> _products = [];
  final ImagePicker _picker = ImagePicker();
  final databaseRef =
      FirebaseDatabase.instance.reference(); //database reference object
  void addData({required String name, required String price,required String quantity, required String url, int servo=-1}) {
    databaseRef
        .child("products")
        .push()
        .set({"name": name, "price": price,"quantity": quantity, "url": url, "servo":servo});
  }
  void delete(String id) {
    databaseRef.child("products").child(id).remove();
  }

  Future<void> updateStock(String id, String qty, int idx) async {
    await databaseRef.child("products").child(id).update({ "quantity": qty}).then((v){
      setState((){
        _products[idx].quantity = qty;
      });
    });

  }

  @override
  void initState() {
    super.initState();
    databaseRef.child("products").onChildRemoved.listen((event) {
      setState(() {
        _products.removeWhere((element) => element.id==event.snapshot.key.toString());
      });
    });
    databaseRef.child("products").onChildAdded.listen((event) {
      Map<dynamic, dynamic> values = event.snapshot.value;
      print("Values" + values.toString());
      values["id"] = event.snapshot.key;
      Product p = Product.fromJson(values);
      setState(() {
        _products.add(p);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product"),
        backgroundColor: Colors.blue.withOpacity(0.5),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController _name = TextEditingController();
          TextEditingController _price = TextEditingController();
          TextEditingController _quantity = TextEditingController();
          XFile? _image = null;
          Alert(
              context: context,
              title: "Add Products",
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: <Widget>[
                    TextField(
                      controller: _name,
                      decoration: InputDecoration(
                        labelText: 'Name',
                      ),
                    ),
                    TextField(
                      controller: _price,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                    ),
                    TextField(
                      controller: _quantity,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                      ),
                    ),
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
                    if (_name.value.text == "" ||
                        _price.value.text == "" ||
                        _image == null) {
                      print("error");
                    } else {
                      print(_image?.path.toString());
                      FirebaseStorage storage = FirebaseStorage.instance;
                      Reference ref = storage
                          .ref()
                          .child("image1" + DateTime.now().toString());
                      UploadTask uploadTask = ref.putFile(File(_image!.path));
                      uploadTask.then((res) async {
                        String url = await res.ref.getDownloadURL();
                        addData(name: _name.text, price: _price.text, quantity: _quantity.text,url: url);
                      });
                    }
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
              FirebaseDatabase.instance.reference().child('products').get(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {

            return Container(

              child:
                  snapshot.connectionState == ConnectionState.waiting ? Center(child: CircularProgressIndicator()) :
              _products.length==0? Center(child: Text("No Data")) :
              ListView(
                shrinkWrap: true,
                children: [
                  ..._products.map((e) => Container(
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Image.network(
                                        e.url,
                                        height: 150,
                                        width: 150,
                                      ),
                                    ),
                                  ),
                                ),
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
                                        "NPR. ${e.price}",
                                        style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(52)),
                                      ),Text(
                                        "${e.quantity} (pcs)",
                                        style: TextStyle(
                                            fontSize:
                                                getProportionateScreenHeight(32), color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: (){
                                    updateStock(e.id, (int.parse(e.quantity)+1).toString(),_products.indexOf(e));
                                  },
                                  iconSize: getProportionateScreenHeight(100),
                                  color: Colors.green.withOpacity(0.5),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: (){
                                    updateStock(e.id, (int.parse(e.quantity)-1).toString(), _products.indexOf(e));
                                  },
                                  iconSize: getProportionateScreenHeight(100),
                                  color: Colors.pink.withOpacity(0.5),
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
