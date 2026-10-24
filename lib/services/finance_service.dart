import 'database_service.dart';

class FinanceService {
  // 1. Calcul du solde de la caisse
  static Future<double> soldeCaisse() async {
    final ca = await chiffreAffaires();
    final dep = await totalDepenses();
    final db = await DatabaseService.database;
    
    double totalRecharges = 0;
    try {
      final r1 = await db.rawQuery('SELECT SUM(montant) as t FROM recharges');
      totalRecharges = (r1.first['t'] as num?)?.toDouble() ?? 0;
    } catch (e) { print("Erreur recharges: $e"); }
    
    return totalRecharges + ca - dep;
  }

  // 2. Chiffre d'affaires (Total des ventes)
  static Future<double> chiffreAffaires() async {
    final db = await DatabaseService.database;
    try {
      final r = await db.rawQuery('SELECT SUM(montant_total) as t FROM ventes');
      return (r.first['t'] as num?)?.toDouble() ?? 0;
    } catch (e) {
      print("Erreur CA: $e");
      return 0;
    }
  }

  // 3. Total des dépenses
  static Future<double> totalDepenses() async {
    final db = await DatabaseService.database;
    try {
      final r = await db.rawQuery('SELECT SUM(montant) as t FROM depenses');
      return (r.first['t'] as num?)?.toDouble() ?? 0;
    } catch (e) {
      print("Erreur depenses: $e");
      return 0;
    }
  }

  // 4. Bénéfice (CA - Dépenses)
  static Future<double> benefice() async {
    final ca = await chiffreAffaires();
    final dep = await totalDepenses();
    return ca - dep;
  }

  // 5. Récupérer les 5 dernières ventes pour l'affichage
  static Future<List<Map<String, dynamic>>> dernieresVentes() async {
    final db = await DatabaseService.database;
    return await db.query('ventes', orderBy: 'date DESC', limit: 5);
  }

  // 6. Ajouter une recharge
  static Future<void> recharger(double montant, String description) async {
    final db = await DatabaseService.database;
    await db.insert('recharges', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'montant': montant,
      'description': description,
      'date': DateTime.now().toIso8601String(),
    });
  }

  // 7. Ajouter une dépense
  static Future<void> depenser(double montant, String description) async {
    final db = await DatabaseService.database;
    await db.insert('depenses', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'montant': montant,
      'description': description,
      'date': DateTime.now().toIso8601String(),
    });
  }

  // 8. Ajouter une vente
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