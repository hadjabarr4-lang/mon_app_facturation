import 'package:uuid/uuid.dart';
import '../models/produit.dart';
import 'database_service.dart';

class ProductService {
  static const _uuid = Uuid();

  static Future<void> ajouter(Produit p) async {
    final db = await DatabaseService.database;
    final data = p.toMap();
    data['id'] = _uuid.v4();
    await db.insert('produits', data);
  }

  static Future<List<Produit>> tous() async {
    final db = await DatabaseService.database;
    final rows = await db.query('produits', orderBy: 'nom ASC');
    return rows.map((r) => Produit.fromMap(r)).toList();
  }

  static Future<Produit?> parCodeBarre(String code) async {
    final db = await DatabaseService.database;
    final rows = await db.query('produits', where: 'code_barre = ?', whereArgs: [code]);
    if (rows.isEmpty) return null;
    return Produit.fromMap(rows.first);
  }

  static Future<void> miseAJourQuantite(String id, int nouvelleQuantite) async {
    final db = await DatabaseService.database;
    await db.update('produits', {'quantite': nouvelleQuantite}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> supprimer(String id) async {
    final db = await DatabaseService.database;
    await db.delete('produits', where: 'id = ?', whereArgs: [id]);
  }
}