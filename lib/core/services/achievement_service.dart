import 'package:flutter/material.dart';
import '../../data/models/achievement_model.dart';
import '../../core/database/db_helper.dart';

class AchievementService {
  /// لیست تمام دستاوردهای ممکن
  static final List<AchievementModel> allAchievements = [
    // ============ برنزی ============
    const AchievementModel(
      id: 'first_read',
      title: 'شروع‌کننده',
      description: 'اولین کتاب خود را باز کنید',
      icon: '📖',
      target: 1,
      type: 'books',
      tier: AchievementTier.bronze,
    ),
    const AchievementModel(
      id: 'read_5',
      title: 'کتاب‌خوان',
      description: '۵ کتاب بخوانید',
      icon: '📚',
      target: 5,
      type: 'books',
      tier: AchievementTier.bronze,
    ),
    const AchievementModel(
      id: 'minutes_60',
      title: 'یک ساعت مطالعه',
      description: '۶۰ دقیقه مطالعه کنید',
      icon: '⏱️',
      target: 60,
      type: 'minutes',
      tier: AchievementTier.bronze,
    ),
    const AchievementModel(
      id: 'streak_3',
      title: 'شروع استمرار',
      description: '۳ روز متوالی مطالعه',
      icon: '🔥',
      target: 3,
      type: 'streak',
      tier: AchievementTier.bronze,
    ),

    // ============ نقره‌ای ============
    const AchievementModel(
      id: 'read_20',
      title: 'کتاب‌خوار',
      description: '۲۰ کتاب بخوانید',
      icon: '🍽️',
      target: 20,
      type: 'books',
      tier: AchievementTier.silver,
    ),
    const AchievementModel(
      id: 'minutes_600',
      title: 'ده ساعت مطالعه',
      description: '۶۰۰ دقیقه مطالعه کنید',
      icon: '⌛',
      target: 600,
      type: 'minutes',
      tier: AchievementTier.silver,
    ),
    const AchievementModel(
      id: 'streak_7',
      title: 'هفته طلایی',
      description: '۷ روز متوالی مطالعه',
      icon: '⭐',
      target: 7,
      type: 'streak',
      tier: AchievementTier.silver,
    ),
    const AchievementModel(
      id: 'rate_10',
      title: 'منتقد',
      description: 'به ۱۰ کتاب امتیاز بدهید',
      icon: '✍️',
      target: 10,
      type: 'rating',
      tier: AchievementTier.silver,
    ),

    // ============ طلایی ============
    const AchievementModel(
      id: 'read_50',
      title: 'کتاب‌دوست',
      description: '۵۰ کتاب بخوانید',
      icon: '💎',
      target: 50,
      type: 'books',
      tier: AchievementTier.gold,
    ),
    const AchievementModel(
      id: 'minutes_3000',
      title: 'پنجاه ساعت مطالعه',
      description: '۳۰۰۰ دقیقه مطالعه کنید',
      icon: '🏅',
      target: 3000,
      type: 'minutes',
      tier: AchievementTier.gold,
    ),
    const AchievementModel(
      id: 'streak_30',
      title: 'قهرمان ماه',
      description: '۳۰ روز متوالی مطالعه',
      icon: '🏆',
      target: 30,
      type: 'streak',
      tier: AchievementTier.gold,
    ),

    // ============ افسانه‌ای ============
    const AchievementModel(
      id: 'read_100',
      title: 'افسانه کتاب',
      description: '۱۰۰ کتاب بخوانید',
      icon: '👑',
      target: 100,
      type: 'books',
      tier: AchievementTier.legendary,
    ),
    const AchievementModel(
      id: 'streak_100',
      title: 'صد روز استمرار',
      description: '۱۰۰ روز متوالی مطالعه',
      icon: '🌟',
      target: 100,
      type: 'streak',
      tier: AchievementTier.legendary,
    ),
    const AchievementModel(
      id: 'minutes_10000',
      title: 'استاد زمان',
      description: '۱۰۰۰۰ دقیقه مطالعه کنید',
      icon: '🎖️',
      target: 10000,
      type: 'minutes',
      tier: AchievementTier.legendary,
    ),
    const AchievementModel(
      id: 'night_owl',
      title: 'شب‌زنده‌دار',
      description: 'بین ۲ تا ۴ صبح مطالعه کنید',
      icon: '🌙',
      target: 1,
      type: 'special',
      tier: AchievementTier.legendary,
    ),
  ];

  // ============ راه‌اندازی ============
  static Future<void> initialize() async {
    // بارگذاری دستاوردهای باز شده از دیتابیس
    final unlocked = await DBHelper.getUnlockedAchievements();
    AchievementModel.setUnlocked(unlocked);
  }

  // ============ بررسی و باز کردن دستاوردها ============
  static Future<List<AchievementModel>> checkAndUnlock(int userId) async {
    final stats = await DBHelper.getUserStats(userId);
    final unlockedList = <AchievementModel>[];
    final currentlyUnlocked = await DBHelper.getUnlockedAchievements();

    final booksRead = (stats['total_books_read'] as num?)?.toInt() ?? 0;
    final minutesRead = (stats['total_minutes_read'] as num?)?.toInt() ?? 0;
    final streak = (stats['current_streak'] as num?)?.toInt() ?? 0;
    final ratingsCount = (stats['total_ratings'] as num?)?.toInt() ?? 0;

    for (final a in allAchievements) {
      if (currentlyUnlocked.contains(a.id)) continue;

      bool earned = false;
      switch (a.type) {
        case 'books':
          earned = booksRead >= a.target;
          break;
        case 'minutes':
          earned = minutesRead >= a.target;
          break;
        case 'streak':
          earned = streak >= a.target;
          break;
        case 'rating':
          earned = ratingsCount >= a.target;
          break;
        case 'special':
          earned = false; // دستی باز می‌شود
          break;
      }

      if (earned) {
        await DBHelper.unlockAchievement(userId, a.id);
        AchievementModel.markUnlocked(a.id);
        unlockedList.add(a);
      }
    }

    return unlockedList;
  }

  // ============ محاسبه XP ============
  static int xpForLevel(int level) {
    // فرمول: هر سطح ۱۰۰ XP بیشتر از قبلی
    return 100 + (level - 1) * 50;
  }

  static int xpInCurrentLevel(int totalXp) {
    int level = 1;
    int remaining = totalXp;
    while (remaining >= xpForLevel(level)) {
      remaining -= xpForLevel(level);
      level++;
    }
    return remaining;
  }

  static int levelForXp(int totalXp) {
    int level = 1;
    int remaining = totalXp;
    while (remaining >= xpForLevel(level)) {
      remaining -= xpForLevel(level);
      level++;
    }
    return level;
  }

  // ============ رنگ هر سطح دستاورد ============
  static Color colorForTier(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.legendary:
        return const Color(0xFF9C27B0);
    }
  }

  static String labelForTier(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return 'برنزی';
      case AchievementTier.silver:
        return 'نقره‌ای';
      case AchievementTier.gold:
        return 'طلایی';
      case AchievementTier.legendary:
        return 'افسانه‌ای';
    }
  }
}