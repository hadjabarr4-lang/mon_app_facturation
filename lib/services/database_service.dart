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
      version: 3, // <--- Version 3
      onCreate: (db, version) async {
        // 1. Table Utilisateurs
        await db.execute('''
          CREATE TABLE utilisateurs(
            id TEXT PRIMARY KEY,
            nom TEXT,
            email TEXT UNIQUE
          )
        ''');

        // 2. Table Produits
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

        // 3. Table Categories
        await db.execute('''
          CREATE TABLE categories(
            id TEXT PRIMARY KEY,
            nom TEXT,
            description TEXT
          )
        ''');

        // 4. Table Recharges
        await db.execute('''
          CREATE TABLE recharges(
            id TEXT PRIMARY KEY,
            montant REAL,
            description TEXT,
            date TEXT
          )
        ''');

        // 5. Table Depenses
        await db.execute('''
          CREATE TABLE depenses(
            id TEXT PRIMARY KEY,
            montant REAL,
            description TEXT,
            date TEXT
          )
        ''');

        // 6. Table Ventes
        await db.execute('''
          CREATE TABLE ventes(
            id TEXT PRIMARY KEY,
            montant_total REAL,
            mode_paiement TEXT,
            date TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE categories(
              id TEXT PRIMARY KEY,
              nom TEXT,
              description TEXT
            )
          ''');
        }
        
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE recharges(
              id TEXT PRIMARY KEY,
              montant REAL,
              description TEXT,
              date TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE depenses(
              id TEXT PRIMARY KEY,
              montant REAL,
              description TEXT,
              date TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE ventes(
              id TEXT PRIMARY KEY,
              montant_total REAL,
              mode_paiement TEXT,
              date TEXT
            )
          ''');
        }
      },
    );
  }
}