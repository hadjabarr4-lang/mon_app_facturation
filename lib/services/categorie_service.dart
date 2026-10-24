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
    final data = c.toMap();
    // 👇 C'est cette ligne qui manquait pour générer l'ID unique !
    data['id'] = DateTime.now().millisecondsSinceEpoch.toString(); 
    await db.insert('categories', data);
  }

  static Future<void> supprimer(String id) async {
    final db = await DatabaseService.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}