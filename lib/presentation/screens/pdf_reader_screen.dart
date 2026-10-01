import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/book_model.dart';

class PdfViewerScreen extends StatefulWidget {
  final BookModel book;

  const PdfViewerScreen({super.key, required this.book});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.title,
          style: GoogleFonts.vazirmatn(),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final file = File(widget.book.filePath);
    if (!file.existsSync()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download, size: 80),
            const SizedBox(height: 16),
            Text(
              'این کتاب هنوز دانلود نشده است',
              style: GoogleFonts.vazirmatn(),
            ),
          ],
        ),
      );
    }

    return PdfViewer.file(
      widget.book.filePath,
    );
  }
}