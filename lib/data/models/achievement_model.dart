import 'package:flutter/material.dart';

enum AchievementTier { bronze, silver, gold, legendary }

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int target;
  final String type; // 'books', 'minutes', 'streak', 'rating', 'special'
  final AchievementTier tier;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.type,
    required this.tier,
  });

  /// فقط در حافظه - برای نمایش وضعیت باز شدن
  static final Set<String> _unlockedIds = {};

  bool get isUnlocked => _unlockedIds.contains(id);

  /// پذیرش هر دو نوع List<String> و Set<String>
  static void setUnlocked(Iterable<String> ids) {
    _unlockedIds
      ..clear()
      ..addAll(ids);
  }

  static void markUnlocked(String id) {
    _unlockedIds.add(id);
  }

  static void clearUnlocked() {
    _unlockedIds.clear();
  }

  static Set<String> get unlockedIds => Set.unmodifiable(_unlockedIds);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'target': target,
        'type': type,
        'tier': tier.name,
      };
}