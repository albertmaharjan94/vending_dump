class Advert{
  Advert({
    required this.id,
    required this.url,
  });
  String id;
  String url;
  factory Advert.fromJson(Map<dynamic, dynamic> json) => Advert(
    id: json["id"],
    url: json["url"],
  );
}

