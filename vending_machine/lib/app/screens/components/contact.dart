import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:vending_machine/app/models/product/contact.dart';
import 'package:vending_machine/app/screens/single_contact/single_contact.dart';
import 'package:vending_machine/app/screens/size_config.dart';

class ContactWidget extends StatefulWidget {
  const ContactWidget({Key? key}) : super(key: key);

  @override
  _ContactWidgetState createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget> {

  List<Contact> _contacts = [];
  final databaseRef =
  FirebaseDatabase.instance.reference(); //database reference object


  @override
  void initState() {
    super.initState();
    refreshPage();
  }
  refreshPage() async {
    List<Contact> _tmp = [];
    await databaseRef.child("contacts").once().then((event) {
      Map<dynamic, dynamic> values = event.value;
      values.keys.forEach((index) {
        values[index]["id"] = index;
        Contact p = Contact.fromJson(values[index]);
        _tmp.add(p);
      });

    });

    setState(() {
      _contacts = _tmp;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
            "Contacts",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: getProportionateScreenHeight(30)
            ),
            textAlign: TextAlign.left,
          )),
          SizedBox(height: getProportionateScreenHeight(10),),
          Expanded(
            child: RefreshIndicator(
              onRefresh: ()=>refreshPage(),
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...List.generate(
                    _contacts.length,
                    (index) => InkWell(
                      onTap:() => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SingleContact(id: _contacts[index].id.toString(),))),
                      child: Container(
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _contacts[index].name.toString(),
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: getProportionateScreenHeight(30),
                                            height: 1.2,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        _contacts[index].contact.toString(),
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: getProportionateScreenHeight(30),
                                            height: 1.2,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _contacts[index].address.toString(),
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: getProportionateScreenHeight(28),
                                            height: 1.2,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.phone,
                                  color: Colors.green,
                                  size: getProportionateScreenHeight(46),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
