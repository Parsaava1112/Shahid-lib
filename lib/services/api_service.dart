import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/user_model.dart';
import '../data/models/book_model.dart';
import '../data/models/rating_model.dart';
import '../core/database/db_helper.dart';

/// سرویس ارتباط با بک‌اند Flask
/// تمام APIها با مدیریت خطا، timeout و retry پیاده‌سازی شده‌اند
class ApiService {
  // ==================== تنظیمات پایه ====================

  /// آدرس سرور - این را با IP سرور خود جایگزین کنید
  /// برای اندروید امولاتور: 10.0.2.2
  /// برای دستگاه واقعی: IP کامپیوتر شما (مثلاً 192.168.1.100)
  static String baseUrl = 'https://api.fanoosy.ir/api';

  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// توکن احراز هویت (اگر در آینده JWT اضافه شود)
  static String? _authToken;

  /// کاربر جاری ذخیره‌شده
  static UserModel? _currentUser;

  // ==================== مدیریت توکن و کاربر ====================

  /// ذخیره توکن احراز هویت
  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// بارگذاری توکن ذخیره‌شده
  static Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  /// پاک کردن توکن (خروج از حساب)
  static Future<void> clearAuthToken() async {
    _authToken = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
  }

  /// ذخیره کاربر جاری
  static Future<void> setCurrentUser(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toMap()));
  }

  /// دریافت کاربر جاری
  static Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('current_user');
    if (data != null) {
      _currentUser = UserModel.fromMap(jsonDecode(data));
      return _currentUser;
    }
    return null;
  }

  // ==================== هدرهای درخواست ====================

  static Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ==================== متدهای کمکی HTTP ====================

  /// درخواست GET با retry خودکار
  static Future<http.Response> _get(String endpoint) async {
    return _retryRequest(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('GET: $uri');
      return await http.get(uri, headers: _headers).timeout(_timeout);
    });
  }

  /// درخواست POST با retry خودکار
  static Future<http.Response> _post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _retryRequest(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('POST: $uri');
      debugPrint('Body: $body');
      return await http
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);
    });
  }

  /// درخواست PUT با retry خودکار
  static Future<http.Response> _put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    return _retryRequest(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      return await http
          .put(uri, headers: _headers, body: jsonEncode(body))
          .timeout(_timeout);
    });
  }

  /// درخواست DELETE
  static Future<http.Response> _delete(String endpoint) async {
    return _retryRequest(() async {
      final uri = Uri.parse('$baseUrl$endpoint');
      return await http.delete(uri, headers: _headers).timeout(_timeout);
    });
  }

  /// Retry خودکار در صورت خطای شبکه
  static Future<http.Response> _retryRequest(
    Future<http.Response> Function() request,
  ) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        final response = await request();
        // اگر خطای سرور 5xx بود، دوباره تلاش کن
        if (response.statusCode >= 500 && attempts < _maxRetries - 1) {
          attempts++;
          await Future.delayed(_retryDelay * attempts);
          continue;
        }
        return response;
      } on SocketException catch (e) {
        attempts++;
        debugPrint('SocketException (attempt $attempts): $e');
        if (attempts >= _maxRetries) rethrow;
        await Future.delayed(_retryDelay * attempts);
      } on TimeoutException catch (e) {
        attempts++;
        debugPrint('TimeoutException (attempt $attempts): $e');
        if (attempts >= _maxRetries) rethrow;
        await Future.delayed(_retryDelay * attempts);
      } catch (e) {
        rethrow;
      }
    }
    throw Exception('عدم پاسخگویی سرور پس از $_maxRetries تلاش');
  }

  /// بررسی و解析 پاسخ
  static dynamic _handleResponse(http.Response response) {
    debugPrint('Response [${response.statusCode}]: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      String errorMessage = 'خطای نامشخص';
      try {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        errorMessage = errorBody['error'] ??
            errorBody['message'] ??
            'خطای سرور (${response.statusCode})';
      } catch (_) {
        errorMessage = 'خطای سرور (${response.statusCode})';
      }
      throw ApiException(errorMessage, response.statusCode);
    }
  }

  // ==================== ۱. احراز هویت ====================

  /// ورود / ثبت‌نام با نام و کد ملی
  static Future<Map<String, dynamic>> login({
    required String name,
    required String nationalCode,
  }) async {
    try {
      final response = await _post('/login', {
        'name': name,
        'national_code': nationalCode,
      });
      final data = _handleResponse(response);

      final user = UserModel.fromMap(data['user']);
      await setCurrentUser(user);
      if (data['token'] != null) {
        await setAuthToken(data['token']);
      }
      return {
        'success': true,
        'user': user,
        'message': data['message'] ?? 'ورود موفق',
      };
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } on SocketException {
      return {
        'success': false,
        'error': 'اتصال به سرور برقرار نیست. حالت آفلاین فعال است.',
        'offline': true,
      };
    } catch (e) {
      return {'success': false, 'error': 'خطای غیرمنتظره: $e'};
    }
  }

  // ==================== ۲. کتاب‌ها ====================

  /// دریافت لیست کتاب‌ها از سرور
  static Future<List<BookModel>> fetchBooks({
    String? type,
    String? category,
  }) async {
    try {
      String endpoint = '/books';
      final params = <String>[];
      if (type != null) params.add('type=$type');
      if (category != null) params.add('category=$category');
      if (params.isNotEmpty) endpoint += '?${params.join('&')}';

      final response = await _get(endpoint);
      final data = _handleResponse(response) as List;
      return data.map((e) => BookModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('fetchBooks error: $e');
      // در صورت خطا، از دیتابیس محلی بخوان
      return await DBHelper.getAllBooks();
    }
  }

  /// دریافت جزئیات یک کتاب
  static Future<BookModel?> fetchBookDetail(int bookId) async {
    try {
      final response = await _get('/books/$bookId');
      final data = _handleResponse(response);
      return BookModel.fromMap(data);
    } catch (e) {
      debugPrint('fetchBookDetail error: $e');
      return null;
    }
  }

  /// دانلود فایل کتاب (PDF، صوت، ویدیو)
  /// فایل را در حافظه موقت ذخیره می‌کند و مسیر را برمی‌گرداند
  static Future<String?> downloadBookFile({
    required int bookId,
    required String fileUrl,
    required String fileName,
    Function(double progress)? onProgress,
  }) async {
    try {
      final uri = Uri.parse(
        fileUrl.startsWith('http') ? fileUrl : '$baseUrl$fileUrl',
      );
      debugPrint('Downloading: $uri');

      // ساخت مسیر ذخیره
      final directory = await _getDownloadDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);

      // اگر فایل قبلاً دانلود شده، برگردان
      if (await file.exists()) {
        debugPrint('File already exists: $filePath');
        return filePath;
      }

      // دانلود با streaming برای نمایش پیشرفت
      final request = http.Request('GET', uri);
      request.headers.addAll(_headers);
      final streamedResponse = await request.send().timeout(_timeout);

      if (streamedResponse.statusCode != 200) {
        throw ApiException(
          'خطا در دانلود فایل (${streamedResponse.statusCode})',
          streamedResponse.statusCode,
        );
      }

      final contentLength = streamedResponse.contentLength ?? 0;
      int downloaded = 0;

      final sink = file.openWrite();
      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        downloaded += chunk.length;
        if (contentLength > 0 && onProgress != null) {
          onProgress(downloaded / contentLength);
        }
      }
      await sink.flush();
      await sink.close();

      debugPrint('Download complete: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('downloadBookFile error: $e');
      return null;
    }
  }

  /// دریافت پوشه دانلود
  static Future<Directory> _getDownloadDirectory() async {
    // در اندروید از مسیر اپ استفاده می‌کنیم
    final directory = Directory(
      '${await _getAppDirectory()}/books',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  static Future<String> _getAppDirectory() async {
    // مسیر پیش‌فرض اپ در اندروید
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Android/data/com.example.shahid_suleimani_library/files';
    } else if (Platform.isIOS) {
      final dir = await Directory.systemTemp.createTemp();
      return dir.path;
    }
    return Directory.current.path;
  }

  // ==================== ۳. امتیازات و نظرات ====================

  /// ثبت امتیاز برای یک کتاب
  static Future<Map<String, dynamic>> submitRating({
    required int bookId,
    required String userName,
    required double rating,
    String? comment,
  }) async {
    try {
      final response = await _post('/ratings', {
        'book_id': bookId,
        'user_name': userName,
        'rating': rating,
        if (comment != null) 'comment': comment,
      });
      _handleResponse(response);
      return {'success': true, 'message': 'امتیاز ثبت شد'};
    } on ApiException catch (e) {
      // در حالت آفلاین، در صف همگام‌سازی ذخیره کن
      await _queueRating(bookId, userName, rating, comment);
      return {
        'success': false,
        'error': e.message,
        'queued': true,
      };
    } catch (e) {
      await _queueRating(bookId, userName, rating, comment);
      return {
        'success': false,
        'error': 'در صف آفلاین ذخیره شد',
        'queued': true,
      };
    }
  }

  /// ذخیره امتیاز در صف آفلاین
  static Future<void> _queueRating(
    int bookId,
    String userName,
    double rating,
    String? comment,
  ) async {
    final payload = jsonEncode({
      'book_id': bookId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
    });
    await DBHelper.addToSyncQueue('rating', payload);
  }

  /// دریافت امتیازات یک کتاب
  static Future<List<RatingModel>> fetchRatings(int bookId) async {
    try {
      final response = await _get('/ratings/$bookId');
      final data = _handleResponse(response) as List;
      return data.map((e) => RatingModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('fetchRatings error: $e');
      return await DBHelper.getRatingsForBook(bookId);
    }
  }

  // ==================== ۴. هوش مصنوعی (AI) ====================

  /// دریافت توصیه‌های کتاب از AI
  static Future<List<BookModel>> fetchRecommendations({
    required int userId,
    int limit = 5,
  }) async {
    try {
      final response = await _get(
        '/ai/recommendations/$userId?limit=$limit',
      );
      final data = _handleResponse(response) as List;
      return data.map((e) => BookModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('fetchRecommendations error: $e');
      // در حالت آفلاین، کتاب‌های با امتیاز بالا را برگردان
      final all = await DBHelper.getAllBooks();
      all.sort((a, b) => b.rating.compareTo(a.rating));
      return all.take(limit).toList();
    }
  }

  /// دریافت پیام انگیزشی از AI
  static Future<String> fetchMotivationalMessage(int userId) async {
    try {
      final response = await _get('/ai/message/$userId');
      final data = _handleResponse(response);
      return data['message'] ?? _getLocalMotivationalMessage();
    } catch (e) {
      debugPrint('fetchMotivationalMessage error: $e');
      return _getLocalMotivationalMessage();
    }
  }

  /// پیام انگیزشی محلی (در صورت عدم دسترسی به سرور)
  static String _getLocalMotivationalMessage() {
    final messages = [
      'امروز یه کتاب خوب بخون. حتی ۱۰ دقیقه.',
      'شهید سلیمانی می‌فرمود: «هرچه داریم از کتاب و مطالعه است.»',
      'کتاب بهترین دوستیه که هیچ‌وقت تنهات نمی‌ذاره.',
      'با هر صفحه‌ای که می‌خونی، یه پله بالاتر می‌ری.',
      'دانش سلاح امروزه. با کتاب مسلح شو.',
    ];
    messages.shuffle();
    return messages.first;
  }

  /// دریافت آمار کاربر از AI
  static Future<Map<String, dynamic>> fetchUserStats(int userId) async {
    try {
      final response = await _get('/ai/stats/$userId');
      final data = _handleResponse(response) as Map<String, dynamic>;
      return data;
    } catch (e) {
      debugPrint('fetchUserStats error: $e');
      return {
        'total_books_read': 0,
        'total_minutes_read': 0,
        'current_streak': 0,
        'badges': [],
      };
    }
  }

  /// ثبت فعالیت کاربر (برای محاسبه استریک)
  static Future<bool> recordActivity({
    required int userId,
    required int bookId,
    required String action,
    int minutes = 0,
  }) async {
    try {
      final response = await _post('/ai/activity', {
        'user_id': userId,
        'book_id': bookId,
        'action': action,
        'minutes': minutes,
      });
      _handleResponse(response);
      return true;
    } catch (e) {
      debugPrint('recordActivity error: $e');
      // در صف آفلاین ذخیره کن
      await DBHelper.addToSyncQueue(
        'activity',
        jsonEncode({
          'user_id': userId,
          'book_id': bookId,
          'action': action,
          'minutes': minutes,
        }),
      );
      return false;
    }
  }

  // ==================== ۵. جدول امتیازات ====================

  /// دریافت لیدربورد
  static Future<List<Map<String, dynamic>>> fetchLeaderboard({
    String period = 'weekly',
  }) async {
    try {
      final response = await _get('/leaderboard?period=$period');
      final data = _handleResponse(response) as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('fetchLeaderboard error: $e');
      return [];
    }
  }

  // ==================== ۶. حلقه‌های مطالعه ====================

  /// دریافت لیست حلقه‌های مطالعه
  static Future<List<Map<String, dynamic>>> fetchCircles() async {
    try {
      final response = await _get('/circles');
      final data = _handleResponse(response) as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('fetchCircles error: $e');
      return [];
    }
  }

  /// ایجاد حلقه مطالعه جدید
  static Future<Map<String, dynamic>> createCircle({
    required String name,
    required int userId,
    String? description,
    int? bookId,
  }) async {
    try {
      final response = await _post('/circles', {
        'name': name,
        'user_id': userId,
        if (description != null) 'description': description,
        if (bookId != null) 'book_id': bookId,
      });
      final data = _handleResponse(response);
      return {'success': true, 'data': data};
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'خطای غیرمنتظره: $e'};
    }
  }

  /// عضویت در حلقه مطالعه
  static Future<Map<String, dynamic>> joinCircle({
    required int circleId,
    required int userId,
  }) async {
    try {
      final response = await _post('/circles/$circleId/join', {
        'user_id': userId,
      });
      _handleResponse(response);
      return {'success': true, 'message': 'عضو شدید'};
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'خطای غیرمنتظره: $e'};
    }
  }

  // ==================== ۷. آپلود فایل (ادمین) ====================

  /// آپلود فایل کتاب (برای پنل ادمین)
  static Future<Map<String, dynamic>> uploadBookFile({
    required File file,
    required String type,
    required String title,
    String? author,
    String? description,
    String? category,
    Function(double progress)? onProgress,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/upload');
      final request = http.MultipartRequest('POST', uri);

      // اضافه کردن هدرها
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // فیلدهای فرم
      request.fields['type'] = type;
      request.fields['title'] = title;
      if (author != null) request.fields['author'] = author;
      if (description != null) request.fields['description'] = description;
      if (category != null) request.fields['category'] = category;

      // فایل
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      // ارسال با پیگیری پیشرفت
      final streamedResponse = await request.send().timeout(
            const Duration(minutes: 10),
          );

      // خواندن پاسخ
      final response = await http.Response.fromStream(streamedResponse);
      final data = _handleResponse(response);

      return {'success': true, 'data': data};
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'خطای آپلود: $e'};
    }
  }

  // ==================== ۸. همگام‌سازی آفلاین ====================

  /// همگام‌سازی تمام عملیات در صف
  static Future<Map<String, int>> syncPendingOperations() async {
    int successCount = 0;
    int failCount = 0;

    try {
      final queue = await DBHelper.getSyncQueue();
      debugPrint('Syncing ${queue.length} pending operations...');

      for (final item in queue) {
        try {
          final payload = jsonDecode(item['payload']);
          final operation = item['operation'];

          bool success = false;
          switch (operation) {
            case 'rating':
              final result = await submitRating(
                bookId: payload['book_id'],
                userName: payload['user_name'],
                rating: (payload['rating'] as num).toDouble(),
                comment: payload['comment'],
              );
              success = result['success'] == true;
              break;

            case 'activity':
              success = await recordActivity(
                userId: payload['user_id'],
                bookId: payload['book_id'],
                action: payload['action'],
                minutes: payload['minutes'] ?? 0,
              );
              break;

            default:
              debugPrint('Unknown operation: $operation');
              success = true; // نادیده بگیر
          }

          if (success) {
            await DBHelper.removeFromSyncQueue(item['id']);
            successCount++;
          } else {
            failCount++;
          }
        } catch (e) {
          debugPrint('Sync error for item ${item['id']}: $e');
          failCount++;
        }
      }
    } catch (e) {
      debugPrint('syncPendingOperations error: $e');
    }

    return {'success': successCount, 'failed': failCount};
  }

  // ==================== ۹. بررسی اتصال ====================

  /// بررسی در دسترس بودن سرور
  static Future<bool> isServerAvailable() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ==================== ۱۰. FCM Token ====================

  /// ثبت FCM Token برای دریافت اعلان‌ها
  static Future<bool> registerFcmToken({
    required int userId,
    required String token,
  }) async {
    try {
      final response = await _post('/users/$userId/fcm-token', {
        'fcm_token': token,
      });
      _handleResponse(response);
      return true;
    } catch (e) {
      debugPrint('registerFcmToken error: $e');
      return false;
    }
  }

  // ==================== ۱۱. بروزرسانی پروفایل ====================

  /// بروزرسانی اطلاعات کاربر
  static Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    String? name,
    String? bio,
    String? avatarSeed,
    String? avatarStyle,
    String? themePreference,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (bio != null) body['bio'] = bio;
      if (avatarSeed != null) body['avatar_seed'] = avatarSeed;
      if (avatarStyle != null) body['avatar_style'] = avatarStyle;
      if (themePreference != null) {
        body['theme_preference'] = themePreference;
      }

      final response = await _put('/users/$userId', body);
      final data = _handleResponse(response);

      // بروزرسانی در حافظه محلی
      if (data['user'] != null) {
        final updated = UserModel.fromMap(data['user']);
        await setCurrentUser(updated);
        await DBHelper.updateUser(updated);
      }

      return {'success': true, 'user': data['user']};
    } on ApiException catch (e) {
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': 'خطای غیرمنتظره: $e'};
    }
  }
}

// ==================== کلاس خطای سفارشی ====================

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}