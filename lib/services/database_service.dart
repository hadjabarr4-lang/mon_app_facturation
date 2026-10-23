import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'mon_app.db');
    return await openDatabase(
      path,
      version: 2, // <--- Version 2 pour forcer la mise à jour
      onCreate: (db, version) async {
        // Table Utilisateurs
        await db.execute('''
          CREATE TABLE utilisateurs(
            id TEXT PRIMARY KEY,
            nom TEXT,
            email TEXT UNIQUE
          )
        ''');

        // Table Produits
        await db.execute('''
          CREATE TABLE produits(
            id TEXT PRIMARY KEY,
            nom TEXT,
            code_barre TEXT,
            image_path TEXT,
            prix_achat REAL,
            prix_vente REAL,
            quantite INTEGER,
            seuil_alerte INTEGER,
            categorie TEXT,
            date_creation TEXT
          )
        ''');

        // Table Categories (NOUVELLE)
        await db.execute('''
          CREATE TABLE categories(
            id TEXT PRIMARY KEY,
            nom TEXT,
            description TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Si l'utilisateur avait la version 1, on ajoute la table categories
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE categories(
              id TEXT PRIMARY KEY,
              nom TEXT,
              description TEXT
            )
          ''');
        }
      },
    ); // <-- Cette parenthèse ferme le openDatabase
  } // <-- Cette accolade ferme le _initDb
} // <-- Cette accolade ferme la classe DatabaseService