import 'package:flutter/material.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int target;
  final String type; // 'books', 'minutes', 'streak', 'rating'
  final Color color;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.type,
    this.color = const Color(0xFFFFD700),
  });
}

class AchievementService {
  static const List<AchievementModel> all = [
    AchievementModel(
      id: 'first_book',
      title: 'شروع‌کننده',
      description: 'اولین کتابت رو تمام کن',
      icon: '📖',
      target: 1,
      type: 'books',
      color: Color(0xFF66BB6A),
    ),
    AchievementModel(
      id: 'five_books',
      title: 'کتاب‌خوان',
      description: '۵ کتاب تمام کن',
      icon: '📚',
      target: 5,
      type: 'books',
      color: Color(0xFF42A5F5),
    ),
    AchievementModel(
      id: 'twenty_books',
      title: 'کتاب‌خوار',
      description: '۲۰ کتاب تمام کن',
      icon: '🍽️',
      target: 20,
      type: 'books',
      color: Color(0xFF7E57C2),
    ),
    AchievementModel(
      id: 'fifty_books',
      title: 'افسانه کتاب',
      description: '۵۰ کتاب تمام کن',
      icon: '👑',
      target: 50,
      type: 'books',
      color: Color(0xFFFFB300),
    ),
    AchievementModel(
      id: 'first_minute',
      title: 'اولین قدم',
      description: 'اولین دقیقه مطالعه',
      icon: '⏱️',
      target: 1,
      type: 'minutes',
      color: Color(0xFF26A69A),
    ),
    AchievementModel(
      id: 'one_hour',
      title: 'یک ساعت طلایی',
      description: 'یک ساعت مطالعه کن',
      icon: '🕐',
      target: 60,
      type: 'minutes',
      color: Color(0xFFEC407A),
    ),
    AchievementModel(
      id: 'ten_hours',
      title: 'کتابخانه‌گرد',
      description: '۱۰ ساعت مطالعه کن',
      icon: '🏛️',
      target: 600,
      type: 'minutes',
      color: Color(0xFF8D6E63),
    ),
    AchievementModel(
      id: 'fifty_hours',
      title: 'فیلسوف',
      description: '۵۰ ساعت مطالعه کن',
      icon: '🧠',
      target: 3000,
      type: 'minutes',
      color: Color(0xFF5C6BC0),
    ),
    AchievementModel(
      id: 'streak_3',
      title: 'مستمر',
      description: '۳ روز متوالی مطالعه',
      icon: '🔥',
      target: 3,
      type: 'streak',
      color: Color(0xFFFF7043),
    ),
    AchievementModel(
      id: 'streak_7',
      title: 'قهرمان هفته',
      description: '۷ روز متوالی مطالعه',
      icon: '🏆',
      target: 7,
      type: 'streak',
      color: Color(0xFFFFA726),
    ),
    AchievementModel(
      id: 'streak_30',
      title: 'یک ماه کامل',
      description: '۳۰ روز متوالی مطالعه',
      icon: '💎',
      target: 30,
      type: 'streak',
      color: Color(0xFF29B6F6),
    ),
    AchievementModel(
      id: 'streak_100',
      title: 'افسانه استمرار',
      description: '۱۰۰ روز متوالی مطالعه',
      icon: '⭐',
      target: 100,
      type: 'streak',
      color: Color(0xFFAB47BC),
    ),
    AchievementModel(
      id: 'first_rating',
      title: 'منتقد',
      description: 'اولین امتیازت رو بده',
      icon: '✨',
      target: 1,
      type: 'rating',
      color: Color(0xFFFFCA28),
    ),
    AchievementModel(
      id: 'ten_ratings',
      title: 'ستاره‌شناس',
      description: '۱۰ امتیاز ثبت کن',
      icon: '🌟',
      target: 10,
      type: 'rating',
      color: Color(0xFFFFD54F),
    ),
  ];

  /// محاسبه دستاوردهای کسب‌شده
  static List<AchievementModel> getUnlocked({
    required int booksRead,
    required int minutesRead,
    required int currentStreak,
    required int ratingsCount,
  }) {
    return all.where((a) {
      switch (a.type) {
        case 'books':
          return booksRead >= a.target;
        case 'minutes':
          return minutesRead >= a.target;
        case 'streak':
          return currentStreak >= a.target;
        case 'rating':
          return ratingsCount >= a.target;
        default:
          return false;
      }
    }).toList();
  }

  /// محاسبه دستاورد بعدی (نزدیک‌ترین)
  static AchievementModel? getNextAchievement({
    required int booksRead,
    required int minutesRead,
    required int currentStreak,
    required int ratingsCount,
  }) {
    AchievementModel? next;
    int minRemaining = 999999;

    for (final a in all) {
      int current;
      switch (a.type) {
        case 'books':
          current = booksRead;
          break;
        case 'minutes':
          current = minutesRead;
          break;
        case 'streak':
          current = currentStreak;
          break;
        case 'rating':
          current = ratingsCount;
          break;
        default:
          continue;
      }

      if (current < a.target) {
        final remaining = a.target - current;
        if (remaining < minRemaining) {
          minRemaining = remaining;
          next = a;
        }
      }
    }
    return next;
  }

  /// محاسبه درصد پیشرفت
  static double getProgress({
    required AchievementModel achievement,
    required int booksRead,
    required int minutesRead,
    required int currentStreak,
    required int ratingsCount,
  }) {
    int current;
    switch (achievement.type) {
      case 'books':
        current = booksRead;
        break;
      case 'minutes':
        current = minutesRead;
        break;
      case 'streak':
        current = currentStreak;
        break;
      case 'rating':
        current = ratingsCount;
        break;
      default:
        return 0;
    }
    if (achievement.target == 0) return 0;
    return (current / achievement.target).clamp(0.0, 1.0);
  }
}