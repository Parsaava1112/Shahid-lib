// lib/providers/book_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// ─────────────────────────────────────────
//  FutureProvider برای لیست کتاب‌ها
// ─────────────────────────────────────────

final booksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);

  // ابتدا از ReaxDB بخوان (آفلاین-اول)
  final localBooks = await LocalStorageService.getAllBooks();
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

Future<void> _refreshBooksFromServer(ApiService api, Ref ref) async {
  try {
    final books = await api.fetchBooks();
    await LocalStorageService.saveBooks(books);
    ref.invalidateSelf();
  } catch (_) {
    // خطا را نادیده بگیر، از داده محلی استفاده کن
  }
}

// ─────────────────────────────────────────
//  کتاب‌های صوتی
// ─────────────────────────────────────────

final audioBooksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return api.fetchAudioBooks();
});

// ─────────────────────────────────────────
//  جستجو
// ─────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Book>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  final api = ref.read(apiServiceProvider);
  return api.searchBooks(query);
});

// ─────────────────────────────────────────
//  کتاب‌های مورد علاقه
// ─────────────────────────────────────────

final favoriteBooksProvider = FutureProvider<List<Book>>((ref) async {
  final books = await ref.watch(booksProvider.future);
  final profile = await LocalStorageService.getProfileAsync();
  if (profile == null) return [];
  return books.where((b) => profile.favoriteBookIds.contains(b.id)).toList();
});