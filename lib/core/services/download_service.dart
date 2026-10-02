import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../data/models/book_model.dart';
import '../database/db_helper.dart';

class DownloadService {
  static final DownloadService _i = DownloadService._();
  factory DownloadService() => _i;
  DownloadService._();

  final Map<int, double> _progress = {};
  final Map<int, bool> _downloading = {};

  double? progressFor(int bookId) => _progress[bookId];
  bool isDownloading(int bookId) => _downloading[bookId] == true;

  /// دانلود یک کتاب با نمایش پیشرفت
  Future<String?> download({
    required BookModel book,
    required String baseUrl,
    Function(double)? onProgress,
  }) async {
    if (book.id == null) return null;
    final bookId = book.id!;

    if (_downloading[bookId] == true) return null;
    _downloading[bookId] = true;
    _progress[bookId] = 0;
    onProgress?.call(0);

    try {
      // ساخت پوشه‌های ذخیره
      final appDir = await getApplicationDocumentsDirectory();
      final subFolder = _folderFor(book.type);
      final dir = Directory('${appDir.path}/library/$subFolder');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // نام فایل
      final ext = _extensionFor(book.type);
      final fileName = 'book_${book.id}_${_sanitize(book.title)}.$ext';
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);

      // اگر قبلاً دانلود شده، برگردان
      if (await file.exists()) {
        await _markDownloaded(book, filePath);
        _progress[bookId] = 1.0;
        onProgress?.call(1.0);
        _downloading[bookId] = false;
        return filePath;
      }

      // URL کامل
      final url = book.fileUrl.startsWith('http')
          ? book.fileUrl
          : '$baseUrl${book.fileUrl}';

      // دانلود با stream برای نمایش پیشرفت
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('خطای سرور: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      int received = 0;
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0) {
          final p = received / contentLength;
          _progress[bookId] = p;
          onProgress?.call(p);
        }
      }

      await sink.flush();
      await sink.close();

      // ثبت در دیتابیس
      await _markDownloaded(book, filePath);

      _progress[bookId] = 1.0;
      onProgress?.call(1.0);
      return filePath;
    } catch (e) {
      debugPrint('Download error: $e');
      _progress[bookId] = 0;
      _downloading[bookId] = false;
      return null;
    } finally {
      _downloading[bookId] = false;
    }
  }

  /// حذف فایل دانلودشده
  Future<bool> deleteDownload(BookModel book) async {
    if (book.id == null) return false;
    try {
      if (book.filePath.isNotEmpty) {
        final file = File(book.filePath);
        if (await file.exists()) await file.delete();
      }
      final db = await DBHelper.database;
      await db.update(
        'books',
        {
          'is_downloaded': 0,
          'file_path': '',
          'downloaded_at': null,
        },
        where: 'id = ?',
        whereArgs: [book.id],
      );
      return true;
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }

  Future<void> _markDownloaded(BookModel book, String path) async {
    final db = await DBHelper.database;
    await db.update(
      'books',
      {
        'is_downloaded': 1,
        'file_path': path,
        'downloaded_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  String _folderFor(String type) {
    switch (type) {
      case 'pdf':
        return 'books';
      case 'audio':
        return 'audio';
      case 'video':
        return 'video';
      default:
        return 'other';
    }
  }

  String _extensionFor(String type) {
    switch (type) {
      case 'pdf':
        return 'pdf';
      case 'audio':
        return 'mp3';
      case 'video':
        return 'mp4';
      default:
        return 'dat';
    }
  }

  String _sanitize(String name) {
    return name.replaceAll(RegExp(r'[^\w\u0600-\u06FF]'), '_');
  }
}