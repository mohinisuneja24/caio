class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.location,
    required this.openTime,
    required this.closeTime,
    required this.open,
  });

  final int id;
  final String name;
  final String location;
  final String openTime;
  final String closeTime;
  final bool open;

  factory Restaurant.fromJson(Map<String, dynamic> j) {
    return Restaurant(
      id: (j['id'] as num).toInt(),
      name: j['name'] as String,
      location: j['location'] as String,
      openTime: j['openTime']?.toString() ?? '',
      closeTime: j['closeTime']?.toString() ?? '',
      open: j['open'] as bool? ?? false,
    );
  }
}

class RestaurantRequest {
  const RestaurantRequest({
    required this.name,
    required this.location,
    required this.openTime,
    required this.closeTime,
  });

  final String name;
  final String location;
  final String openTime;
  final String closeTime;

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': location,
        'openTime': openTime,
        'closeTime': closeTime,
      };
}
