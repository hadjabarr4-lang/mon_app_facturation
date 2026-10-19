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
      version: 1,
      onCreate: (db, version) async {
        // ---------- TABLE UTILISATEURS ----------
        await db.execute('''
          CREATE TABLE utilisateurs(
            id TEXT PRIMARY KEY,
            nom TEXT,
            email TEXT UNIQUE,
            mot_de_passe TEXT,
            role TEXT
          )
        ''');

        // ---------- TABLE PRODUITS ----------
        await db.execute('''
          CREATE TABLE produits(
            id TEXT PRIMARY KEY,
            nom TEXT NOT NULL,
            code_barre TEXT UNIQUE,
            image_path TEXT,
            prix_achat REAL DEFAULT 0,
            prix_vente REAL DEFAULT 0,
            quantite INTEGER DEFAULT 0,
            seuil_alerte INTEGER DEFAULT 5,
            categorie TEXT,
            date_creation TEXT
          )
        ''');

        // ---------- TABLE CLIENTS ----------
        await db.execute('''
          CREATE TABLE clients(
            id TEXT PRIMARY KEY,
            nom TEXT,
            telephone TEXT,
            adresse TEXT,
            date_creation TEXT
          )
        ''');

        // ---------- TABLE VENTES ----------
        await db.execute('''
          CREATE TABLE ventes(
            id TEXT PRIMARY KEY,
            numero TEXT UNIQUE,
            client_id TEXT,
            client_nom TEXT,
            type_vente TEXT,
            mode_paiement TEXT,
            montant_total REAL,
            acompte REAL DEFAULT 0,
            reste_a_payer REAL DEFAULT 0,
            statut TEXT,
            remarque TEXT,
            date TEXT
          )
        ''');

        // ---------- TABLE LIGNES DE VENTE ----------
        await db.execute('''
          CREATE TABLE lignes_vente(
            id TEXT PRIMARY KEY,
            vente_id TEXT,
            produit_id TEXT,
            produit_nom TEXT,
            prix_unitaire REAL,
            quantite INTEGER,
            total REAL
          )
        ''');

        // ---------- TABLE DÉPENSES ----------
        await db.execute('''
          CREATE TABLE depenses(
            id TEXT PRIMARY KEY,
            description TEXT,
            montant REAL,
            categorie TEXT,
            date TEXT
          )
        ''');

        // ---------- TABLE RECHARGES (Solde caisse) ----------
        await db.execute('''
          CREATE TABLE recharges(
            id TEXT PRIMARY KEY,
            montant REAL,
            description TEXT,
            date TEXT
          )
        ''');
      },
    );
  }
}