import 'database_service.dart';

class FinanceService {
  /// Chiffre d'affaires total
  static Future<double> chiffreAffaires() async {
    final db = await DatabaseService.database;
    final r = await db.rawQuery('SELECT SUM(montant_total) as t FROM ventes');
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  /// Total des dépenses
  static Future<double> totalDepenses() async {
    final db = await DatabaseService.database;
    final r = await db.rawQuery('SELECT SUM(montant) as t FROM depenses');
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  /// Bénéfice = CA - Dépenses
  static Future<double> benefice() async {
    final ca = await chiffreAffaires();
    final dep = await totalDepenses();
    return ca - dep;
  }

  /// Solde caisse = Recharges + Ventes encaissées - Dépenses
  static Future<double> soldeCaisse() async {
    final db = await DatabaseService.database;
    final r1 = await db.rawQuery('SELECT SUM(montant) as t FROM recharges');
    final r2 = await db.rawQuery('SELECT SUM(montant_total) as t FROM ventes WHERE type_vente = "normal"');
    final r3 = await db.rawQuery('SELECT SUM(montant) as t FROM depenses');
    final recharges = (r1.first['t'] as num?)?.toDouble() ?? 0;
    final ventes = (r2.first['t'] as num?)?.toDouble() ?? 0;
    final depenses = (r3.first['t'] as num?)?.toDouble() ?? 0;
    return recharges + ventes - depenses;
  }

  /// Ajouter une recharge
  static Future<void> recharger(double montant, String description) async {
    final db = await DatabaseService.database;
    await db.insert('recharges', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'montant': montant,
      'description': description,
      'date': DateTime.now().toIso8601String(),
    });
  }

  /// Ajouter une dépense
  static Future<void> ajouterDepense(String description, double montant, String categorie) async {
    final db = await DatabaseService.database;
    await db.insert('depenses', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'description': description,
      'montant': montant,
      'categorie': categorie,
      'date': DateTime.now().toIso8601String(),
    });
  }
}