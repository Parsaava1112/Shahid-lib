import 'package:dio/dio.dart';
import '../models/book.dart';

class ApiService {
  final Dio _dio;

  ApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://api.shahid-soleimani-library.ir/api',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ));

  // دریافت لیست کتاب‌ها
  Future<List<Book>> fetchBooks({String? category}) async {
    try {
      final response = await _dio.get('/books', queryParameters: {
        if (category != null) 'category': category,
      });
      return (response.data['books'] as List)
          .map((json) => Book.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('خطا در دریافت کتاب‌ها: ${e.message}');
    }
  }

  // دریافت کتاب‌های صوتی
  Future<List<Book>> fetchAudioBooks() async {
    try {
      final response = await _dio.get('/books/audio');
      return (response.data['books'] as List)
          .map((json) => Book.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('خطا در دریافت کتاب‌های صوتی: ${e.message}');
    }
  }

  // جستجوی کتاب
  Future<List<Book>> searchBooks(String query) async {
    try {
      final response = await _dio.get('/books/search', queryParameters: {
        'q': query,
      });
      return (response.data['books'] as List)
          .map((json) => Book.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('خطا در جستجو: ${e.message}');
    }
  }
}