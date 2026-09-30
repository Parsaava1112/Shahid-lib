// lib/providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier(ref.read(apiServiceProvider));
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final ApiService _api;

  UserProfileNotifier(this._api) : super(null) {
    _init();
  }

  Future<void> _init() async {
    // ابتدا از ReaxDB بخوان
    final local = await LocalStorageService.getProfileAsync();
    if (local != null) {
      state = local;
    } else {
      _createDefaultProfile();
    }
    // سپس از سرور همگام کن
    _syncFromServer();
  }

  void _createDefaultProfile() {
    final defaultProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'کاربر مهمان',
      diceBearSeed:
          'shahid-soleimani-${DateTime.now().millisecondsSinceEpoch}',
    );
    state = defaultProfile;
    LocalStorageService.saveProfile(defaultProfile);
  }

  Future<void> _syncFromServer() async {
    try {
      final remote = await _api.fetchProfile();
      state = remote;
      await LocalStorageService.saveProfile(remote);
    } catch (_) {
      // آفلاین: از داده محلی استفاده کن
    }
  }

  Future<void> updateName(String name) async {
    if (state == null) return;
    final updated = state!.copyWith(name: name);
    state = updated;
    await LocalStorageService.saveProfile(updated);
    try {
      await _api.updateProfile(name: name);
    } catch (_) {}
  }

  Future<void> updateAvatar(String seed, String style) async {
    if (state == null) return;
    final updated = state!.copyWith(diceBearSeed: seed, avatarStyle: style);
    state = updated;
    await LocalStorageService.saveProfile(updated);
    try {
      await _api.updateProfile(diceBearSeed: seed, avatarStyle: style);
    } catch (_) {}
  }

  Future<void> toggleDarkMode() async {
    if (state == null) return;
    final updated = state!.copyWith(isDarkMode: !state!.isDarkMode);
    state = updated;
    await LocalStorageService.saveProfile(updated);
    try {
      await _api.updateProfile(isDarkMode: updated.isDarkMode);
    } catch (_) {}
  }

  Future<void> toggleFavorite(String bookId) async {
    if (state == null) return;
    try {
      final isFav = await _api.toggleFavorite(int.parse(bookId));
      final favorites = List<String>.from(state!.favoriteBookIds);
      if (isFav) {
        favorites.add(bookId);
      } else {
        favorites.remove(bookId);
      }
      final updated = state!.copyWith(favoriteBookIds: favorites);
      state = updated;
      await LocalStorageService.saveProfile(updated);
    } catch (_) {}
  }
}