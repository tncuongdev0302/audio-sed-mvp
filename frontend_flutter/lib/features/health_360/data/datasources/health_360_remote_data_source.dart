import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/network/api_client.dart';

abstract class Health360RemoteDataSource {
  Future<String> submitUserIntake({
    required String name,
    required List<String> symptoms,
    required List<String> diseaseTags,
    required double lat,
    required double long,
    required String deviceToken,
  });

  Future<Map<String, dynamic>> getContextWeather(String userId);

  Future<Map<String, dynamic>> scanFood({
    required String userId,
    required Uint8List imageBytes,
  });

  Future<List<Map<String, String>>> getFoodOptions();

  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String productId,
    required String productName,
    required double lat,
    required double long,
  });

  Future<void> trackEvent({
    required String userId,
    required String eventType,
    required Map<String, dynamic> metadata,
  });

  Future<Map<String, dynamic>> getWeeklySummary(String userId);
}

class Health360RemoteDataSourceImpl implements Health360RemoteDataSource {
  final ApiClient client;

  Health360RemoteDataSourceImpl({required this.client});

  @override
  Future<String> submitUserIntake({
    required String name,
    required List<String> symptoms,
    required List<String> diseaseTags,
    required double lat,
    required double long,
    required String deviceToken,
  }) async {
    final response = await client.post(
      '/api/v1/user/intake',
      data: {
        'name': name,
        'disease_tags': diseaseTags,
        'symptoms': symptoms,
        'vitals': {},
        'lat': lat,
        'long': long,
        'device_token': deviceToken,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data['user_id'] as String;
    } else {
      throw Exception('Lỗi tạo hồ sơ lâm sàng');
    }
  }

  @override
  Future<Map<String, dynamic>> getContextWeather(String userId) async {
    final response = await client.get('/api/v1/context/$userId');
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Lỗi lấy dữ liệu thời tiết');
    }
  }

  @override
  Future<Map<String, dynamic>> scanFood({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    String subtype = 'png';
    if (imageBytes.length > 3 &&
        imageBytes[0] == 0xFF &&
        imageBytes[1] == 0xD8 &&
        imageBytes[2] == 0xFF) {
      subtype = 'jpeg';
    }

    print('=== [DEBUG UPLOAD IMAGE] ===');
    print('Kích thước ảnh gửi đi: ${imageBytes.length} bytes');
    print('Định dạng xác định: $subtype');
    print('Tên tệp tin gửi lên: food_scan.${subtype == 'jpeg' ? 'jpg' : 'png'}');
    print('MediaType: image/$subtype');
    print('============================');

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        imageBytes,
        filename: 'food_scan.${subtype == 'jpeg' ? 'jpg' : 'png'}',
        contentType: MediaType('image', subtype),
      ),
    });

    final response = await client.post(
      '/api/food-scan?user_id=$userId',
      data: formData,
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Lỗi phân tích thực phẩm');
    }
  }

  @override
  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String productId,
    required String productName,
    required double lat,
    required double long,
  }) async {
    final response = await client.post(
      '/api/v1/order/create',
      data: {
        'user_id': userId,
        'product_id': productId,
        'product_name': productName,
        'quantity': 1,
        'delivery_lat': lat,
        'delivery_long': long,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Lỗi tạo đơn hàng đổi thưởng');
    }
  }

  @override
  Future<void> trackEvent({
    required String userId,
    required String eventType,
    required Map<String, dynamic> metadata,
  }) async {
    await client.post(
      '/api/v1/analytics/event',
      data: {
        'event_type': eventType,
        'user_id': userId,
        'metadata': metadata,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getWeeklySummary(String userId) async {
    final response = await client.get('/api/v1/analytics/summary/$userId');
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Lỗi lấy tổng kết tuần');
    }
  }

  @override
  Future<List<Map<String, String>>> getFoodOptions() async {
    final response = await client.get('/api/v1/food/options');
    if (response.statusCode == 200) {
      final List<dynamic> optionsJson = response.data['options'];
      return optionsJson.map((json) {
        final map = json as Map<String, dynamic>;
        return {
          'key': map['key'].toString(),
          'name': map['name'].toString(),
        };
      }).toList();
    } else {
      throw Exception('Lỗi lấy danh sách món ăn');
    }
  }
}
