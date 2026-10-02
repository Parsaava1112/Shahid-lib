import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/database/db_helper.dart';
import '../../data/models/rating_model.dart';
import '../../services/api_service.dart';

class RatingWidget extends StatefulWidget {
  final int bookId;
  final double initialRating;
  final ValueChanged<double>? onRatingChanged;

  const RatingWidget({
    super.key,
    required this.bookId,
    this.initialRating = 0,
    this.onRatingChanged,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget>
    with SingleTickerProviderStateMixin {
  double _rating = 0;
  int _hoveredStar = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  Future<void> _submit() async {
    if (_rating == 0 || _submitting) return;
    setState(() => _submitting = true);

    final user = await ApiService.getCurrentUser();
    final rating = RatingModel(
      bookId: widget.bookId,
      userName: user?.name ?? 'کاربر',
      rating: _rating,
      createdAt: DateTime.now(),
    );

    await DBHelper.insertRating(rating);
    await DBHelper.updateBookRating(widget.bookId);

    if (!mounted) return;
    setState(() => _submitting = false);
    widget.onRatingChanged?.call(_rating);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'امتیاز $_rating از ۵ ثبت شد',
              style: GoogleFonts.vazirmatn(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withOpacity(0.05),
            scheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, color: scheme.secondary, size: 24),
              const SizedBox(width: 8),
              Text(
                'امتیاز شما',
                style: GoogleFonts.vazirmatn(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final index = i + 1;
              final active = index <= (_hoveredStar > 0 ? _hoveredStar : _rating);
              return GestureDetector(
                onTap: () {
                  setState(() => _rating = index.toDouble());
                },
                onLongPress: () {
                  setState(() => _rating = index.toDouble());
                },
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredStar = index),
                  onExit: (_) => setState(() => _hoveredStar = 0),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 150 + i * 30),
                    curve: Curves.easeOutBack,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(6),
                    transform: Matrix4.identity()
                      ..scale(active ? 1.15 : 1.0),
                    transformAlignment: Alignment.center,
                    child: Icon(
                      active
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 40,
                      color: active
                          ? scheme.secondary
                          : scheme.onSurface.withOpacity(0.25),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: GoogleFonts.vazirmatn(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _rating > 0
                  ? scheme.primary
                  : scheme.onSurface.withOpacity(0.5),
            ),
            child: Text(_getLabel(_rating)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _rating > 0 && !_submitting ? _submit : null,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'ثبت امتیاز',
                      style: GoogleFonts.vazirmatn(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLabel(double v) {
    if (v == 0) return 'برای امتیاز ستاره را لمس کنید';
    if (v <= 1) return 'ضعیف';
    if (v <= 2) return 'متوسط';
    if (v <= 3) return 'خوب';
    if (v <= 4) return 'خیلی خوب';
    return 'فوق‌العاده!';
  }
}