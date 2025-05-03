import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:classfy/screens/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gestion_docs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Utilisateur (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT,
        email TEXT,
        motDePasse TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Dossier (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT,
        utilisateurId INTEGER,
        FOREIGN KEY (utilisateurId) REFERENCES Utilisateur(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Document (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT,
        type TEXT,
        contenu TEXT,
        dossierId INTEGER,
        FOREIGN KEY (dossierId) REFERENCES Dossier(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Annotation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contenu TEXT,
        date TEXT,
        documentId INTEGER,
        FOREIGN KEY (documentId) REFERENCES Document(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Partage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        utilisateurSource INTEGER,
        utilisateurCible INTEGER,
        documentPartage INTEGER,
        FOREIGN KEY (utilisateurSource) REFERENCES Utilisateur(id),
        FOREIGN KEY (utilisateurCible) REFERENCES Utilisateur(id),
        FOREIGN KEY (documentPartage) REFERENCES Document(id)
      )
    ''');

    await db.execute('''
   CREATE TABLE Task (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  titre TEXT,
  note TEXT,
  date TEXT,
  startTime TEXT,
  endTime TEXT,
  remind TEXT,
  repeat TEXT,
  color INTEGER,
  utilisateurId INTEGER,
  FOREIGN KEY (utilisateurId) REFERENCES Utilisateur(id)
)
    ''');

    await db.execute('''
      CREATE TABLE Rappel (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateHeure TEXT,
        planificationId INTEGER,
        FOREIGN KEY (planificationId) REFERENCES Planification(id)
      )
    ''');

  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> insertTask(TaskModel task) async {
    final db = await instance.database;
    return await db.insert('Task', task.toMap());
  }

  // DELETE method to remove a task from the database by its ID
  Future<int> deleteEvent(int eventId) async {
    final db = await instance.database;
    return await db.delete(
      'Task',
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  // UPDATE method to modify an existing task
  Future<int> updateEvent(TaskModel task) async {
    final db = await instance.database;
    return await db.update(
      'Task',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
