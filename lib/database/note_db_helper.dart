import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';
import 'dart:io';

class NoteDatabaseHelper {

  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
      CREATE TABLE notes (
        id $idType,
        title $textType,
        content $textType,
        date $textType,
        isPinned $boolType DEFAULT 0
      )
    ''');


    await db.insert('notes', {
      'title': 'Welcome to MySimpleNote',
      'content': 'This is your first note! Feel free to edit, delete, or pin it.',
      'date': DateTime.now().toString(),
      'isPinned': 1,
    });

    await db.insert('notes', {
      'title': 'Shopping List',
      'content': '1. Apples\n2. Bananas\n3. Milk\n4. Bread',
      'date': DateTime.now().toString(),
      'isPinned': 0,
    });

    await db.insert('notes', {
      'title': 'Meeting Notes',
      'content': 'Discuss project deadlines, milestones, and team responsibilities.',
      'date': DateTime.now().toString(),
      'isPinned': 0,
    });

    await db.insert('notes', {
      'title': 'Reminder',
      'content': 'Remember to call John tomorrow regarding the meeting schedule.',
      'date': DateTime.now().toString(),
      'isPinned': 0,
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('ALTER TABLE notes ADD COLUMN isPinned BOOLEAN NOT NULL DEFAULT 0');
    }
  }

  Future<int> create(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    const orderBy = 'isPinned DESC, date DESC';
    final result = await db.query('notes', orderBy: orderBy);
    return result.map((json) => Note.fromMap(json)).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;
    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
