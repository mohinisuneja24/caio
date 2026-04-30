enum OrderStatus {
  placed('PLACED'),
  accepted('ACCEPTED'),
  outForDelivery('OUT_FOR_DELIVERY'),
  delivered('DELIVERED'),
  cancelled('CANCELLED');

  const OrderStatus(this.api);
  final String api;

  static OrderStatus? fromApi(String? raw) {
    if (raw == null) return null;
    for (final e in OrderStatus.values) {
      if (e.api == raw) return e;
    }
    return null;
  }
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.status,
    required this.totalAmount,
    this.deliveryPartnerName,
    required this.itemNames,
    this.deliveryAddress,
  });

  final int id;
  final int restaurantId;
  final String restaurantName;
  final OrderStatus? status;
  final double totalAmount;
  final String? deliveryPartnerName;
  final List<String> itemNames;
  final String? deliveryAddress;

  factory OrderSummary.fromJson(Map<String, dynamic> j) {
    final items = (j['itemNames'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    return OrderSummary(
      id: (j['id'] as num).toInt(),
      restaurantId: (j['restaurantId'] as num).toInt(),
      restaurantName: j['restaurantName'] as String? ?? '',
      status: OrderStatus.fromApi(j['status'] as String?),
      totalAmount: (j['totalAmount'] as num?)?.toDouble() ?? 0,
      deliveryPartnerName: j['deliveryPartnerName'] as String?,
      itemNames: items,
      deliveryAddress: j['deliveryAddress'] as String?,
    );
  }
}
