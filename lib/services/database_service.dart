// lib/services/database_service.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  // نام فایل دیتابیس
  static const String _dbName = 'shahid_soleimani_library.db';
  static const int _dbVersion = 1;

  // نام جداول
  static const String tableBooks = 'books';
  static const String tableProfile = 'user_profile';
  static const String tableDownloads = 'downloads';

  /// دریافت نمونه Singleton از دیتابیس
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// راه‌اندازی اولیه دیتابیس
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// ساخت جداول در اولین اجرا
  static Future<void> _onCreate(Database db, int version) async {
    // جدول کتاب‌ها
    await db.execute('''
      CREATE TABLE $tableBooks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        description TEXT,
        cover_url TEXT,
        pdf_url TEXT,
        audio_url TEXT,
        video_url TEXT,
        category TEXT,
        rating REAL DEFAULT 0.0,
        is_pdf_downloaded INTEGER DEFAULT 0,
        is_audio_downloaded INTEGER DEFAULT 0,
        local_pdf_path TEXT,
        local_audio_path TEXT,
        created_at TEXT
      )
    ''');

    // جدول پروفایل کاربر (فقط یک رکورد)
    await db.execute('''
      CREATE TABLE $tableProfile (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        dice_bear_seed TEXT,
        avatar_style TEXT DEFAULT 'adventurer',
        theme_color INTEGER DEFAULT 0xFF1B5E20,
        is_dark_mode INTEGER DEFAULT 0,
        favorite_book_ids TEXT DEFAULT '[]'
      )
    ''');

    // جدول دانلودها
    await db.execute('''
      CREATE TABLE $tableDownloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id TEXT NOT NULL,
        type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        downloaded_at TEXT
      )
    ''');
  }

  /// مدیریت نسخه‌های بعدی
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // در صورت تغییر ساختار دیتابیس، اینجا کد مهاجرت را بنویسید
    // مثال: if (oldVersion < 2) { await db.execute('ALTER TABLE ...'); }
  }

  /// بستن دیتابیس
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}