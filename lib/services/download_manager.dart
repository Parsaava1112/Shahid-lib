import 'package:background_downloader/background_downloader.dart';
import '../models/book.dart';
import 'local_storage.dart';

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  Future<void> init() async {
    FileDownloader().registerCallbacks(
      taskNotificationTapCallback: _onNotificationTap,
    );

    FileDownloader().updates.listen((update) {
      switch (update) {
        case TaskStatusUpdate _:
          // می‌توانی وضعیت دانلود را اینجا مدیریت کنی
          break;
        case TaskProgressUpdate _:
          // پیشرفت دانلود
          break;
      }
    });
  }

  Future<bool> downloadBook(Book book, {bool isAudio = false}) async {
    final url = isAudio ? book.audioUrl : book.pdfUrl;
    if (url == null) return false;

    final task = DownloadTask(
      url: url,
      filename: isAudio ? '${book.id}.mp3' : '${book.id}.pdf',
      directory: 'books',
      updates: Updates.statusAndProgress,
      retries: 3,
      allowPause: true,
    );

    final result = await FileDownloader().download(task);
    if (result.status == TaskStatus.complete) {
      final filePath = await task.filePath();
      await LocalStorageService.saveDownloadPath(
        book.id, filePath, isAudio ? 'audio' : 'pdf',
      );
      return true;
    }
    return false;
  }

  Future<void> pauseDownload(String taskId) async {
    await FileDownloader().pause(taskId);
  }

  Future<void> resumeDownload(String taskId) async {
    await FileDownloader().resume(taskId);
  }

  void _onNotificationTap(Task task, NotificationType type) {
    // باز کردن فایل هنگام کلیک روی نوتیفیکیشن
  }
}