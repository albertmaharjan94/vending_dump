import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vending_machine/app/models/product/contact.dart';

import '../size_config.dart';

class SingleContact extends StatefulWidget {
  SingleContact({Key? key, required this.id}) : super(key: key);
  String id;
  @override
  _SingleContactState createState() => _SingleContactState();
}

class _SingleContactState extends State<SingleContact> {

  Completer<GoogleMapController> _controller = Completer();
  List<Marker> _markers = <Marker>[];

  static CameraPosition? _initLocation;

  Contact? contact;
  final databaseRef =
  FirebaseDatabase.instance.reference(); //database reference object


  @override
  void initState() {
    super.initState();
    refreshPage();

    databaseRef.child("contacts").onChildChanged.listen((event){
      if(event.snapshot.key == contact!.id){
        event.snapshot.value["id"] = event.snapshot.key;
        setState(() {
          contact = Contact.fromJson(event.snapshot.value);
        });
      }
    });
  }

  refreshPage() async {
    Contact? _tmp;

    await databaseRef.child("contacts").child(widget.id).once().then((event){
      event.value["id"] = event.key;
      _tmp = Contact.fromJson(event.value);

      setState(() {
        contact = _tmp;
      });
    });

  }
  LatLng? _loc;
  @override
  Widget build(BuildContext context) {
    if(contact!=null){
      LatLng _loc = LatLng(double.parse(contact!.lat), double.parse(contact!.lon));
      setState(() {
        _initLocation = CameraPosition(
            target: _loc,
            zoom: 15
        );
        _markers.add(
            Marker(
                markerId: MarkerId('SomeId'),
                position: _loc,
                infoWindow: InfoWindow(
                  title: contact?.name.toString(),
                )
            ));
      });
    }


    return new Scaffold(
      appBar: AppBar(
        title: Text(contact == null ? "Loading" : contact!.name.toString()),
        backgroundColor: Colors.green.withOpacity(0.5),
      ),
      body:
      contact==null ? Center(child: CircularProgressIndicator(),):
      Row(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              mapType: MapType.normal,
              markers: Set<Marker>.of(_markers),
              initialCameraPosition: _initLocation!,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Expanded(
            flex: 1,
              child: Container(
                margin: EdgeInsets.all(10),
                  child: Card(child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: RefreshIndicator(
                      onRefresh: ()=>Future.value(),
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                children: [
                      Text(contact!.name, style: TextStyle(fontSize: getProportionateScreenHeight(48), fontWeight: FontWeight.w600),),
                      Text(contact!.contact, style: TextStyle(fontSize: getProportionateScreenHeight(46), fontWeight: FontWeight.w500),),
                      Text(contact!.address, style: TextStyle(fontSize: getProportionateScreenHeight(38), fontWeight: FontWeight.w500, color: Colors.black54),),
                      Text(contact!.description),
                ],
              ),
                    ),
                  ))))
        ],
      ),
    );
  }

}
