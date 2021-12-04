import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:vending_machine/app/models/product/product.dart';
import 'package:vending_machine/app/screens/size_config.dart';

class ServoScreen extends StatefulWidget {
  const ServoScreen({Key? key}) : super(key: key);

  @override
  _ServoScreenState createState() => _ServoScreenState();
}

class _ServoScreenState extends State<ServoScreen> {
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
    await databaseRef
        .child("products")
        .orderByChild("servo")
        .once()
        .then((event) {
      Map<dynamic, dynamic> values = event.value;
      values.keys.forEach((index) {
        values[index]["id"] = index;
        Product p = Product.fromJson(values[index]);
        _tmp.add(p);
      });
    });

    setState(() {
      _products = _tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_products.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text("Servo"),
        backgroundColor: Colors.blue.withOpacity(0.4),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20),
              itemCount: 10,
              itemBuilder: (BuildContext ctx, index) {
                Product? _active;
                try {
                  _active = _products.firstWhere((element) {
                    return int.parse(element.servo) == index + 1;
                  });
                  print("ACTIVE :: " + _active.name.toString());
                } catch (e) {}
                print(_active);
                return InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () => Alert(
                    context: context,
                    title: "SET SERVO",
                    content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        children: <Widget>[
                          ..._products.map((e) => Container(
                              width: double.infinity,
                              child: InkWell(
                                onTap: () {
                                  try {
                                    databaseRef
                                        .child("products")
                                        .child(_products
                                            .firstWhere((element) =>
                                                int.parse(element.servo) ==
                                                index + 1)
                                            .id)
                                        .update({"servo": -1});
                                  } catch (e) {
                                    print(e.toString());
                                  }

                                  databaseRef
                                      .child("products")
                                      .child(e.id)
                                      .update({"servo": index + 1}).then(
                                          (value) {
                                    refreshPage();
                                    Navigator.pop(context);
                                  });
                                },
                                child: Card(
                                    child: Text(
                                  e.name.toString(),
                                  style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(50)),
                                )),
                              )))
                        ],
                      );
                    }),
                  ).show(),
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _active != null
                                ? Image.network(
                                    _active.url,
                                    width: double.infinity,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(
                                    Icons.settings_backup_restore_sharp,
                                    size: 40,
                                  ),
                            _active != null
                                ? Text(_active.name.toString())
                                : Text("No Product"),
                            Text("Servo: " + (index + 1).toString()),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      if (_active != null)
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              databaseRef
                                  .child("products")
                                  .child(_products
                                      .firstWhere((element) =>
                                          int.parse(element.servo) == index + 1)
                                      .id)
                                  .update({"servo": -1}).then((value) => refreshPage());
                            },
                            child: Container(
                                padding: EdgeInsets.all(5),
                                child: Icon(Icons.delete)),
                          ),
                        )
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
