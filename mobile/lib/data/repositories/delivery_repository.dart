import 'package:ciao_delivery/data/api_json.dart';
import 'package:ciao_delivery/data/models/delivery_models.dart';
import 'package:dio/dio.dart';

class DeliveryRepository {
  DeliveryRepository(this._dio);

  final Dio _dio;

  Future<DeliveryPartnerProfile> registerProfile({
    required String availableFrom,
    required String availableTo,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/delivery-partners/register',
      data: {
        'availableFrom': availableFrom,
        'availableTo': availableTo,
      },
    );
    return DeliveryPartnerProfile.fromJson(parseObject(res));
  }

  Future<DeliveryPartnerProfile> me() async {
    final res = await _dio.get<Map<String, dynamic>>('/delivery-partners/me');
    return DeliveryPartnerProfile.fromJson(parseObject(res));
  }

  Future<DeliveryPartnerProfile> updateAvailability({
    required String availableFrom,
    required String availableTo,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(
      '/delivery-partners/availability',
      data: {
        'availableFrom': availableFrom,
        'availableTo': availableTo,
      },
    );
    return DeliveryPartnerProfile.fromJson(parseObject(res));
  }

  Future<DeliveryPartnerProfile> toggleDuty() async {
    final res = await _dio.patch<Map<String, dynamic>>('/delivery-partners/duty');
    return DeliveryPartnerProfile.fromJson(parseObject(res));
  }

  Future<List<DeliveryPartnerProfile>> availablePartners() async {
    final res = await _dio.get<Map<String, dynamic>>('/delivery-partners/available');
    return parseList(res).map((e) => DeliveryPartnerProfile.fromJson(e as Map<String, dynamic>)).toList();
  }
}
