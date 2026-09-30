import 'package:flutter/material.dart';
import 'package:pdf_render_maintained/pdf_render.dart';
import 'package:pdf_render_maintained/pdf_render_widgets.dart';
import 'package:animate_do/animate_do.dart';
import '../models/book.dart';

class PdfViewerScreen extends StatefulWidget {
  final Book book;

  const PdfViewerScreen({super.key, required this.book});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfDocumentLoader _documentLoader;
  final PdfViewerController _controller = PdfViewerController();

  @override
  void initState() {
    super.initState();
    _documentLoader = PdfDocumentLoader.openAsset(
      'assets/books/${widget.book.id}.pdf',
      // یا از فایل دانلود شده:
      // PdfDocumentLoader.openFile(widget.book.localPdfPath!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.book.title),
          actions: [
            // دکمه تغییر حالت نمایش
            IconButton(
              icon: const Icon(Icons.view_carousel),
              onPressed: () {
                setState(() {
                  _controller.layoutPages(
                    margin: const EdgeInsets.all(10),
                  );
                });
              },
            ),
          ],
        ),
        body: FadeIn(
          duration: const Duration(milliseconds: 500),
          child: PdfViewer(
            documentLoader: _documentLoader,
            controller: _controller,
            scrollDirection: Axis.vertical,
            pageDropShadow: const BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
            backgroundColor: Colors.grey[200],
          ),
        ),
        // دکمه‌های شناور برای ناوبری
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              heroTag: 'prev',
              onPressed: () => _controller.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Icon(Icons.arrow_upward),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'next',
              onPressed: () => _controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
              child: const Icon(Icons.arrow_downward),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _documentLoader.dispose();
    _controller.dispose();
    super.dispose();
  }
}