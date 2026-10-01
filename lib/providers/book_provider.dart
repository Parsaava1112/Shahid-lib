// lib/providers/book_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../repositories/book_repository.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final bookRepositoryProvider = Provider<BookRepository>((ref) => BookRepository());

/// FutureProvider برای لیست کتاب‌ها (آفلاین-اول)
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final repository = ref.read(bookRepositoryProvider);

  // ابتدا از دیتابیس محلی بخوان
  final localBooks = await repository.getAllBooks();
  if (localBooks.isNotEmpty) {
    // در پس‌زمینه از سرور به‌روزرسانی کن
    _refreshBooksFromServer(api, repository, ref);
    return localBooks;
  }

  // اگر دیتابیس خالی بود، از سرور بگیر
  final books = await api.fetchBooks();
  await repository.saveAllBooks(books);
  return books;
});

Future<void> _refreshBooksFromServer(
  ApiService api,
  BookRepository repository,
  Ref ref,
) async {
  try {
    final books = await api.fetchBooks();
    await repository.saveAllBooks(books);
    ref.invalidateSelf();
  } catch (_) {
    // خطا را نادیده بگیر، از داده محلی استفاده کن
  }
}

/// کتاب‌های صوتی
final audioBooksProvider = FutureProvider<List<Book>>((ref) async {
  final repository = ref.read(bookRepositoryProvider);
  return repository.getAudioBooks();
});

/// جستجو
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<Book>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];
  final repository = ref.read(bookRepositoryProvider);
  return repository.searchBooks(query);
});

/// کتاب‌های مورد علاقه
final favoriteBooksProvider = FutureProvider<List<Book>>((ref) async {
  final books = await ref.watch(booksProvider.future);
  // در اینجا می‌توانید از ProfileRepository استفاده کنید
  return books.where((b) => true).toList(); // منطق خود را پیاده کنید
});