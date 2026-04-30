enum AppRole {
  user,
  restaurant,
  delivery;

  static AppRole? fromApi(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'USER':
        return AppRole.user;
      case 'RESTAURANT':
        return AppRole.restaurant;
      case 'DELIVERY':
        return AppRole.delivery;
      default:
        return null;
    }
  }

  String get apiValue => name.toUpperCase();
}
