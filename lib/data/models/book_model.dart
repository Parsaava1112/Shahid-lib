class BookModel {
  final int? id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String fileUrl;
  final String filePath;
  final String type;
  final String category;
  final double rating;
  final int ratingCount;
  final bool isDownloaded;
  final DateTime? downloadedAt;

  BookModel({
    this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.fileUrl,
    required this.filePath,
    required this.type,
    required this.category,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isDownloaded = false,
    this.downloadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'cover_url': coverUrl,
      'file_url': fileUrl,
      'file_path': filePath,
      'type': type,
      'category': category,
      'rating': rating,
      'rating_count': ratingCount,
      'is_downloaded': isDownloaded ? 1 : 0,
      'downloaded_at': downloadedAt?.toIso8601String(),
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'],
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      coverUrl: map['cover_url'] ?? '',
      fileUrl: map['file_url'] ?? '',
      filePath: map['file_path'] ?? '',
      type: map['type'] ?? 'pdf',
      category: map['category'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (map['rating_count'] as num?)?.toInt() ?? 0,
      isDownloaded: map['is_downloaded'] == 1,
      downloadedAt: map['downloaded_at'] != null
          ? DateTime.tryParse(map['downloaded_at'])
          : null,
    );
  }
}