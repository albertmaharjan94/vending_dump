import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vending_machine/app/models/product/product.dart';
import 'package:vending_machine/app/screens/single_item/single_item.dart';
import 'package:vending_machine/app/screens/size_config.dart';

class Item extends StatefulWidget {
  const Item({Key? key}) : super(key: key);

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  List<Product> _products = [];
  final databaseRef =
  FirebaseDatabase.instance.reference(); //database reference object

  @override
  void initState() {
    super.initState();

    refreshPage();
  }

  refreshPage() async {
    List<Product> _tmp = [];
    await databaseRef.child("products").orderByChild("servo").once().then((event) {
      Map<dynamic, dynamic> values = event.value;
      values.keys.forEach((index) {
        values[index]["id"] = index;
        Product p = Product.fromJson(values[index]);

        if(p.servo!="-1"){
          _tmp.add(p);
        }
      });

    });

    setState(() {
      _products = _tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: getProportionateScreenHeight(10)),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 5, color: Colors.black.withOpacity(0.2))
        )
      ),
      child: RefreshIndicator(
        onRefresh: ()=>refreshPage(),
        child: GridView.count(
          shrinkWrap: true,
            crossAxisCount: 3,
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 20.0,
            children: List.generate(_products.length, (index) {
              return Center(
                child: InkWell(
                  onTap:() => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SingleItem(title: _products[index].name.toString(), id: _products[index].id.toString()))),
                  child: Card(
                    elevation: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.network(_products[index].url.toString(), width: getProportionateScreenWidth(200), height: getProportionateScreenHeight(130), fit: BoxFit.cover,),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(5)),
                          child: Column(
                            children: [
                              Text(_products[index].name.toString(),  textAlign:TextAlign.center, style: TextStyle(fontSize: getProportionateScreenHeight(28), height: 1, fontWeight: FontWeight.w500),),
                              Text("Rs. ${_products[index].price.toString()}", textAlign: TextAlign.center, style: TextStyle(fontSize: getProportionateScreenHeight(32), height: 1, fontWeight: FontWeight.bold),),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            )
        ),
      ),
    );
  }
}
