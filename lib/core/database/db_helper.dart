import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/models/user_model.dart';
import '../../data/models/book_model.dart';
import '../../data/models/rating_model.dart';
import '../../data/models/achievement_model.dart';

class DBHelper {
  static Database? _database;
  static const _dbName = 'shahid_library.db';
  static const _dbVersion = 2;

  // ==================== راه‌اندازی ====================
  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        national_code TEXT UNIQUE NOT NULL,
        avatar_seed TEXT,
        avatar_style TEXT,
        bio TEXT,
        theme_preference TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        author TEXT,
        description TEXT,
        cover_url TEXT,
        file_url TEXT,
        file_path TEXT,
        type TEXT NOT NULL,
        category TEXT,
        rating REAL DEFAULT 0,
        rating_count INTEGER DEFAULT 0,
        is_downloaded INTEGER DEFAULT 0,
        downloaded_at TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ratings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        user_name TEXT NOT NULL,
        rating REAL NOT NULL,
        comment TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE user_activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_id INTEGER,
        action TEXT NOT NULL,
        minutes_read INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 1,
        last_activity TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reading_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        current_page INTEGER DEFAULT 1,
        total_pages INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, book_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        page INTEGER NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        tier TEXT NOT NULL,
        requirement_type TEXT NOT NULL,
        requirement_value INTEGER NOT NULL,
        xp_reward INTEGER DEFAULT 0,
        unlocked_at TEXT,
        is_unlocked INTEGER DEFAULT 0,
        progress INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE user_stats (
        user_id INTEGER PRIMARY KEY,
        total_xp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        books_completed INTEGER DEFAULT 0,
        books_read INTEGER DEFAULT 0,
        total_minutes INTEGER DEFAULT 0,
        current_streak INTEGER DEFAULT 0,
        longest_streak INTEGER DEFAULT 0,
        last_active TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_books_type ON books (type)');
    await db.execute('CREATE INDEX idx_ratings_book ON ratings (book_id)');
    await db.execute('CREATE INDEX idx_progress_user ON reading_progress (user_id)');
  }

