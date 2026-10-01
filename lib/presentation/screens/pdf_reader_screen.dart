import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_viewer_pro/pdf_viewer_pro.dart';

class PdfReaderScreen extends StatelessWidget {
  final String filePath;
  final String title;
  final int bookId;

  const PdfReaderScreen({
    super.key,
    required this.filePath,
    required this.title,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    // اگر فایل وجود دارد
    if (File(filePath).existsSync()) {
      return PdfViewerScreen(
        filePath: filePath,
        title: title,
        bookId: bookId,
        serviceConfig: PdfViewerServiceConfig(
          authToken: 'your-jwt-token',
          isLoggedIn: true,
          onBookmarksSync: (bookId, bookmarks) async {
            // همگام‌سازی نشانک‌ها با سرور
            print('Syncing bookmarks for book $bookId: $bookmarks');
          },
          onMessage: (msg, type) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
          },
        ),
      );
    } else {
      // اگر فایل دانلود نشده، صفحه دانلود نمایش داده شود
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.download, size: 80),
              const SizedBox(height: 16),
              const Text('این کتاب هنوز دانلود نشده است'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // منطق دانلود فایل
                },
                child: const Text('دانلود کتاب'),
              ),
            ],
          ),
        ),
      );
    }
  }
}