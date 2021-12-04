import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vending_machine/app/models/product/product.dart';
import 'package:vending_machine/app/screens/single_item/components/item_information.dart';
import 'package:vending_machine/app/screens/size_config.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SingleItem extends StatefulWidget {
  SingleItem({Key? key, required this.title, required this.id}) : super(key: key);
  String title = "THIS IS TITLE";
  String id = "T";
  @override
  _SingleItemState createState() => _SingleItemState();
}

class _SingleItemState extends State<SingleItem> {
  Product? product;
  final databaseRef =
  FirebaseDatabase.instance.reference(); //database reference object
  bool showQR = true;

  String username = 'vendingmachine212@gmail.com';
  String password = 'Vending@212';


  @override
  void initState() {
    super.initState();
    refreshPage();


    databaseRef.child("products").onChildChanged.listen((event){
      if(event.snapshot.key == product!.id){
        event.snapshot.value["id"] = event.snapshot.key;
        try{
          setState(() {
            product = Product.fromJson(event.snapshot.value);
          });
        }catch(e){}

        quantityCheck(product!);
      }
    });
  }

  Future<void> quantityCheck(Product product) async {
    setState(() {
      if(int.parse(product.quantity) <1){
        showQR=false;
      }else{
        showQR=true;
      }
    });

    if(int.parse(product.quantity) <1) {
      final smtpServer = gmail(username, password);
      final message = Message()
        ..from = Address(username, 'Matrix')
        ..recipients.add(username)
        ..subject = 'Out of stock - ${product.name.toString()}'
        ..html = "<h1>Out of Stock</h1>\n<p>There has been an request for ${product
            .name
            .toString()}. Please refill the item.</p>\n<p>Thank you.</p><p><b>Vending Machine-Matrix</b></p>\n<p>${DateTime
            .now()}</p>";

      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString());
      } on MailerException catch (e) {
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      }
    }
  }
  refreshPage() async {
    Product? _tmp;

    await databaseRef.child("products").child(widget.id).once().then((event){
      event.value["id"] = event.key;
      _tmp = Product.fromJson(event.value);

      setState(() {
        product = _tmp;
      });
      quantityCheck(product!);
    });

  }

  @override
  Widget build(BuildContext context) {
    print(product.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product!=null ? product!.name.toString() : widget.title.toString(),
        ),
        backgroundColor: Colors.green.withOpacity(0.5),
        actions: [
      Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: IconButton(
        icon: Icon(Icons.refresh), onPressed: ()=>refreshPage(),
      )),
        ],
      ),
      body: product==null ?
          Center(child: CircularProgressIndicator(),)
      :
      Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ItemInformation(product: product!)),
            Expanded(
                child: Container(
                  padding: EdgeInsets.all(getProportionateScreenHeight(10)),
                  child: Card(
                    child: Center(
              child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            child: Text(
                          "VENDING MACHINE",
                          style:
                              TextStyle(fontSize: getProportionateScreenHeight(48), fontWeight: FontWeight.w400),
                        )),
                        Column(
                          children: [
                            Container(
                              child:
                              !showQR ?

                                  CachedNetworkImage(imageUrl: "https://i.dlpng.com/static/png/6770080_preview.png",
                                    height: getProportionateScreenHeight(260),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
                                  )
                              :
                              QrImage(
                                data: jsonEncode({
                                  "id": product!.id.toString(),
                                  "name": product!.name.toString(),
                                  "price": product!.price.toString(),
                                  "quantity": product!.quantity.toString(),
                                  "servo": product!.servo.toString(),
                                }),
                                version: QrVersions.auto,
                                size: getProportionateScreenHeight(280),
                              ),
                            ),
                          ],
                        ),
                        Container(
                            child: Text(
                          "What is it sharing?\nThe item tags, item price and verification.",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: getProportionateScreenHeight(38), fontWeight: FontWeight.w400, color: Colors.black.withOpacity(0.8)),
                        )),
                      ],
                    ),
              ),
            ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
