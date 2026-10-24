import '../models/produit.dart';
import 'database_service.dart';

class ProductService {
  static Future<List<Produit>> tous() async {
    final db = await DatabaseService.database;
    final rows = await db.query('produits', orderBy: 'nom ASC');
    return rows.map((r) => Produit.fromMap(r)).toList();
  }

  static Future<void> ajouter(Produit p) async {
    final db = await DatabaseService.database;
    final data = p.toMap();
    data['id'] = DateTime.now().millisecondsSinceEpoch.toString(); 
    await db.insert('produits', data);
  }

  static Future<void> modifier(Produit p) async {
    final db = await DatabaseService.database;
    await db.update('produits', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  static Future<void> supprimer(String id) async {
    final db = await DatabaseService.database;
    await db.delete('produits', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> miseAJourQuantite(String id, int nouvelleQuantite) async {
    final db = await DatabaseService.database;
    await db.update('produits', {'quantite': nouvelleQuantite}, where: 'id = ?', whereArgs: [id]);
  }

  // C'est cette fonction qui manquait pour le bouton Valider
  static Future<void> deduireStock(String idProduit, int quantiteVendue) async {
    final db = await DatabaseService.database;
    await db.rawUpdate(
      'UPDATE produits SET quantite = quantite - ? WHERE id = ?',
      [quantiteVendue, idProduit]
    );
  }
}