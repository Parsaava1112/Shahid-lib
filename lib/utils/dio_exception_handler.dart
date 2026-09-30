import 'package:dio/dio.dart';

class DioExceptionHandler {
  static String handleException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return 'خطای اتصال: زمان اتصال به سرور به پایان رسید. لطفاً دوباره تلاش کنید.';
      case DioExceptionType.sendTimeout:
        return 'خطای ارسال: زمان ارسال درخواست به پایان رسید.';
      case DioExceptionType.receiveTimeout:
        return 'خطای دریافت: زمان دریافت پاسخ از سرور به پایان رسید.';
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final statusMessage = exception.response?.statusMessage ?? 'پیام نامشخص';
        return 'خطای سرور ($statusCode): $statusMessage';
      case DioExceptionType.cancel:
        return 'درخواست لغو شد.';
      case DioExceptionType.badCertificate:
        return 'خطای گواهی امنیتی. لطفاً اتصال خود را بررسی کنید.';
      case DioExceptionType.connectionError:
        return 'خطای اتصال: لطفاً اتصال اینترنت خود را بررسی کنید.';
      case DioExceptionType.unknown:
        return 'خطای ناشناخته رخ داد. لطفاً دوباره تلاش کنید.';
      default:
        return 'خطای ناشناخته رخ داد.';
    }
  }
}