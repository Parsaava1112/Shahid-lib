class RatingModel {
  final int? id;
  final int bookId;
  final String userName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  RatingModel({
    this.id,
    required this.bookId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      id: map['id'],
      bookId: map['book_id'],
      userName: map['user_name'],
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}