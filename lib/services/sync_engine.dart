import 'package:local_first/local_first.dart';
import '../models/book.dart';

class SyncEngine {
  static final SyncEngine _instance = SyncEngine._internal();
  factory SyncEngine() => _instance;
  SyncEngine._internal();

  late final LocalFirst _localFirst;

  Future<void> init() async {
    _localFirst = LocalFirst(
      storage: HiveStorageAdapter(),
      syncStrategy: RestSyncStrategy(
        baseUrl: 'https://api.fanoosy.ir/api',
      ),
    );
    await _localFirst.initialize();
  }

  /// هر کتاب را به صورت یک رویداد ذخیره می‌کند
  Future<void> saveBook(Book book) async {
    await _localFirst.repository<Book>('books').upsert(book);
  }

  /// دریافت همه کتاب‌ها (آفلاین از Hive می‌خواند)
  Stream<List<Book>> watchBooks() {
    return _localFirst.repository<Book>('books').watchAll();
  }

  /// همگام‌سازی دستی با سرور
  Future<void> sync() async {
    await _localFirst.sync();
  }
}