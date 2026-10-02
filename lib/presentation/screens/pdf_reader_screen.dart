import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../data/models/book_model.dart';
import '../../core/database/db_helper.dart';
import '../../services/api_service.dart';

class PdfReaderScreen extends StatefulWidget {
  final BookModel book;
  const PdfReaderScreen({super.key, required this.book});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final _pdfCtrl = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  bool _uiVisible = true;

  // رنگ‌های کاغذی
  static const _paperColor = Color(0xFFF5EBDC);
  static const _paperColorDark = Color(0xFF3A332A);
  static const _inkColor = Color(0xFF2A1E14);

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = await ApiService.getCurrentUser();
    if (user?.id != null && widget.book.id != null) {
      final saved = await DBHelper.getReadingProgress(
        userId: user!.id!,
        bookId: widget.book.id!,
      );
      if (saved != null && saved > 1 && mounted) {
        setState(() => _currentPage = saved);
      }
    }
  }

  Future<void> _saveProgress() async {
    final user = await ApiService.getCurrentUser();
    if (user?.id == null || widget.book.id == null) return;

    final isCompleted = _totalPages > 0 && _currentPage >= _totalPages - 1;
    await DBHelper.saveReadingProgress(
      userId: user!.id!,
      bookId: widget.book.id!,
      page: _currentPage,
      totalPages: _totalPages,
      isCompleted: isCompleted,
    );

    // ثبت فعالیت
    await DBHelper.recordActivity(
      userId: user.id!,
      bookId: widget.book.id,
      action: isCompleted ? 'complete' : 'read',
      minutes: 1,
    );
  }

  @override
  void dispose() {
    _saveProgress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _paperColorDark : _paperColor;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          _buildViewer(),
          if (_uiVisible) _buildTopBar(isDark),
          if (_uiVisible) _buildBottomBar(isDark),
        ],
      ),
    );
  }

  Widget _buildViewer() {
    if (widget.book.filePath.isNotEmpty) {
      final f = File(widget.book.filePath);
      if (f.existsSync()) {
        return PdfViewer.file(
          widget.book.filePath,
          controller: _pdfCtrl,
          params: PdfViewerParams(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? _paperColorDark
                : _paperColor,
            margin: 20,
            maxScale: 5,
            minScale: 1,
            panAxis: PanAxis.free,
            onViewerReady: (_, __) {
              setState(() {
                _totalPages = _pdfCtrl.pageCount ?? 0;
                _isLoading = false;
              });
              if (_currentPage > 1) {
                _pdfCtrl.goToPage(pageNumber: _currentPage);
              }
            },
            onPageChanged: (page) {
              setState(() => _currentPage = page ?? 1);
              _saveProgress();
            },
          ),
        );
      }
    }

    if (widget.book.fileUrl.isNotEmpty) {
      return PdfViewer.uri(
        Uri.parse(widget.book.fileUrl),
        controller: _pdfCtrl,
        params: PdfViewerParams(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? _paperColorDark
              : _paperColor,
          margin: 20,
          onViewerReady: (_, __) {
            setState(() {
              _totalPages = _pdfCtrl.pageCount ?? 0;
              _isLoading = false;
            });
          },
          onPageChanged: (page) {
            setState(() => _currentPage = page ?? 1);
            _saveProgress();
          },
        ),
      );
    }

    return _buildNoFile();
  }

  Widget _buildTopBar(bool isDark) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: _uiVisible ? Offset.zero : const Offset(0, -1),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? _paperColorDark : _paperColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    color: _inkColor,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.book.title,
                      style: GoogleFonts.vazirmatn(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _inkColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_add_outlined),
                    color: _inkColor,
                    onPressed: _addBookmark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        offset: _uiVisible ? Offset.zero : const Offset(0, 1),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? _paperColorDark : _paperColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // نوار پیشرفت
                  if (_totalPages > 0)
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _inkColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerRight,
                        widthFactor: _currentPage / _totalPages,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _inkColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _iconBtn(
                        Icons.first_page_rounded,
                        () => _pdfCtrl.goToPage(pageNumber: 1),
                      ),
                      _iconBtn(
                        Icons.chevron_right_rounded,
                        () => _pdfCtrl.goToPage(
                            pageNumber: (_currentPage - 1).clamp(1, _totalPages)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: _inkColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _totalPages > 0
                              ? 'صفحه $_currentPage از $_totalPages'
                              : 'در حال بارگذاری...',
                          style: GoogleFonts.vazirmatn(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _inkColor,
                          ),
                        ),
                      ),
                      _iconBtn(
                        Icons.chevron_left_rounded,
                        () => _pdfCtrl.goToPage(
                            pageNumber: (_currentPage + 1).clamp(1, _totalPages)),
                      ),
                      _iconBtn(
                        Icons.last_page_rounded,
                        () => _pdfCtrl.goToPage(pageNumber: _totalPages),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: _inkColor, size: 26),
        ),
      ),
    );
  }

  Widget _buildNoFile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 100,
              color: _inkColor.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'این کتاب هنوز دانلود نشده است',
              style: GoogleFonts.vazirmatn(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _inkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addBookmark() async {
    final user = await ApiService.getCurrentUser();
    if (user?.id == null || widget.book.id == null) return;
    await DBHelper.addBookmark(
      userId: user!.id!,
      bookId: widget.book.id!,
      page: _currentPage,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'صفحه $_currentPage نشان‌گذاری شد',
            style: GoogleFonts.vazirmatn(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}