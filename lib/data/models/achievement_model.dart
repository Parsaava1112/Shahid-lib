class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementTier tier;
  final AchievementRequirement requirementType;
  final int requirementValue;
  final int xpReward;
  final bool isUnlocked;
  final int progress;
  final DateTime? unlockedAt;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tier,
    required this.requirementType,
    required this.requirementValue,
    required this.xpReward,
    this.isUnlocked = false,
    this.progress = 0,
    this.unlockedAt,
  });

  double get progressPercent =>
      requirementValue == 0 ? 0 : (progress / requirementValue).clamp(0, 1);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'tier': tier.name,
        'requirement_type': requirementType.name,
        'requirement_value': requirementValue,
        'xp_reward': xpReward,
        'is_unlocked': isUnlocked ? 1 : 0,
        'progress': progress,
        'unlocked_at': unlockedAt?.toIso8601String(),
      };

  factory AchievementModel.fromMap(Map<String, dynamic> m) => AchievementModel(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String,
        icon: m['icon'] as String,
        tier: AchievementTier.values.firstWhere(
          (e) => e.name == m['tier'],
          orElse: () => AchievementTier.bronze,
        ),
        requirementType: AchievementRequirement.values.firstWhere(
          (e) => e.name == m['requirement_type'],
          orElse: () => AchievementRequirement.booksRead,
        ),
        requirementValue: m['requirement_value'] as int,
        xpReward: m['xp_reward'] as int? ?? 0,
        isUnlocked: m['is_unlocked'] == 1,
        progress: m['progress'] as int? ?? 0,
        unlockedAt: m['unlocked_at'] != null
            ? DateTime.tryParse(m['unlocked_at'])
            : null,
      );
}

enum AchievementTier { bronze, silver, gold, platinum, legendary }

enum AchievementRequirement {
  booksRead,
  booksCompleted,
  minutesRead,
  streak,
  ratings,
  downloads,
}