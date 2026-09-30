import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

// Provider برای ApiService
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Provider برای لیست کتاب‌ها
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);
  
  // ابتدا از حافظه محلی بخوان
  final localBooks = LocalStorageService.getBooks();
  if (localBooks.isNotEmpty) {
    // در پس‌زمینه از سرور به‌روزرسانی کن
    _refreshBooksFromServer(api, ref);
    return localBooks;
  }
  
  // اگر محلی خالی بود، از سرور بگیر
  final books = await api.fetchBooks();
  await LocalStorageService.saveBooks(books);
  return books;
});

// به‌روزرسانی کتاب‌ها از سرور در پس‌زمینه
Future<void> _refreshBooksFromServer(ApiService api, Ref ref) async {
  try {
    final books = await api.fetchBooks();
    await LocalStorageService.saveBooks(books);
    ref.invalidateSelf();
  } catch (_) {
    // خطا را نادیده بگیر، از داده محلی استفاده کن
  }
}

// Provider برای کتاب‌های صوتی
final audioBooksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchAudioBooks();
});

// Provider برای جستجو
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Book>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  final api = ref.read(apiServiceProvider);
  return api.searchBooks(query);
});

// Provider برای کتاب‌های مورد علاقه
final favoriteBooksProvider = Provider<List<Book>>((ref) {
  final books = ref.watch(booksProvider).valueOrNull ?? [];
  final profile = LocalStorageService.getProfile();
  if (profile == null) return [];
  return books.where((b) => profile.favoriteBookIds.contains(b.id)).toList();
});