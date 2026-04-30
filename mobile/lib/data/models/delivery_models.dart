class DeliveryPartnerProfile {
  const DeliveryPartnerProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.availableFrom,
    required this.availableTo,
    required this.onDuty,
    required this.availableNow,
  });

  final int id;
  final int userId;
  final String name;
  final String availableFrom;
  final String availableTo;
  final bool onDuty;
  final bool availableNow;

  factory DeliveryPartnerProfile.fromJson(Map<String, dynamic> j) {
    return DeliveryPartnerProfile(
      id: (j['id'] as num).toInt(),
      userId: (j['userId'] as num).toInt(),
      name: j['name'] as String? ?? '',
      availableFrom: j['availableFrom']?.toString() ?? '',
      availableTo: j['availableTo']?.toString() ?? '',
      onDuty: j['onDuty'] as bool? ?? false,
      availableNow: j['availableNow'] as bool? ?? false,
    );
  }
}
