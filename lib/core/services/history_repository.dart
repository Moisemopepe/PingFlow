import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/diagnostic_models.dart';

class HistoryRepository extends ChangeNotifier {
  HistoryRepository();

  final List<HistoryItem> _items = [];
  Database? _database;

  List<HistoryItem> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final database = await _db();
    final rows = await database.query(
      'history',
      orderBy: 'created_at DESC',
      limit: 100,
    );
    _items
      ..clear()
      ..addAll(rows.map(_fromRow));
    notifyListeners();
  }

  Future<void> add(HistoryItem item) async {
    final database = await _db();
    final id = await database.insert('history', _toRow(item));
    _items.insert(
      0,
      HistoryItem(
        id: id,
        type: item.type,
        title: item.title,
        subtitle: item.subtitle,
        result: item.result,
        createdAt: item.createdAt,
      ),
    );
    notifyListeners();
  }

  Future<void> clear() async {
    final database = await _db();
    await database.delete('history');
    _items.clear();
    notifyListeners();
  }

  Future<Database> _db() async {
    if (_database != null) return _database!;
    final root = await getDatabasesPath();
    final path = p.join(root, 'pingflow.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            subtitle TEXT NOT NULL,
            result TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Map<String, Object?> _toRow(HistoryItem item) {
    return {
      'type': item.type.name,
      'title': item.title,
      'subtitle': item.subtitle,
      'result': item.result,
      'created_at': item.createdAt.toIso8601String(),
    };
  }

  HistoryItem _fromRow(Map<String, Object?> row) {
    return HistoryItem(
      id: row['id'] as int?,
      type: DiagnosticType.values.firstWhere(
        (type) => type.name == row['type'],
        orElse: () => DiagnosticType.ping,
      ),
      title: row['title'] as String,
      subtitle: row['subtitle'] as String,
      result: row['result'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
