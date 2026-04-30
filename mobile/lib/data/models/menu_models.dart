class MenuItem {
  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    required this.price,
    required this.available,
  });

  final int id;
  final int restaurantId;
  final String name;
  final String? description;
  final double price;
  final bool available;

  factory MenuItem.fromJson(Map<String, dynamic> j) {
    return MenuItem(
      id: (j['id'] as num).toInt(),
      restaurantId: (j['restaurantId'] as num).toInt(),
      name: j['name'] as String,
      description: j['description'] as String?,
      price: (j['price'] as num).toDouble(),
      available: j['available'] as bool? ?? true,
    );
  }
}
