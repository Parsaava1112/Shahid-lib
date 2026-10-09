import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/models/book_model.dart';
import '../../data/models/rating_model.dart';

class DBHelper {
  static Database? _database;
  static const String _dbName = 'shahid_library.db';
  static const int _dbVersion = 3;

  // ==================== راه‌اندازی ====================

  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
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
        file_size INTEGER DEFAULT 0,
        type TEXT NOT NULL,
        category TEXT,
        language TEXT DEFAULT 'fa',
        level TEXT,
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
        created_at TEXT NOT NULL
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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        achievement_id TEXT NOT NULL,
        unlocked_at TEXT NOT NULL,
        UNIQUE(user_id, achievement_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute('CREATE INDEX idx_books_type ON books (type)');
    await db.execute('CREATE INDEX idx_books_language ON books (language)');
    await db.execute('CREATE INDEX idx_ratings_book ON ratings (book_id)');
    await db.execute(
        'CREATE INDEX idx_activities_user ON user_activities (user_id)');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      try {
        await db.execute(
            'ALTER TABLE books ADD COLUMN file_size INTEGER DEFAULT 0');
      } catch (_) {}
      try {
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
      } catch (_) {}
      try {
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
      } catch (_) {}
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS achievements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            achievement_id TEXT NOT NULL,
            unlocked_at TEXT NOT NULL,
            UNIQUE(user_id, achievement_id)
          )
        ''');
      } catch (_) {}
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS sync_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            operation TEXT NOT NULL,
            payload TEXT NOT NULL,
            created_at TEXT NOT NULL,
            retry_count INTEGER DEFAULT 0
          )
        ''');
      } catch (_) {}
    }

    if (oldVersion < 3) {
      try {
        await db.execute(
            "ALTER TABLE books ADD COLUMN language TEXT DEFAULT 'fa'");
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE books ADD COLUMN level TEXT');
      } catch (_) {}
      try {
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_books_language ON books (language)');
      } catch (_) {}
    }
  }

  // ==================== کاربران ====================

  static Future<int> insertUser(UserModel user) async {
    final db = await database;
    final map = user.toMap();
    map.remove('id');
    map['created_at'] = DateTime.now().toIso8601String();

    if (user.nationalCode.isNotEmpty) {
      final existing = await getUserByNationalCode(user.nationalCode);
      if (existing != null) {
        final updated = UserModel(
          id: existing.id,
          name: user.name,
          nationalCode: user.nationalCode,
          avatarSeed: user.avatarSeed ?? existing.avatarSeed,
          avatarStyle: user.avatarStyle ?? existing.avatarStyle,
          bio: user.bio ?? existing.bio,
          themePreference: user.themePreference ?? existing.themePreference,
        );
        await updateUser(updated);
        return existing.id ?? 0;
      }
    }

    return await db.insert('users', map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<UserModel?> getUserByNationalCode(String code) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'national_code = ?',
      whereArgs: [code],
      limit: 1,
    );
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  static Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) return UserModel.fromMap(maps.first);
    return null;
  }

  static Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users', orderBy: 'created_at DESC');
    return maps.map((e) => UserModel.fromMap(e)).toList();
  }

  static Future<int> updateUser(UserModel user) async {
    if (user.id == null) return 0;
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ==================== کتاب‌ها ====================

  static Future<int> insertBook(BookModel book) async {
    final db = await database;
    final map = book.toMap();
    map.remove('id');
    map['created_at'] = DateTime.now().toIso8601String();
    return await db.insert(
      'books',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertBooks(List<BookModel> books) async {
    final db = await database;
    final batch = db.batch();
    for (final book in books) {
      final map = book.toMap();
      map.remove('id');
      map['created_at'] = DateTime.now().toIso8601String();
      batch.insert(
        'books',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<BookModel>> getAllBooks() async {
    final db = await database;
    final maps = await db.query('books', orderBy: 'title ASC');
    return maps.map((e) => BookModel.fromMap(e)).toList();
  }

  static Future<List<BookModel>> getBooksByType(String type) async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'title ASC',
    );
    return maps.map((e) => BookModel.fromMap(e)).toList();
  }

  static Future<List<BookModel>> getDownloadedBooks() async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'is_downloaded = 1',
      orderBy: 'downloaded_at DESC',
    );
    return maps.map((e) => BookModel.fromMap(e)).toList();
  }

  static Future<BookModel?> getBookById(int id) async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) return BookModel.fromMap(maps.first);
    return null;
  }

  static Future<BookModel?> findBookByTitle(String title) async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'title = ?',
      whereArgs: [title],
      limit: 1,
    );
    if (maps.isNotEmpty) return BookModel.fromMap(maps.first);
    return null;
  }

  static Future<int> updateBook(BookModel book) async {
    if (book.id == null) return 0;
    final db = await database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  static Future<int> markBookAsDownloaded(
      int bookId, String filePath) async {
    final db = await database;
    return await db.update(
      'books',
      {
        'is_downloaded': 1,
        'file_path': filePath,
        'downloaded_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  static Future<int> deleteBook(int id) async {
    final db = await database;
    return await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteAllBooks() async {
    final db = await database;
    await db.delete('books');
  }

  // ==================== کتاب‌های انگلیسی ====================

  /// دریافت کتاب‌های انگلیسی (با فیلتر اختیاری سطح)
  static Future<List<BookModel>> getEnglishBooks({String? level}) async {
    final db = await database;
    final where = <String>['language = ?'];
    final args = <dynamic>['en'];

    if (level != null && level.isNotEmpty) {
      where.add('level = ?');
      args.add(level);
    }

    final maps = await db.query(
      'books',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'title ASC',
    );
    return maps.map((e) => BookModel.fromMap(e)).toList();
  }

  /// تعداد کتاب‌ها در هر سطح
  static Future<Map<String, int>> getEnglishLevelCounts() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT level, COUNT(*) as count FROM books "
      "WHERE language = 'en' AND level IS NOT NULL "
      "GROUP BY level",
    );
    final map = <String, int>{};
    for (final row in result) {
      map[row['level'] as String] = (row['count'] as num).toInt();
    }
    return map;
  }

  // ==================== امتیازات ====================

  static Future<int> insertRating(RatingModel rating) async {
    final db = await database;
    return await db.insert('ratings', rating.toMap());
  }

  static Future<List<RatingModel>> getRatingsForBook(int bookId) async {
    final db = await database;
    final maps = await db.query(
      'ratings',
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'created_at DESC',
    );
    return maps.map((e) => RatingModel.fromMap(e)).toList();
  }

  static Future<void> updateBookRating(int bookId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(rating) as avg_rating, COUNT(*) as count '
      'FROM ratings WHERE book_id = ?',
      [bookId],
    );
    if (result.isNotEmpty) {
      final avg = (result.first['avg_rating'] as num?)?.toDouble() ?? 0.0;
      final count = (result.first['count'] as num?)?.toInt() ?? 0;
      await db.update(
        'books',
        {'rating': avg, 'rating_count': count},
        where: 'id = ?',
        whereArgs: [bookId],
      );
    }
  }

  // ==================== فعالیت‌ها ====================

  static Future<int> recordActivity({
    required int userId,
    int? bookId,
    required String action,
    int minutes = 0,
  }) async {
    final db = await database;
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10);

    final existing = await db.query(
      'user_activities',
      where: 'user_id = ? AND DATE(last_activity) = ?',
      whereArgs: [userId, todayStr],
      orderBy: 'last_activity DESC',
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final currentMinutes =
          (existing.first['minutes_read'] as num?)?.toInt() ?? 0;
      return await db.update(
        'user_activities',
        {
          'minutes_read': currentMinutes + minutes,
          'last_activity': today.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr = yesterday.toIso8601String().substring(0, 10);
      final yesterdayActivity = await db.query(
        'user_activities',
        where: 'user_id = ? AND DATE(last_activity) = ?',
        whereArgs: [userId, yesterdayStr],
        orderBy: 'last_activity DESC',
        limit: 1,
      );

      int streak = 1;
      if (yesterdayActivity.isNotEmpty) {
        streak =
            ((yesterdayActivity.first['current_streak'] as num?)?.toInt() ??
                    1) +
                1;
      }

      return await db.insert('user_activities', {
        'user_id': userId,
        'book_id': bookId,
        'action': action,
        'minutes_read': minutes,
        'current_streak': streak,
        'last_activity': today.toIso8601String(),
      });
    }
  }

  // ==================== آمار کاربر ====================

  static Future<Map<String, dynamic>> getUserStats(int userId) async {
    final db = await database;

    final booksResult = await db.rawQuery(
      'SELECT COUNT(DISTINCT book_id) as count FROM user_activities '
      'WHERE user_id = ? AND action IN ("read", "complete")',
      [userId],
    );
    final booksRead = (booksResult.first['count'] as num?)?.toInt() ?? 0;

    final minutesResult = await db.rawQuery(
      'SELECT SUM(minutes_read) as total FROM user_activities '
      'WHERE user_id = ?',
      [userId],
    );
    final minutesRead =
        (minutesResult.first['total'] as num?)?.toInt() ?? 0;

    final streakResult = await db.query(
      'user_activities',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'last_activity DESC',
      limit: 1,
    );
    final streak = streakResult.isNotEmpty
        ? (streakResult.first['current_streak'] as num?)?.toInt() ?? 0
        : 0;

    final ratingsResult =
        await db.rawQuery('SELECT COUNT(*) as count FROM ratings');
    final ratingsCount =
        (ratingsResult.first['count'] as num?)?.toInt() ?? 0;

    final xp = (booksRead * 100) + (minutesRead ~/ 10) + (streak * 50);

    return {
      'total_books_read': booksRead,
      'total_minutes_read': minutesRead,
      'current_streak': streak,
      'total_ratings': ratingsCount,
      'xp': xp,
    };
  }

  // ==================== دستاوردها ====================

  static Future<List<String>> getUnlockedAchievements() async {
    final db = await database;
    try {
      final rows = await db.query('achievements');
      return rows.map((r) => r['achievement_id'] as String).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> unlockAchievement(
      int userId, String achievementId) async {
    final db = await database;
    try {
      await db.insert(
        'achievements',
        {
          'user_id': userId,
          'achievement_id': achievementId,
          'unlocked_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getAchievements() async {
    final db = await database;
    try {
      return await db.query('achievements');
    } catch (_) {
      return [];
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
    try {
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
    } catch (_) {}
  }

  static Future<int?> getReadingProgress({
    required int userId,
    required int bookId,
  }) async {
    final db = await database;
    try {
      final rows = await db.query(
        'reading_progress',
        where: 'user_id = ? AND book_id = ?',
        whereArgs: [userId, bookId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first['current_page'] as int?;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getReadingProgressFull({
    required int userId,
    required int bookId,
  }) async {
    final db = await database;
    try {
      final rows = await db.query(
        'reading_progress',
        where: 'user_id = ? AND book_id = ?',
        whereArgs: [userId, bookId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return Map<String, dynamic>.from(rows.first);
    } catch (_) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllReadingProgress(
      int userId) async {
    final db = await database;
    try {
      return await db.query(
        'reading_progress',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'updated_at DESC',
      );
    } catch (_) {
      return [];
    }
  }

  // ==================== نشانک‌ها ====================

  static Future<void> addBookmark({
    required int userId,
    required int bookId,
    required int page,
    String? note,
  }) async {
    final db = await database;
    try {
      await db.insert('bookmarks', {
        'user_id': userId,
        'book_id': bookId,
        'page': page,
        'note': note,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getBookmarks({
    required int userId,
    required int bookId,
  }) async {
    final db = await database;
    try {
      return await db.query(
        'bookmarks',
        where: 'user_id = ? AND book_id = ?',
        whereArgs: [userId, bookId],
        orderBy: 'page ASC',
      );
    } catch (_) {
      return [];
    }
  }

  // ==================== صف همگام‌سازی ====================

  static Future<int> addToSyncQueue(String operation, String payload) async {
    final db = await database;
    try {
      return await db.insert('sync_queue', {
        'operation': operation,
        'payload': payload,
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
      });
    } catch (_) {
      return -1;
    }
  }

  static Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    try {
      return await db.query('sync_queue', orderBy: 'created_at ASC');
    } catch (_) {
      return [];
    }
  }

  static Future<void> removeFromSyncQueue(int id) async {
    final db = await database;
    try {
      await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
    } catch (_) {}
  }

  static Future<void> incrementSyncRetry(int id) async {
    final db = await database;
    try {
      await db.rawUpdate(
        'UPDATE sync_queue SET retry_count = retry_count + 1 WHERE id = ?',
        [id],
      );
    } catch (_) {}
  }

  static Future<void> clearSyncQueue() async {
    final db = await database;
    try {
      await db.delete('sync_queue');
    } catch (_) {}
  }

  // ==================== آمار کلی ====================

  static Future<Map<String, dynamic>> getOverallStats() async {
    final db = await database;
    final books = await db.rawQuery('SELECT COUNT(*) as count FROM books');
    final downloaded = await db.rawQuery(
        'SELECT COUNT(*) as count FROM books WHERE is_downloaded = 1');
    final users = await db.rawQuery('SELECT COUNT(*) as count FROM users');

    return {
      'total_books': (books.first['count'] as num?)?.toInt() ?? 0,
      'downloaded_books': (downloaded.first['count'] as num?)?.toInt() ?? 0,
      'total_users': (users.first['count'] as num?)?.toInt() ?? 0,
    };
  }

  // ==================== پاک‌سازی ====================

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('user_activities');
    await db.delete('ratings');
    await db.delete('sync_queue');
    await db.delete('achievements');
    await db.delete('reading_progress');
    await db.delete('bookmarks');
  }

  static Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
    _database = null;
  }

  static Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}