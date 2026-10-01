import 'package:flutter/material.dart';
import 'package:awesome_rating/awesome_rating.dart';
import '../../data/models/rating_model.dart';
import '../../core/database/db_helper.dart';

class RatingWidget extends StatefulWidget {
  final int bookId;
  final double initialRating;
  final ValueChanged<double>? onRatingChanged;

  const RatingWidget({
    super.key,
    required this.bookId,
    this.initialRating = 0.0,
    this.onRatingChanged,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late double _rating;
  final _commentController = TextEditingController();
  bool _showCommentField = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  Future<void> _submitRating() async {
    if (_rating == 0) return;

    final user = await DBHelper.getUserByNationalCode(''); // باید کاربر جاری را بگیرید
    // در پیاده‌سازی واقعی، کاربر جاری را از state management بگیرید

    final rating = RatingModel(
      bookId: widget.bookId,
      userName: user?.name ?? 'کاربر مهمان',
      rating: _rating,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await DBHelper.insertRating(rating);
    await DBHelper.updateBookRating(widget.bookId);
    await DBHelper.addToSyncQueue('rating', rating.toMap().toString());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('امتیاز شما ثبت شد. متشکریم!')),
      );
      setState(() {
        _showCommentField = false;
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'امتیاز شما به این کتاب',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Center(
              child: AwesomeStarRating(
                starCount: 5,
                rating: _rating,
                size: 40,
                color: Colors.amber,
                borderColor: Colors.amber,
                onRatingChanged: (value) {
                  setState(() {
                    _rating = value;
                    _showCommentField = true;
                  });
                  widget.onRatingChanged?.call(value);
                },
              ),
            ),
            if (_showCommentField) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'نظر خود را بنویسید (اختیاری)',
                  prefixIcon: Icon(Icons.comment),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitRating,
                  child: const Text('ثبت امتیاز و نظر'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}