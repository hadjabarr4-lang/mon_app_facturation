import 'database_service.dart';

class FinanceService {
  // Calcul du solde sécurisé
  static Future<double> soldeCaisse() async {
    final db = await DatabaseService.database;
    double totalRecharges = 0;
    double totalVentes = 0;
    double totalDepenses = 0;

    try {
      final r1 = await db.rawQuery('SELECT SUM(montant) as t FROM recharges');
      totalRecharges = (r1.first['t'] as num?)?.toDouble() ?? 0;
    } catch (e) { print("Erreur recharges: $e"); }

    try {
      final r2 = await db.rawQuery('SELECT SUM(montant_total) as t FROM ventes');
      totalVentes = (r2.first['t'] as num?)?.toDouble() ?? 0;
    } catch (e) { print("Erreur ventes: $e"); }

    try {
      final r3 = await db.rawQuery('SELECT SUM(montant) as t FROM depenses');
      totalDepenses = (r3.first['t'] as num?)?.toDouble() ?? 0;
    } catch (e) { print("Erreur depenses: $e"); }

    return totalRecharges + totalVentes - totalDepenses;
  }

  // Ajouter une recharge
  static Future<void> recharger(double montant, String description) async {
    final db = await DatabaseService.database;
    await db.insert('recharges', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'montant': montant,
      'description': description,
      'date': DateTime.now().toIso8601String(),
    });
  }

  // Ajouter une dépense
  static Future<void> depenser(double montant, String description) async {
    final db = await DatabaseService.database;
    await db.insert('depenses', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'montant': montant,
      'description': description,
      'date': DateTime.now().toIso8601String(),
    });
  }

  // Ajouter une vente (simplifiée)
  static Future<void> vendre(double montantTotal, String modePaiement) async {
    final db = await DatabaseService.database;
    await db.insert('ventes', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'montant_total': montantTotal,
      'mode_paiement': modePaiement,
      'date': DateTime.now().toIso8601String(),
    });
  }
}