// lib/services/local_storage.dart

import 'package:reaxdb_dart/reaxdb_dart.dart';
import '../models/book.dart';
import '../models/user_profile.dart';

class LocalStorageService {
  static late ReaxDB _db;

  // ─────────────────────────────────────────
  //  راه‌اندازی اولیه
  // ─────────────────────────────────────────

  static Future<void> init() async {
    _db = await ReaxDB.simple('shahid_soleimani_library');
  }

  // ─────────────────────────────────────────
  //  کتاب‌ها
  // ─────────────────────────────────────────

  /// ذخیره لیست کتاب‌ها (جایگزین `saveBooks`)
  static Future<void> saveBooks(List<Book> books) async {
    final Map<String, dynamic> data = {};
    for (final book in books) {
      data['book:${book.id}'] = book.toJson();
    }
    await _db.putAll(data);
  }

  /// دریافت همه کتاب‌ها (جایگزین `getBooks`)
  static List<Book> getBooks() {
    // ReaxDB به صورت همگام (sync) داده نمی‌دهد،
    // پس از این تابع باید به صورت async استفاده کنی.
    // این تابع برای سازگاری نگه داشته شده،
    // اما بهتر است از `getAllBooks()` استفاده کنی.
    return [];
  }

  /// دریافت همه کتاب‌ها به صورت async
  static Future<List<Book>> getAllBooks() async {
    final data = await _db.getAll('book:*');
    return data.values
        .map((json) => Book.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  /// دریافت یک کتاب
  static Future<Book?> getBook(String id) async {
    final data = await _db.get('book:$id');
    if (data == null) return null;
    return Book.fromJson(Map<String, dynamic>.from(data));
  }

  /// به‌روزرسانی یک کتاب (جایگزین `updateBook`)
  static Future<void> updateBook(Book book) async {
    await _db.put('book:${book.id}', book.toJson());
  }

  /// حذف یک کتاب
  static Future<void> deleteBook(String id) async {
    await _db.delete('book:$id');
  }

  // ─────────────────────────────────────────
  //  پروفایل کاربر
  // ─────────────────────────────────────────

  /// ذخیره اطلاعات پروفایل (جایگزین `saveProfile`)
  static Future<void> saveProfile(UserProfile profile) async {
    await _db.put('profile:current', profile.toJson());
  }

  /// دریافت اطلاعات پروفایل (جایگزین `getProfile`)
  static UserProfile? getProfile() {
    // مثل getBooks، این تابع sync نیست.
    // از `getProfileAsync()` استفاده کن.
    return null;
  }

  /// دریافت اطلاعات پروفایل به صورت async
  static Future<UserProfile?> getProfileAsync() async {
    final data = await _db.get('profile:current');
    if (data == null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(data));
  }

  // ─────────────────────────────────────────
  //  مسیر فایل‌های دانلود شده
  // ─────────────────────────────────────────

  /// ذخیره مسیر فایل دانلود شده (جایگزین `saveDownloadPath`)
  static Future<void> saveDownloadPath(
    String bookId,
    String path,
    String type,
  ) async {
    await _db.put('download:$bookId:$type', {
      'bookId': bookId,
      'path': path,
      'type': type,
    });
  }

  /// دریافت مسیر فایل دانلود شده (جایگزین `getDownloadPath`)
  static String? getDownloadPath(String bookId, String type) {
    // sync نیست، از نسخه async استفاده کن.
    return null;
  }

  /// دریافت مسیر فایل دانلود شده به صورت async
  static Future<String?> getDownloadPathAsync(
    String bookId,
    String type,
  ) async {
    final data = await _db.get('download:$bookId:$type');
    if (data == null) return null;
    return data['path'] as String?;
  }

  // ─────────────────────────────────────────
  //  گوش دادن به تغییرات (Real-time)
  // ─────────────────────────────────────────

  /// گوش دادن به تغییرات کتاب‌ها
  static Stream<void> watchBooks() {
    return _db.watch('book:*');
  }

  /// گوش دادن به تغییرات پروفایل
  static Stream<void> watchProfile() {
    return _db.watch('profile:*');
  }
}