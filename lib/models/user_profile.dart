// lib/models/user_profile.dart

import 'dart:convert';

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

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      diceBearSeed: map['dice_bear_seed'] as String? ?? '',
      avatarStyle: map['avatar_style'] as String? ?? 'adventurer',
      themeColor: map['theme_color'] as int? ?? 0xFF1B5E20,
      isDarkMode: (map['is_dark_mode'] as int? ?? 0) == 1,
      favoriteBookIds: _parseFavoriteIds(map['favorite_book_ids']),
    );
  }

  static List<String> _parseFavoriteIds(dynamic value) {
    if (value == null) return [];
    try {
      final list = jsonDecode(value as String);
      return (list as List).map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dice_bear_seed': diceBearSeed,
      'avatar_style': avatarStyle,
      'theme_color': themeColor,
      'is_dark_mode': isDarkMode ? 1 : 0,
      'favorite_book_ids': jsonEncode(favoriteBookIds),
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