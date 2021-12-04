class Contact{
  Contact({
    required this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.lat,
    required this.lon,
    required this.description
  });
  String id;
  String address;
  String contact;
  String name;
  String lat;
  String lon;
  String description;
  factory Contact.fromJson(Map<dynamic, dynamic> json) => Contact(
    id: json["id"].toString(),
    name: json["name"].toString(),
    address: json["address"].toString(),
    contact: json["contact"].toString(),
    lat: json["lat"].toString(),
    lon: json["lon"].toString(),
    description: json["description"].toString(),
  );
}

