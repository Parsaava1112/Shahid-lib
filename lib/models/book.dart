// lib/models/book.dart

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String? pdfUrl;
  final String? audioUrl;
  final String? videoUrl;       // اضافه شد
  final bool isPdfDownloaded;
  final bool isAudioDownloaded;
  final String? localPdfPath;
  final String? localAudioPath;
  final String category;
  final double rating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    this.pdfUrl,
    this.audioUrl,
    this.videoUrl,
    this.isPdfDownloaded = false,
    this.isAudioDownloaded = false,
    this.localPdfPath,
    this.localAudioPath,
    this.category = 'عمومی',
    this.rating = 0.0,
  });

  // ─────────────────────────────────────────
  //  fromJson — برای دریافت از API و ReaxDB
  // ─────────────────────────────────────────

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      pdfUrl: json['pdfUrl'],
      audioUrl: json['audioUrl'],
      videoUrl: json['videoUrl'],
      isPdfDownloaded: json['isPdfDownloaded'] ?? false,
      isAudioDownloaded: json['isAudioDownloaded'] ?? false,
      localPdfPath: json['localPdfPath'],
      localAudioPath: json['localAudioPath'],
      category: json['category'] ?? 'عمومی',
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  // ─────────────────────────────────────────
  //  toJson — برای ذخیره در ReaxDB
  // ─────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'pdfUrl': pdfUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'isPdfDownloaded': isPdfDownloaded,
      'isAudioDownloaded': isAudioDownloaded,
      'localPdfPath': localPdfPath,
      'localAudioPath': localAudioPath,
      'category': category,
      'rating': rating,
    };
  }

  // ─────────────────────────────────────────
  //  copyWith
  // ─────────────────────────────────────────

  Book copyWith({
    bool? isPdfDownloaded,
    bool? isAudioDownloaded,
    String? localPdfPath,
    String? localAudioPath,
  }) {
    return Book(
      id: id,
      title: title,
      author: author,
      description: description,
      coverUrl: coverUrl,
      pdfUrl: pdfUrl,
      audioUrl: audioUrl,
      videoUrl: videoUrl,
      isPdfDownloaded: isPdfDownloaded ?? this.isPdfDownloaded,
      isAudioDownloaded: isAudioDownloaded ?? this.isAudioDownloaded,
      localPdfPath: localPdfPath ?? this.localPdfPath,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      category: category,
      rating: rating,
    );
  }
}