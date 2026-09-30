import 'package:hive_io/hive_io.dart';

part 'book.g.dart';

@HiveType(typeId: 0)
class Book {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String author;
  
  @HiveField(3)
  final String description;
  
  @HiveField(4)
  final String coverUrl;
  
  @HiveField(5)
  final String? pdfUrl;
  
  @HiveField(6)
  final String? audioUrl;
  
  @HiveField(7)
  final bool isPdfDownloaded;
  
  @HiveField(8)
  final bool isAudioDownloaded;
  
  @HiveField(9)
  final String? localPdfPath;
  
  @HiveField(10)
  final String? localAudioPath;
  
  @HiveField(11)
  final String category;
  
  @HiveField(12)
  final double rating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    this.pdfUrl,
    this.audioUrl,
    this.isPdfDownloaded = false,
    this.isAudioDownloaded = false,
    this.localPdfPath,
    this.localAudioPath,
    this.category = 'عمومی',
    this.rating = 0.0,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      pdfUrl: json['pdfUrl'],
      audioUrl: json['audioUrl'],
      category: json['category'] ?? 'عمومی',
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
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
      isPdfDownloaded: isPdfDownloaded ?? this.isPdfDownloaded,
      isAudioDownloaded: isAudioDownloaded ?? this.isAudioDownloaded,
      localPdfPath: localPdfPath ?? this.localPdfPath,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      category: category,
      rating: rating,
    );
  }
}