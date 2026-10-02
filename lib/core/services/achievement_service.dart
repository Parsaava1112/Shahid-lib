import 'package:flutter/material.dart';
import '../../data/models/achievement_model.dart';
import '../database/db_helper.dart';

class AchievementService {
  static const List<AchievementModel> _definitions = [
    // ===== برنز =====
    AchievementModel(
      id: 'first_book',
      title: 'اولین قدم',
      description: 'اولین کتاب خود را باز کنید',
      icon: '📖',
      tier: AchievementTier.bronze,
      requirementType: AchievementRequirement.booksRead,
      requirementValue: 1,
      xpReward: 20,
    ),
    AchievementModel(
      id: 'first_rating',
      title: 'منتقد تازه‌کار',
      description: 'اولین امتیاز خود را ثبت کنید',
      icon: '⭐',
      tier: AchievementTier.bronze,
      requirementType: AchievementRequirement.ratings,
      requirementValue: 1,
      xpReward: 15,
    ),
    AchievementModel(
      id: 'first_download',
      title: 'کتاب‌جمع‌کن',
      description: 'اولین کتاب را دانلود کنید',
      icon: '📥',
      tier: AchievementTier.bronze,
      requirementType: AchievementRequirement.downloads,
      requirementValue: 1,
      xpReward: 10,
    ),
    AchievementModel(
      id: 'streak_3',
      title: 'شروع مستمر',
      description: '۳ روز متوالی مطالعه کنید',
      icon: '🔥',
      tier: AchievementTier.bronze,
      requirementType: AchievementRequirement.streak,
      requirementValue: 3,
      xpReward: 30,
    ),

    // ===== نقره =====
    AchievementModel(
      id: 'books_5',
      title: 'کتاب‌خوان',
      description: '۵ کتاب مطالعه کنید',
      icon: '📚',
      tier: AchievementTier.silver,
      requirementType: AchievementRequirement.booksRead,
      requirementValue: 5,
      xpReward: 60,
    ),
    AchievementModel(
      id: 'completed_1',
      title: 'تمام‌کننده',
      description: 'اولین کتاب را کامل بخوانید',
      icon: '✅',
      tier: AchievementTier.silver,
      requirementType: AchievementRequirement.booksCompleted,
      requirementValue: 1,
      xpReward: 50,
    ),
    AchievementModel(
      id: 'minutes_100',
      title: 'صد دقیقه',
      description: '۱۰۰ دقیقه مطالعه کنید',
      icon: '⏱️',
      tier: AchievementTier.silver,
      requirementType: AchievementRequirement.minutesRead,
      requirementValue: 100,
      xpReward: 40,
    ),
    AchievementModel(
      id: 'streak_7',
      title: 'قهرمان هفته',
      description: '۷ روز متوالی مطالعه کنید',
      icon: '🏆',
      tier: AchievementTier.silver,
      requirementType: AchievementRequirement.streak,
      requirementValue: 7,
      xpReward: 80,
    ),

    // ===== طلایی =====
    AchievementModel(
      id: 'books_15',
      title: 'کتاب‌خوار',
      description: '۱۵ کتاب مطالعه کنید',
      icon: '🍽️',
      tier: AchievementTier.gold,
      requirementType: AchievementRequirement.booksRead,
      requirementValue: 15,
      xpReward: 150,
    ),
    AchievementModel(
      id: 'completed_5',
      title: 'پیگیر',
      description: '۵ کتاب را کامل بخوانید',
      icon: '🎯',
      tier: AchievementTier.gold,
      requirementType: AchievementRequirement.booksCompleted,
      requirementValue: 5,
      xpReward: 200,
    ),
    AchievementModel(
      id: 'minutes_1000',
      title: 'هزار دقیقه',
      description: '۱۰۰۰ دقیقه مطالعه کنید',
      icon: '⏰',
      tier: AchievementTier.gold,
      requirementType: AchievementRequirement.minutesRead,
      requirementValue: 1000,
      xpReward: 180,
    ),
    AchievementModel(
      id: 'streak_30',
      title: 'یک ماه افسانه‌ای',
      description: '۳۰ روز متوالی مطالعه کنید',
      icon: '🌙',
      tier: AchievementTier.gold,
      requirementType: AchievementRequirement.streak,
      requirementValue: 30,
      xpReward: 400,
    ),

    // ===== پلاتینیوم =====
    AchievementModel(
      id: 'books_50',
      title: 'کتابخانه‌دار',
      description: '۵۰ کتاب مطالعه کنید',
      icon: '🏛️',
      tier: AchievementTier.platinum,
      requirementType: AchievementRequirement.booksRead,
      requirementValue: 50,
      xpReward: 600,
    ),
    AchievementModel(
      id: 'completed_20',
      title: 'فاتح',
      description: '۲۰ کتاب را کامل بخوانید',
      icon: '👑',
      tier: AchievementTier.platinum,
      requirementType: AchievementRequirement.booksCompleted,
      requirementValue: 20,
      xpReward: 800,
    ),

    // ===== افسانه‌ای =====
    AchievementModel(
      id: 'streak_100',
      title: 'افسانه زنده',
      description: '۱۰۰ روز متوالی مطالعه کنید',
      icon: '💎',
      tier: AchievementTier.legendary,
      requirementType: AchievementRequirement.streak,
      requirementValue: 100,
      xpReward: 2000,
    ),
    AchievementModel(
      id: 'books_100',
      title: 'استاد کتاب',
      description: '۱۰۰ کتاب مطالعه کنید',
      icon: '🌟',
      tier: AchievementTier.legendary,
      requirementType: AchievementRequirement.booksRead,
      requirementValue: 100,
      xpReward: 3000,
    ),
  ];

