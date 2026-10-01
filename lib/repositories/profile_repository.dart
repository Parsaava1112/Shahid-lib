// lib/repositories/profile_repository.dart

import '../models/user_profile.dart';
import '../services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ProfileRepository {
  /// ذخیره یا به‌روزرسانی پروفایل
  Future<void> saveProfile(UserProfile profile) async {
    final db = await DatabaseService.database;
    await db.insert(
      DatabaseService.tableProfile,
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// دریافت پروفایل
  Future<UserProfile?> getProfile() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      DatabaseService.tableProfile,
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  /// حذف پروفایل
  Future<void> deleteProfile() async {
    final db = await DatabaseService.database;
    await db.delete(DatabaseService.tableProfile);
  }
}