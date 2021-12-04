import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:vending_machine/app/models/product/advert.dart';
import 'package:vending_machine/app/screens/size_config.dart';

class Ads extends StatefulWidget {
  const Ads({Key? key}) : super(key: key);

  @override
  _AdsState createState() => _AdsState();
}

class _AdsState extends State<Ads> {
  
  int _current = 0;


  List<Advert> _adverts = [];
  final databaseRef =
  FirebaseDatabase.instance.reference(); //database reference object


  @override
  void initState() {
    super.initState();
    refreshPage();
  }
  refreshPage() async {
    List<Advert> _tmp = [];
    await databaseRef.child("adverts").once().then((event) {
      Map<dynamic, dynamic> values = event.value;
      values.keys.forEach((index) {
        values[index]["id"] = index;
        Advert p = Advert.fromJson(values[index]);
        _tmp.add(p);
      });

    });

    setState(() {
      _adverts = _tmp;
    });
  }
  List<String> images = [
    "https://img.lovepik.com/desgin_photo/45005/0368_detail.jpg",
    "https://cdn2.vectorstock.com/i/1000x1000/18/16/maternity-hospital-advertising-banner-vector-31271816.jpg",
    "https://mir-s3-cdn-cf.behance.net/project_modules/1400/b189ee95362655.5e95d603048e1.jpg"
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade700.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 4,
              offset: Offset(5, 0),
            ),
          ],
        ),
        child: CarouselSlider(
      options: CarouselOptions(
        autoPlayAnimationDuration: Duration(seconds: 2),
          autoPlayInterval: Duration(seconds: 10),
          viewportFraction: 1.0,
          enlargeCenterPage: false,
          height: getProportionateScreenHeight(140),
          aspectRatio: 2.0,
          autoPlay: true,
          onPageChanged: (index, reason) {
            setState(() {
              _current = index;
            });
          }),
      items: _adverts.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: NetworkImage(i.url),
                    fit: BoxFit.cover,
                  )),
            );
          },
        );
      }).toList(),
    ));
  }
}
