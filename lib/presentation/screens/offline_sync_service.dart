import 'dart:convert';
import 'package:flutter_offline_sync_manager/flutter_offline_sync_manager.dart';
import '../core/database/db_helper.dart';

class OfflineSyncService {
  static final OfflineSyncService _instance = OfflineSyncService._();
  factory OfflineSyncService() => _instance;
  OfflineSyncService._();

  late OfflineSyncManager _syncManager;

  Future<void> initialize() async {
    _syncManager = OfflineSyncManager(
      config: OfflineSyncConfig(
        baseUrl: 'https://api.fanoosy.ir/api',
        syncInterval: const Duration(minutes: 5),
        maxRetries: 5,
        conflictResolution: ConflictResolution.serverWins,
      ),
    );
    await _syncManager.initialize();
  }

  Future<void> syncPendingOperations() async {
    final queue = await DBHelper.getSyncQueue();
    for (final item in queue) {
      try {
        final payload = jsonDecode(item['payload']);
        final success = await _syncManager.syncOperation(
          operation: item['operation'],
          payload: payload,
        );
        if (success) {
          await DBHelper.removeFromSyncQueue(item['id']);
        }
      } catch (e) {
        debugPrint('Sync error: $e');
      }
    }
  }
}