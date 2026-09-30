import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/local_storage.dart';

// Provider برای پروفایل کاربر
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(LocalStorageService.getProfile()) {
    if (state == null) {
      _createDefaultProfile();
    }
  }

  void _createDefaultProfile() {
    final defaultProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'کاربر مهمان',
      diceBearSeed: 'shahid-soleimani-${DateTime.now().millisecondsSinceEpoch}',
    );
    state = defaultProfile;
    LocalStorageService.saveProfile(defaultProfile);
  }

  Future<void> updateName(String name) async {
    if (state == null) return;
    final updated = state!.copyWith(name: name);
    state = updated;
    await LocalStorageService.saveProfile(updated);
  }

  Future<void> updateAvatar(String seed, String style) async {
    if (state == null) return;
    final updated = state!.copyWith(diceBearSeed: seed, avatarStyle: style);
    state = updated;
    await LocalStorageService.saveProfile(updated);
  }

  Future<void> toggleDarkMode() async {
    if (state == null) return;
    final updated = state!.copyWith(isDarkMode: !state!.isDarkMode);
    state = updated;
    await LocalStorageService.saveProfile(updated);
  }

  Future<void> updateThemeColor(int color) async {
    if (state == null) return;
    final updated = state!.copyWith(themeColor: color);
    state = updated;
    await LocalStorageService.saveProfile(updated);
  }

  Future<void> toggleFavorite(String bookId) async {
    if (state == null) return;
    final favorites = List<String>.from(state!.favoriteBookIds);
    if (favorites.contains(bookId)) {
      favorites.remove(bookId);
    } else {
      favorites.add(bookId);
    }
    final updated = state!.copyWith(favoriteBookIds: favorites);
    state = updated;
    await LocalStorageService.saveProfile(updated);
  }
}