import '../models/utilisateur.dart';
import 'database_service.dart';

class UtilisateurService {
  static Future<List<Utilisateur>> tous() async {
    final db = await DatabaseService.database;
    final rows = await db.query('utilisateurs');
    return rows.map((r) => Utilisateur.fromMap(r)).toList();
  }

  static Future<void> ajouter(Utilisateur u) async {
    final db = await DatabaseService.database;
    final data = u.toMap();
    data['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insert('utilisateurs', data);
  }

  static Future<void> supprimer(String id) async {
    final db = await DatabaseService.database;
    await db.delete('utilisateurs', where: 'id = ?', whereArgs: [id]);
  }
}