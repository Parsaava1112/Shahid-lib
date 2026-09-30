import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';
import '../models/user_profile.dart';

class LocalStorageService {
  static const String _booksBoxName = 'books';
  static const String _profileBoxName = 'user_profile';
  static const String _downloadsBoxName = 'downloads';

  // راه‌اندازی اولیه Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // ثبت Adapterها
    Hive.registerAdapter(BookAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    
    // باز کردن Boxها
    await Hive.openBox<Book>(_booksBoxName);
    await Hive.openBox<UserProfile>(_profileBoxName);
    await Hive.openBox(_downloadsBoxName);
  }

  // ذخیره کتاب‌ها
  static Future<void> saveBooks(List<Book> books) async {
    final box = Hive.box<Book>(_booksBoxName);
    await box.clear();
    for (final book in books) {
      await box.put(book.id, book);
    }
  }

  // دریافت کتاب‌های ذخیره شده
  static List<Book> getBooks() {
    final box = Hive.box<Book>(_booksBoxName);
    return box.values.toList();
  }

  // به‌روزرسانی یک کتاب
  static Future<void> updateBook(Book book) async {
    final box = Hive.box<Book>(_booksBoxName);
    await box.put(book.id, book);
  }

  // ذخیره اطلاعات پروفایل
  static Future<void> saveProfile(UserProfile profile) async {
    final box = Hive.box<UserProfile>(_profileBoxName);
    await box.put('current_user', profile);
  }

  // دریافت اطلاعات پروفایل
  static UserProfile? getProfile() {
    final box = Hive.box<UserProfile>(_profileBoxName);
    return box.get('current_user');
  }

  // ذخیره مسیر فایل دانلود شده
  static Future<void> saveDownloadPath(String bookId, String path, String type) async {
    final box = Hive.box(_downloadsBoxName);
    await box.put('${bookId}_$type', path);
  }

  // دریافت مسیر فایل دانلود شده
  static String? getDownloadPath(String bookId, String type) {
    final box = Hive.box(_downloadsBoxName);
    return box.get('${bookId}_$type') as String?;
  }
}