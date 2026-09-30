import 'package:hive_io/hive_io.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String diceBearSeed;
  
  @HiveField(3)
  final String avatarStyle;
  
  @HiveField(4)
  final int themeColor;
  
  @HiveField(5)
  final bool isDarkMode;
  
  @HiveField(6)
  final List<String> favoriteBookIds;

  UserProfile({
    required this.id,
    required this.name,
    required this.diceBearSeed,
    this.avatarStyle = 'adventurer',
    this.themeColor = 0xFF1B5E20,
    this.isDarkMode = false,
    this.favoriteBookIds = const [],
  });

  UserProfile copyWith({
    String? name,
    String? diceBearSeed,
    String? avatarStyle,
    int? themeColor,
    bool? isDarkMode,
    List<String>? favoriteBookIds,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      diceBearSeed: diceBearSeed ?? this.diceBearSeed,
      avatarStyle: avatarStyle ?? this.avatarStyle,
      themeColor: themeColor ?? this.themeColor,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      favoriteBookIds: favoriteBookIds ?? this.favoriteBookIds,
    );
  }
}