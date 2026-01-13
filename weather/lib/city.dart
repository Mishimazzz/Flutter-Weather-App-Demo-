class City {
  final String name;
  final String country;
  final double lat;
  final double lon;

  City(
    {
      required this.name,
      required this.country,
      required this.lat,
      required this.lon,
    }
  );

  factory City.fromJson(Map<String,dynamic> j) => City(
    name: j['name'] ?? '', 
    country: j['country'] ?? '', 
    lat: (j['latitude'] as num).toDouble(),
    lon: (j['longitude'] as num).toDouble(),
  );

  @override
  String toString() => '$name, $country';
}