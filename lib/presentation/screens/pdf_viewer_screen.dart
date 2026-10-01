import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../data/models/book_model.dart';
import '../../core/database/db_helper.dart';

class PdfViewerScreen extends StatefulWidget {
  final BookModel book;

  const PdfViewerScreen({super.key, required this.book});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _controller = PdfViewerController();
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _recordActivity();
  }

  Future<void> _recordActivity() async {
    final user = await _getCurrentUser();
    if (user?.id != null && widget.book.id != null) {
      await DBHelper.recordActivity(
        userId: user!.id!,
        bookId: widget.book.id,
        action: 'read',
        minutes: 1,
      );
    }
  }

  Future<dynamic> _getCurrentUser() async {
    // اگر از ApiService استفاده می‌کنید:
    // return await ApiService.getCurrentUser();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: _showAppBar
          ? AppBar(
              title: Text(
                widget.book.title,
                style: GoogleFonts.vazirmatn(fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  tooltip: 'نشانک',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('نشانک اضافه شد'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'اشتراک‌گذاری',
                  onPressed: () {
                    // اشتراک‌گذاری
                  },
                ),
              ],
            )
          : null,
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          setState(() => _showAppBar = !_showAppBar);
        },
        child: Icon(_showAppBar ? Icons.fullscreen : Icons.fullscreen_exit),
      ),
    );
  }

  Widget _buildBody() {
    // اگر فایل وجود دارد
    if (widget.book.filePath.isNotEmpty) {
      final file = File(widget.book.filePath);
      if (file.existsSync()) {
        return PdfViewer.file(
          widget.book.filePath,
          controller: _controller,
        );
      }
    }

    // اگر URL دارد، از اینترنت بارگذاری کن
    if (widget.book.fileUrl.isNotEmpty) {
      return PdfViewer.uri(
        Uri.parse(widget.book.fileUrl),
        controller: _controller,
      );
    }

    // حالت خالی
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 100,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'این کتاب هنوز دانلود نشده است',
              style: GoogleFonts.vazirmatn(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'برای مطالعه، ابتدا کتاب را دانلود کنید.',
              style: GoogleFonts.vazirmatn(
                fontSize: 14,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _downloadBook,
              icon: const Icon(Icons.download),
              label: Text(
                'دانلود کتاب',
                style: GoogleFonts.vazirmatn(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadBook() async {
    // در اینجا منطق دانلود کتاب را پیاده‌سازی کنید
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('قابلیت دانلود در نسخه بعدی اضافه می‌شود'),
      ),
    );
  }
}