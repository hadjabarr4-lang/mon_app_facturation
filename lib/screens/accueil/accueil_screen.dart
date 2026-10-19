import 'package:mon_app_facturation/services/database_service.dart';
import 'package:flutter/material.dart';
import '../../services/finance_service.dart';
import '../../utils/format.dart';
import '../vente/vente_screen.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({Key? key}) : super(key: key);

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  double _solde = 0;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final s = await FinanceService.soldeCaisse();
    setState(() => _solde = s);
  }

  Future<void> _recharger() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recharger la caisse'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Montant en FCFA'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final m = double.tryParse(ctrl.text) ?? 0;
              if (m > 0) {
                await FinanceService.recharger(m, 'Recharge manuelle');
                Navigator.pop(context);
                _charger();
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  Future<void> _depense() async {
    final desc = TextEditingController();
    final montant = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nouvelle dépense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: montant, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Montant FCFA')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final m = double.tryParse(montant.text) ?? 0;
              if (m > 0) {
                await FinanceService.ajouterDepense(desc.text, m, 'Général');
                Navigator.pop(context);
                _charger();
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Accueil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _charger,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte Solde
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SOLDE CAISSE', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(Fmt.fcfa(_solde), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Boutons d'action
              Row(
                children: [
                  _actionButton(Icons.add_card, 'Recharger', Colors.green, _recharger),
                  const SizedBox(width: 10),
                  _actionButton(Icons.point_of_sale, 'Vendre', Colors.blue, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VenteScreen()));
                  }),
                  const SizedBox(width: 10),
                  _actionButton(Icons.receipt, 'Dépense', Colors.orange, _depense),
                ],
              ),
              const SizedBox(height: 25),

              // Zone de recherche
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit ou une vente...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              const Text('Ventes récentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _ventesRecentes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ventesRecentes() {
    return FutureBuilder(
      future: () async {
        final db = await DatabaseService.database;
        return db.query('ventes', orderBy: 'date DESC', limit: 5);
      }(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final ventes = snap.data as List<Map<String, dynamic>>;
        if (ventes.isEmpty) {
          return const Padding(padding: EdgeInsets.all(20), child: Text('Aucune vente pour le moment'));
        }
        return Column(
          children: ventes.map((v) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${v['client_nom']?.toString().substring(0, 1) ?? '?'}')),
              title: Text(v['client_nom'] ?? 'Client'),
              subtitle: Text(v['type_vente'] ?? ''),
              trailing: Text(Fmt.fcfa((v['montant_total'] as num?) ?? 0), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )).toList(),
        );
      },
    );
  }
}