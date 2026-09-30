// lib/models/user_profile.dart

class UserProfile {
  final String id;
  final String name;
  final String diceBearSeed;
  final String avatarStyle;
  final int themeColor;
  final bool isDarkMode;
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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      diceBearSeed: json['diceBearSeed'] ?? '',
      avatarStyle: json['avatarStyle'] ?? 'adventurer',
      themeColor: json['themeColor'] ?? 0xFF1B5E20,
      isDarkMode: json['isDarkMode'] ?? false,
      favoriteBookIds: (json['favoriteBookIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'diceBearSeed': diceBearSeed,
      'avatarStyle': avatarStyle,
      'themeColor': themeColor,
      'isDarkMode': isDarkMode,
      'favoriteBookIds': favoriteBookIds,
    };
  }

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