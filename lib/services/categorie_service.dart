import '../models/categorie.dart';
import 'database_service.dart';

class CategorieService {
  static Future<List<Categorie>> tous() async {
    final db = await DatabaseService.database;
    final rows = await db.query('categories', orderBy: 'nom ASC');
    return rows.map((r) => Categorie.fromMap(r)).toList();
  }

  static Future<void> ajouter(Categorie c) async {
    final db = await DatabaseService.database;
    await db.insert('categories', c.toMap());
  }

  static Future<void> supprimer(String id) async {
    final db = await DatabaseService.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}