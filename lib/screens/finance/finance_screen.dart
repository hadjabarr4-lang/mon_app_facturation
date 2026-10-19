import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/finance_service.dart';
import '../../utils/format.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({Key? key}) : super(key: key);
  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  double _ca = 0, _dep = 0, _ben = 0;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final ca = await FinanceService.chiffreAffaires();
    final dep = await FinanceService.totalDepenses();
    final ben = await FinanceService.benefice();
    setState(() { _ca = ca; _dep = dep; _ben = ben; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Finance', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _charger,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _carte('Chiffre d\'affaires', _ca, Colors.blue, Icons.trending_up),
              const SizedBox(height: 12),
              _carte('Dépenses', _dep, Colors.orange, Icons.trending_down),
              const SizedBox(height: 12),
              _carte('Bénéfice', _ben, _ben >= 0 ? Colors.green : Colors.red, Icons.account_balance_wallet),
              const SizedBox(height: 25),
              const Align(alignment: Alignment.centerLeft, child: Text('Historique des transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              _historique(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carte(String titre, double montant, Color couleur, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: couleur.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icone, color: couleur)),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titre, style: const TextStyle(color: Colors.grey)),
            Text(Fmt.fcfa(montant), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: couleur)),
          ])),
        ],
      ),
    );
  }

  Widget _historique() {
    return FutureBuilder(
      future: () async {
        final db = await DatabaseService.database;
        final ventes = await db.query('ventes', orderBy: 'date DESC', limit: 20);
        final depenses = await db.query('depenses', orderBy: 'date DESC', limit: 20);
        final liste = <Map<String, dynamic>>[];
        for (var v in ventes) {
          liste.add({'type': 'Vente', 'label': v['client_nom'], 'montant': v['montant_total'], 'date': v['date'], 'color': Colors.green});
        }
        for (var d in depenses) {
          liste.add({'type': 'Dépense', 'label': d['description'], 'montant': d['montant'], 'date': d['date'], 'color': Colors.red});
        }
        liste.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
        return liste;
      }(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final liste = snap.data as List<Map<String, dynamic>>;
        if (liste.isEmpty) return const Text('Aucune transaction');
        return Column(
          children: liste.map((t) => Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: (t['color'] as Color).withOpacity(0.15), child: Icon(t['type'] == 'Vente' ? Icons.arrow_upward : Icons.arrow_downward, color: t['color'])),
              title: Text(t['label'] ?? ''),
              subtitle: Text(t['type']),
              trailing: Text(Fmt.fcfa((t['montant'] as num?) ?? 0), style: TextStyle(fontWeight: FontWeight.bold, color: t['color'])),
            ),
          )).toList(),
        );
      },
    );
  }
}