  static Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reading_progress (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          book_id INTEGER NOT NULL,
          current_page INTEGER DEFAULT 1,
          total_pages INTEGER DEFAULT 0,
          is_completed INTEGER DEFAULT 0,
          updated_at TEXT NOT NULL,
          UNIQUE(user_id, book_id)
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          book_id INTEGER NOT NULL,
          page INTEGER NOT NULL,
          note TEXT,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS achievements (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          icon TEXT NOT NULL,
          tier TEXT NOT NULL,
          requirement_type TEXT NOT NULL,
          requirement_value INTEGER NOT NULL,
          xp_reward INTEGER DEFAULT 0,
          unlocked_at TEXT,
          is_unlocked INTEGER DEFAULT 0,
          progress INTEGER DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_stats (
          user_id INTEGER PRIMARY KEY,
          total_xp INTEGER DEFAULT 0,
          level INTEGER DEFAULT 1,
          books_completed INTEGER DEFAULT 0,
          books_read INTEGER DEFAULT 0,
          total_minutes INTEGER DEFAULT 0,
          current_streak INTEGER DEFAULT 0,
          longest_streak INTEGER DEFAULT 0,
          last_active TEXT
        )
      ''');
    }
  }

  // ==================== کاربران ====================
  static Future<int> insertUser(UserModel user) async {
    final db = await database;
    final map = user.toMap()..['created_at'] = DateTime.now().toIso8601String();
    return db.insert('users', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<UserModel?> getUserByNationalCode(String code) async {
    final db = await database;
    final rows = await db.query('users',
        where: 'national_code = ?', whereArgs: [code], limit: 1);
    return rows.isEmpty ? null : UserModel.fromMap(rows.first);
  }

  static Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final rows =
        await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : UserModel.fromMap(rows.first);
  }

  static Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final rows = await db.query('users', orderBy: 'created_at DESC');
    return rows.map((e) => UserModel.fromMap(e)).toList();
  }

  static Future<int> updateUser(UserModel user) async {
    if (user.id == null) return 0;
    final db = await database;
    return db.update('users', user.toMap(),
        where: 'id = ?', whereArgs: [user.id]);
  }

  // ==================== کتاب‌ها ====================
  static Future<int> insertBook(BookModel book) async {
    final db = await database;
    final map = book.toMap()..['created_at'] = DateTime.now().toIso8601String();
    return db.insert('books', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<BookModel>> getAllBooks() async {
    final db = await database;
    final rows = await db.query('books', orderBy: 'title ASC');
    return rows.map((e) => BookModel.fromMap(e)).toList();
  }

  static Future<List<BookModel>> getBooksByType(String type) async {
    final db = await database;
    final rows = await db.query('books',
        where: 'type = ?', whereArgs: [type], orderBy: 'title ASC');
    return rows.map((e) => BookModel.fromMap(e)).toList();
  }

  static Future<BookModel?> getBookById(int id) async {
    final db = await database;
    final rows =
        await db.query('books', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : BookModel.fromMap(rows.first);
  }

  static Future<List<BookModel>> getDownloadedBooks() async {
    final db = await database;
    final rows = await db.query('books',
        where: 'is_downloaded = 1', orderBy: 'downloaded_at DESC');
    return rows.map((e) => BookModel.fromMap(e)).toList();
  }

  static Future<int> updateBook(BookModel book) async {
    if (book.id == null) return 0;
    final db = await database;
    return db.update('books', book.toMap(),
        where: 'id = ?', whereArgs: [book.id]);
  }

  // ==================== امتیازات ====================
  static Future<int> insertRating(RatingModel rating) async {
    final db = await database;
    return db.insert('ratings', rating.toMap());
  }

  static Future<void> updateBookRating(int bookId) async {
    final db = await database;
    final r = await db.rawQuery(
      'SELECT AVG(rating) as a, COUNT(*) as c FROM ratings WHERE book_id = ?',
      [bookId],
    );
    if (r.isNotEmpty) {
      final avg = (r.first['a'] as num?)?.toDouble() ?? 0;
      final count = (r.first['c'] as num?)?.toInt() ?? 0;
      await db.update('books', {'rating': avg, 'rating_count': count},
          where: 'id = ?', whereArgs: [bookId]);
    }
  }

  // ==================== پیشرفت مطالعه ====================
  static Future<void> saveReadingProgress({
    required int userId,
    required int bookId,
    required int page,
    required int totalPages,
    required bool isCompleted,
  }) async {
    final db = await database;
    await db.insert(
      'reading_progress',
      {
        'user_id': userId,
        'book_id': bookId,
        'current_page': page,
        'total_pages': totalPages,
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int?> getReadingProgress({
    required int userId,
    required int bookId,
  }) async {
    final full = await getReadingProgressFull(userId: userId, bookId: bookId);
    return full?['current_page'] as int?;
  }

  static Future<Map<String, dynamic>?> getReadingProgressFull({
    required int userId,
    required int bookId,
  }) async {
    final db = await database;
    final rows = await db.query('reading_progress',
        where: 'user_id = ? AND book_id = ?',
        whereArgs: [userId, bookId],
        limit: 1);
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first);
  }

  static Future<bool> isBookCompleted({
    required int userId,
    required int bookId,
  }) async {
    final p = await getReadingProgressFull(userId: userId, bookId: bookId);
    return p != null && p['is_completed'] == 1;
  }

  // ==================== نشانک‌ها ====================
  static Future<void> addBookmark({
    required int userId,
    required int bookId,
    required int page,
    String? note,
  }) async {
    final db = await database;
    await db.insert('bookmarks', {
      'user_id': userId,
      'book_id': bookId,
      'page': page,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getBookmarks({
    required int userId,
    required int bookId,
  }) async {
    final db = await database;
    return db.query('bookmarks',
        where: 'user_id = ? AND book_id = ?',
        whereArgs: [userId, bookId],
        orderBy: 'page ASC');
  }

  // ==================== فعالیت‌ها ====================
  static Future<int> recordActivity({
    required int userId,
    int? bookId,
    required String action,
    int minutes = 0,
  }) async {
    final db = await database;
    final now = DateTime.now();
    final todayStr = now.toIso8601String().substring(0, 10);

    final existing = await db.query('user_activities',
        where: "user_id = ? AND DATE(last_activity) = ?",
        whereArgs: [userId, todayStr],
        limit: 1);

    if (existing.isNotEmpty) {
      final cur = (existing.first['minutes_read'] as num?)?.toInt() ?? 0;
      return db.update(
        'user_activities',
        {
          'minutes_read': cur + minutes,
          'last_activity': now.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      final yest = now.subtract(const Duration(days: 1));
      final yStr = yest.toIso8601String().substring(0, 10);
      final yAct = await db.query('user_activities',
          where: "user_id = ? AND DATE(last_activity) = ?",
          whereArgs: [userId, yStr],
          limit: 1);

      int streak = 1;
      if (yAct.isNotEmpty) {
        streak = ((yAct.first['current_streak'] as num?)?.toInt() ?? 1) + 1;
      }

      return db.insert('user_activities', {
        'user_id': userId,
        'book_id': bookId,
        'action': action,
        'minutes_read': minutes,
        'current_streak': streak,
        'last_activity': now.toIso8601String(),
      });
    }
  }

  static Future<int> getCurrentStreak(int userId) async {
    final db = await database;
    final rows = await db.query('user_activities',
        where: 'user_id = ?', whereArgs: [userId],
        orderBy: 'last_activity DESC', limit: 1);
    return rows.isEmpty
        ? 0
        : (rows.first['current_streak'] as num?)?.toInt() ?? 0;
  }

  static Future<int> getTotalMinutes(int userId) async {
    final db = await database;
    final r = await db.rawQuery(
      'SELECT SUM(minutes_read) as total FROM user_activities WHERE user_id = ?',
      [userId],
    );
    return (r.first['total'] as num?)?.toInt() ?? 0;
  }

  // ==================== دستاوردها ====================
  static Future<List<AchievementModel>> getAchievements() async {
    final db = await database;
    final rows = await db.query('achievements');
    return rows.map((e) => AchievementModel.fromMap(e)).toList();
  }

  static Future<void> saveAchievement(AchievementModel a) async {
    final db = await database;
    await db.insert('achievements', a.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> unlockAchievement(String id) async {
    final db = await database;
    await db.update(
      'achievements',
      {
        'is_unlocked': 1,
        'unlocked_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== آمار کاربر ====================
  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    final db = await database;
    final rows = await db
        .query('user_stats', where: 'user_id = ?', whereArgs: [userId], limit: 1);
    if (rows.isEmpty) {
      await db.insert('user_stats', {'user_id': userId});
      return {
        'user_id': userId,
        'total_xp': 0,
        'level': 1,
        'books_completed': 0,
        'books_read': 0,
        'total_minutes': 0,
        'current_streak': 0,
        'longest_streak': 0,
      };
    }
    return Map<String, dynamic>.from(rows.first);
  }

  static Future<void> updateUserStats({
    required int userId,
    int? totalXp,
    int? level,
    int? booksCompleted,
    int? booksRead,
    int? totalMinutes,
    int? currentStreak,
    int? longestStreak,
  }) async {
    final db = await database;
    final stats = await getUserStats(userId);
    await db.insert(
      'user_stats',
      {
        'user_id': userId,
        'total_xp': totalXp ?? stats['total_xp'] ?? 0,
        'level': level ?? stats['level'] ?? 1,
        'books_completed': booksCompleted ?? stats['books_completed'] ?? 0,
        'books_read': booksRead ?? stats['books_read'] ?? 0,
        'total_minutes': totalMinutes ?? stats['total_minutes'] ?? 0,
        'current_streak': currentStreak ?? stats['current_streak'] ?? 0,
        'longest_streak': longestStreak ?? stats['longest_streak'] ?? 0,
        'last_active': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== پاک‌سازی ====================
  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('user_activities');
    await db.delete('ratings');
    await db.delete('reading_progress');
    await db.delete('bookmarks');
  }

  static Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}