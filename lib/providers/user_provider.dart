// lib/providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../repositories/profile_repository.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository());

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier(
    ref.read(apiServiceProvider),
    ref.read(profileRepositoryProvider),
  );
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  final ApiService _api;
  final ProfileRepository _repository;

  UserProfileNotifier(this._api, this._repository) : super(null) {
    _init();
  }

  Future<void> _init() async {
    // ابتدا از دیتابیس محلی بخوان
    final local = await _repository.getProfile();
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
      diceBearSeed: 'shahid-soleimani-${DateTime.now().millisecondsSinceEpoch}',
    );
    state = defaultProfile;
    _repository.saveProfile(defaultProfile);
  }

  Future<void> _syncFromServer() async {
    try {
      final remote = await _api.fetchProfile();
      state = remote;
      await _repository.saveProfile(remote);
    } catch (_) {
      // آفلاین: از داده محلی استفاده کن
    }
  }

  Future<void> updateName(String name) async {
    if (state == null) return;
    final updated = state!.copyWith(name: name);
    state = updated;
    await _repository.saveProfile(updated);
    try {
      await _api.updateProfile(name: name);
    } catch (_) {}
  }

  Future<void> updateAvatar(String seed, String style) async {
    if (state == null) return;
    final updated = state!.copyWith(diceBearSeed: seed, avatarStyle: style);
    state = updated;
    await _repository.saveProfile(updated);
    try {
      await _api.updateProfile(diceBearSeed: seed, avatarStyle: style);
    } catch (_) {}
  }

  Future<void> toggleDarkMode() async {
    if (state == null) return;
    final updated = state!.copyWith(isDarkMode: !state!.isDarkMode);
    state = updated;
    await _repository.saveProfile(updated);
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
      await _repository.saveProfile(updated);
    } catch (_) {}
  }
}