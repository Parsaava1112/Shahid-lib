// lib/presentation/screens/book_detail_screen.dart (بخش کاور)
Widget _buildCover() {
  return Hero(
    tag: 'book_cover_${widget.book.id}',
    child: Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      child: Icon(
        widget.book.type == 'pdf' ? Icons.picture_as_pdf
            : widget.book.type == 'audio' ? Icons.headphones
            : Icons.videocam,
        size: 80,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}