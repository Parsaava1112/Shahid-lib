import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/models/book_model.dart';

/// Provider کاربر جاری
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserModel?>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserModel?> {
  UserProfileNotifier() : super(null);

  final List<int> _favorites = [];

  List<int> get favorites => _favorites;

  void setUser(UserModel user) {
    state = user;
  }

  void toggleFavorite(int bookId) {
    if (_favorites.contains(bookId)) {
      _favorites.remove(bookId);
    } else {
      _favorites.add(bookId);
    }
    state = state; // trigger rebuild
  }

  bool isFavorite(int bookId) => _favorites.contains(bookId);
}

/// Provider لیست کتاب‌ها
final booksProvider = FutureProvider<List<BookModel>>((ref) async {
  return [];
});

/// Provider کتاب‌های مورد علاقه
final favoritesProvider = Provider<List<int>>((ref) {
  final notifier = ref.watch(userProfileProvider.notifier);
  return notifier.favorites;
});