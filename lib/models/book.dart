// lib/models/book.dart

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String? pdfUrl;
  final String? audioUrl;
  final String? videoUrl;
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

  /// از Map دیتابیس به مدل
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      description: map['description'] as String? ?? '',
      coverUrl: map['cover_url'] as String? ?? '',
      pdfUrl: map['pdf_url'] as String?,
      audioUrl: map['audio_url'] as String?,
      videoUrl: map['video_url'] as String?,
      isPdfDownloaded: (map['is_pdf_downloaded'] as int? ?? 0) == 1,
      isAudioDownloaded: (map['is_audio_downloaded'] as int? ?? 0) == 1,
      localPdfPath: map['local_pdf_path'] as String?,
      localAudioPath: map['local_audio_path'] as String?,
      category: map['category'] as String? ?? 'عمومی',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// از JSON API به مدل (برای دریافت از سرور)
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
      category: json['category'] ?? 'عمومی',
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  /// از مدل به Map دیتابیس
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'cover_url': coverUrl,
      'pdf_url': pdfUrl,
      'audio_url': audioUrl,
      'video_url': videoUrl,
      'is_pdf_downloaded': isPdfDownloaded ? 1 : 0,
      'is_audio_downloaded': isAudioDownloaded ? 1 : 0,
      'local_pdf_path': localPdfPath,
      'local_audio_path': localAudioPath,
      'category': category,
      'rating': rating,
    };
  }

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