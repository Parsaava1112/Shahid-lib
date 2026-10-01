// lib/repositories/download_repository.dart

import '../services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class DownloadRepository {
  /// ذخیره مسیر فایل دانلود شده
  Future<void> saveDownloadPath(
    String bookId,
    String path,
    String type,
  ) async {
    final db = await DatabaseService.database;
    // ابتدا رکورد قبلی را حذف کن
    await db.delete(
      DatabaseService.tableDownloads,
      where: 'book_id = ? AND type = ?',
      whereArgs: [bookId, type],
    );
    // سپس رکورد جدید را درج کن
    await db.insert(DatabaseService.tableDownloads, {
      'book_id': bookId,
      'type': type,
      'file_path': path,
      'downloaded_at': DateTime.now().toIso8601String(),
    });
  }

  /// دریافت مسیر فایل دانلود شده
  Future<String?> getDownloadPath(String bookId, String type) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      DatabaseService.tableDownloads,
      where: 'book_id = ? AND type = ?',
      whereArgs: [bookId, type],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first['file_path'] as String?;
  }

  /// حذف رکورد دانلود
  Future<void> deleteDownload(String bookId, String type) async {
    final db = await DatabaseService.database;
    await db.delete(
      DatabaseService.tableDownloads,
      where: 'book_id = ? AND type = ?',
      whereArgs: [bookId, type],
    );
  }
}