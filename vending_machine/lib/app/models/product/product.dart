class Product{
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.url,
    required this.quantity,
    required this.servo
  });
  String id;
  String price;
  String name;
  String url;
  String quantity;
  String servo;
  factory Product.fromJson(Map<dynamic, dynamic> json) => Product(
    id: json["id"].toString(),
    name: json["name"].toString(),
    price: json["price"].toString(),
    quantity: json["quantity"].toString(),
    servo: json["servo"].toString(),
    url: json["url"].toString(),
  );
}

