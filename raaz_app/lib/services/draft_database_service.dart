import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

/// Local SQLite storage for drafts only.
/// PRD Section 10: Drafts are NEVER synced to Supabase until published.
/// Max 10 active drafts per device.
class DraftDatabaseService {
  static Database? _db;
  static const int _maxDrafts = 10;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'raaz_drafts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE drafts (
            id          TEXT PRIMARY KEY,
            body        TEXT NOT NULL,
            category_id TEXT,
            mood        TEXT,
            created_at  TEXT NOT NULL,
            updated_at  TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ─── Save / upsert draft ─────────────────────────────────────
  static Future<void> saveDraft({
    required String id,
    required String body,
    String? categoryId,
    String? mood,
  }) async {
    final database = await db;
    final now = DateTime.now().toIso8601String();

    await database.insert(
      'drafts',
      {
        'id': id,
        'body': body,
        'category_id': categoryId,
        'mood': mood,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Enforce 10-draft limit: remove oldest if exceeded
    final count = await getDraftCount();
    if (count > _maxDrafts) {
      await database.rawDelete('''
        DELETE FROM drafts WHERE id IN (
          SELECT id FROM drafts ORDER BY created_at ASC LIMIT ${count - _maxDrafts}
        )
      ''');
    }
  }

  // ─── Get all drafts ──────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getAllDrafts() async {
    final database = await db;
    return await database.query('drafts', orderBy: 'updated_at DESC');
  }

  // ─── Delete single draft ─────────────────────────────────────
  static Future<void> deleteDraft(String id) async {
    final database = await db;
    await database.delete('drafts', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Clear all drafts ────────────────────────────────────────
  static Future<void> clearAllDrafts() async {
    final database = await db;
    await database.delete('drafts');
  }

  // ─── Draft count ─────────────────────────────────────────────
  static Future<int> getDraftCount() async {
    final database = await db;
    final result = await database.rawQuery('SELECT COUNT(*) FROM drafts');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
