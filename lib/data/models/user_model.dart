class UserModel {
  final int? id;
  final String name;
  final String nationalCode;
  final String? avatarSeed;
  final String? avatarStyle;
  final String? bio;
  final String? themePreference;

  UserModel({
    this.id,
    required this.name,
    required this.nationalCode,
    this.avatarSeed,
    this.avatarStyle,
    this.bio,
    this.themePreference,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'national_code': nationalCode,
      'avatar_seed': avatarSeed,
      'avatar_style': avatarStyle,
      'bio': bio,
      'theme_preference': themePreference,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      nationalCode: map['national_code'],
      avatarSeed: map['avatar_seed'],
      avatarStyle: map['avatar_style'],
      bio: map['bio'],
      themePreference: map['theme_preference'],
    );
  }
}