  /// راه‌اندازی اولیه دستاوردها
  static Future<void> initialize() async {
    final existing = await DBHelper.getAchievements();
    if (existing.isEmpty) {
      for (final a in _definitions) {
        await DBHelper.saveAchievement(a);
      }
    }
  }

  /// بررسی و به‌روزرسانی دستاوردها
  static Future<List<AchievementModel>> checkAndUnlock(int userId) async {
    final all = await DBHelper.getAchievements();
    final stats = await DBHelper.getUserStats(userId);
    final unlocked = <AchievementModel>[];

    final booksRead = stats['books_read'] as int? ?? 0;
    final booksCompleted = stats['books_completed'] as int? ?? 0;
    final minutes = stats['total_minutes'] as int? ?? 0;
    final streak = stats['current_streak'] as int? ?? 0;

    // تعداد امتیازات و دانلودها را هم می‌توان محاسبه کرد
    // در این نسخه ساده، فقط از stats استفاده می‌کنیم

    for (final a in all) {
      if (a.isUnlocked) continue;

      int current = 0;
      switch (a.requirementType) {
        case AchievementRequirement.booksRead:
          current = booksRead;
          break;
        case AchievementRequirement.booksCompleted:
          current = booksCompleted;
          break;
        case AchievementRequirement.minutesRead:
          current = minutes;
          break;
        case AchievementRequirement.streak:
          current = streak;
          break;
        default:
          current = a.progress;
      }

      if (current >= a.requirementValue) {
        await DBHelper.unlockAchievement(a.id);
        await _addXp(userId, a.xpReward);
        unlocked.add(AchievementModel(
          id: a.id,
          title: a.title,
          description: a.description,
          icon: a.icon,
          tier: a.tier,
          requirementType: a.requirementType,
          requirementValue: a.requirementValue,
          xpReward: a.xpReward,
          isUnlocked: true,
          progress: a.requirementValue,
          unlockedAt: DateTime.now(),
        ));
      } else {
        final updated = AchievementModel(
          id: a.id,
          title: a.title,
          description: a.description,
          icon: a.icon,
          tier: a.tier,
          requirementType: a.requirementType,
          requirementValue: a.requirementValue,
          xpReward: a.xpReward,
          isUnlocked: false,
          progress: current,
        );
        await DBHelper.saveAchievement(updated);
      }
    }

    return unlocked;
  }

  /// اضافه کردن XP و بررسی Level Up
  static Future<int> addXp(int userId, int xp) async {
    return _addXp(userId, xp);
  }

  static Future<int> _addXp(int userId, int xp) async {
    final stats = await DBHelper.getUserStats(userId);
    final currentXp = (stats['total_xp'] as int? ?? 0) + xp;
    final currentLevel = stats['level'] as int? ?? 1;

    final newLevel = _levelForXp(currentXp);
    final leveledUp = newLevel > currentLevel;

    await DBHelper.updateUserStats(
      userId: userId,
      totalXp: currentXp,
      level: newLevel,
    );

    return leveledUp ? newLevel : 0;
  }

  static int _levelForXp(int xp) {
    // هر سطح ۱۰۰ XP بیشتر از قبلی
    int level = 1;
    int needed = 100;
    int total = 0;
    while (xp >= total + needed) {
      total += needed;
      level++;
      needed = 100 + (level - 1) * 50;
    }
    return level;
  }

  static int xpForNextLevel(int level) {
    return 100 + (level - 1) * 50;
  }

  static int xpInCurrentLevel(int totalXp) {
    int total = 0;
    int level = 1;
    int needed = 100;
    while (totalXp >= total + needed) {
      total += needed;
      level++;
      needed = 100 + (level - 1) * 50;
    }
    return totalXp - total;
  }

  /// رنگ هر سطح
  static Color colorForTier(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFB0BEC5);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFF9C27B0);
      case AchievementTier.legendary:
        return const Color(0xFFFF6F00);
    }
  }

  static String labelForTier(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return 'برنز';
      case AchievementTier.silver:
        return 'نقره';
      case AchievementTier.gold:
        return 'طلایی';
      case AchievementTier.platinum:
        return 'پلاتینیوم';
      case AchievementTier.legendary:
        return 'افسانه‌ای';
    }
  }
}