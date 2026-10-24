import '../models/achat.dart';
import 'database_service.dart';

class AchatService {
  // Enregistrer un achat, augmenter le stock et baisser la caisse
  static Future<void> enregistrerAchat(Achat achat) async {
    final db = await DatabaseService.database;
    
    // 1. Enregistrer l'achat
    await db.insert('achats', achat.toMap());
    
    // 2. Augmenter le stock du produit et mettre à jour son prix d'achat
    await db.rawUpdate(
      'UPDATE produits SET quantite = quantite + ?, prix_achat = ? WHERE id = ?',
      [achat.quantite, achat.prixUnitaire, achat.produitId]
    );

    // 3. Enregistrer la dépense dans la caisse (pour que le solde baisse)
    await db.insert('depenses', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'montant': achat.total,
      'description': 'Achat: ${achat.produitNom}',
      'date': achat.date,
    });
  }

  // Récupérer l'historique des achats
  static Future<List<Achat>> tousLesAchats() async {
    final db = await DatabaseService.database;
    final rows = await db.query('achats', orderBy: 'date DESC');
    return rows.map((r) => Achat.fromMap(r)).toList();
  }
}