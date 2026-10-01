// lib/repositories/book_repository.dart

import '../models/book.dart';
import '../services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class BookRepository {
  /// ذخیره لیست کتاب‌ها (جایگزین کامل جدول)
  Future<void> saveAllBooks(List<Book> books) async {
    final db = await DatabaseService.database;
    final batch = db.batch();

    // ابتدا جدول را خالی کن
    batch.delete(DatabaseService.tableBooks);

    // سپس همه کتاب‌ها را درج کن
    for (final book in books) {
      batch.insert(
        DatabaseService.tableBooks,
        book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// دریافت همه کتاب‌ها
  Future<List<Book>> getAllBooks() async {
    final db = await DatabaseService.database;
    final maps = await db.query(DatabaseService.tableBooks);
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  /// دریافت یک کتاب
  Future<Book?> getBookById(String id) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      DatabaseService.tableBooks,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Book.fromMap(maps.first);
  }

  /// جستجو در کتاب‌ها
  Future<List<Book>> searchBooks(String query) async {
    final db = await DatabaseService.database;
    final pattern = '%$query%';
    final maps = await db.query(
      DatabaseService.tableBooks,
      where: 'title LIKE ? OR author LIKE ? OR description LIKE ?',
      whereArgs: [pattern, pattern, pattern],
    );
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  /// به‌روزرسانی یک کتاب
  Future<void> updateBook(Book book) async {
    final db = await DatabaseService.database;
    await db.update(
      DatabaseService.tableBooks,
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  /// حذف یک کتاب
  Future<void> deleteBook(String id) async {
    final db = await DatabaseService.database;
    await db.delete(
      DatabaseService.tableBooks,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// دریافت کتاب‌های صوتی
  Future<List<Book>> getAudioBooks() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      DatabaseService.tableBooks,
      where: 'audio_url IS NOT NULL',
    );
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  /// شمارش کتاب‌ها
  Future<int> countBooks() async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseService.tableBooks}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}