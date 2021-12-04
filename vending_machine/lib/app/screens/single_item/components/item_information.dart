import 'package:flutter/material.dart';
import 'package:vending_machine/app/models/product/product.dart';
import 'package:vending_machine/app/screens/size_config.dart';

class ItemInformation extends StatefulWidget {
  ItemInformation({Key? key, required this.product}) : super(key: key);
  Product product;
  @override
  _ItemInformationState createState() => _ItemInformationState();
}

class _ItemInformationState extends State<ItemInformation> {

  Map<String, String> _item= {"Sanitizer": "https://empire-s3-production.bobvila.com/articles/wp-content/uploads/2020/11/Best_Hand_Sanitizer.jpg"};
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: Image.network(widget.product.url.toString(), height: getProportionateScreenHeight(470), width: double.infinity, fit: BoxFit.cover,)),
            Container(
              padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.product.name.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: getProportionateScreenHeight(38), height: 0.8, fontWeight: FontWeight.w500),),
                  Text("Rs. ${widget.product.price}", style: TextStyle(fontSize: getProportionateScreenHeight(46), height: 1, fontWeight: FontWeight.bold),),
                  Text("${widget.product.quantity} left", style: TextStyle(color: Colors.black54, fontSize: getProportionateScreenHeight(30), height: 1, fontWeight: FontWeight.bold),),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
