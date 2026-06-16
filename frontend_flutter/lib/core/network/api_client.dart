import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../error/failures.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio();
    _setupDio();
  }

  Dio get dio => _dio;

  void _setupDio() {
    final baseUrl = dotenv.get('BACKEND_URL', fallback: 'http://localhost:8000');
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
    ));
  }

  String _parseDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      if (data is Map) {
        final detail = data['detail'] ?? data['message'] ?? data['error'];
        if (detail != null) {
          return detail.toString();
        }
      }
      if (statusCode == 404) {
        return 'Không tìm thấy dữ liệu yêu cầu (404)';
      } else if (statusCode == 500) {
        return 'Lỗi hệ thống máy chủ (500)';
      } else if (statusCode != null) {
        return 'Yêu cầu không thành công (Mã lỗi: $statusCode)';
      }
    }
    
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Hết thời gian chờ kết nối máy chủ';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng';
    }
    
    return 'Lỗi kết nối mạng';
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ServerException(_parseDioError(e));
    } catch (e) {
      throw ServerException('Lỗi không xác định: $e');
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ServerException(_parseDioError(e));
    } catch (e) {
      throw ServerException('Lỗi không xác định: $e');
    }
  }
}

