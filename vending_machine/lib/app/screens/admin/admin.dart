import 'package:flutter/material.dart';
import 'package:vending_machine/app/screens/admin/advert.dart';
import 'package:vending_machine/app/screens/admin/contact.dart';
import 'package:vending_machine/app/screens/admin/product.dart';
import 'package:vending_machine/app/screens/admin/servo.dart';
import 'package:vending_machine/app/screens/size_config.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vending Admin"),
        backgroundColor: Colors.blue.withOpacity(0.5),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(child: Text("Control panel for vending machine", style: TextStyle(fontSize: getProportionateScreenHeight(60)),), ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProductScreen())),
                    child: Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.red.withOpacity(0.2),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: getProportionateScreenHeight(50)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: getProportionateScreenHeight(80),
                            ),
                            Text(
                              "Products",
                              style: TextStyle(
                                  fontSize: getProportionateScreenHeight(48)),
                            ),
                          ],
                        )),
                  ),
                )),
                Expanded(
                    child: Center(
                  child: InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ContactScreen())),
                    child: Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.green.withOpacity(0.2),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: getProportionateScreenHeight(50)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.smartphone_outlined,
                              size: getProportionateScreenHeight(80),
                            ),
                            Text(
                              "Contacts",
                              style: TextStyle(
                                  fontSize: getProportionateScreenHeight(48)),
                            ),
                          ],
                        )),
                  ),
                )),
                Expanded(
                    child: Center(
                  child: InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AdvertScreen())),
                    child: Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.brown.withOpacity(0.2),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: getProportionateScreenHeight(50)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mark_chat_read_outlined,
                              size: getProportionateScreenHeight(80),
                            ),
                            Text(
                              "Adverts",
                              style: TextStyle(
                                  fontSize: getProportionateScreenHeight(48)),
                            ),
                          ],
                        )),
                  ),
                )),Expanded(
                    child: Center(
                  child: InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ServoScreen())),
                    child: Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepPurple.withOpacity(0.2),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: getProportionateScreenHeight(50)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.settings_backup_restore_sharp,
                              size: getProportionateScreenHeight(80),
                            ),
                            Text(
                              "Servo",
                              style: TextStyle(
                                  fontSize: getProportionateScreenHeight(48)),
                            ),
                          ],
                        )),
                  ),
                )),
              ],
            ),
            Center(child: Text(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).year.toString(), style: TextStyle(fontSize: getProportionateScreenHeight(40)),), ),
          ],
        ),
      ),
    );
  }
}
