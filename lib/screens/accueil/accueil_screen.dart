import 'package:flutter/material.dart';
import '../../services/finance_service.dart';
import '../vente/vente_screen.dart'; // Assurez-vous du bon chemin

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({Key? key}) : super(key: key);

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  double _solde = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _ventesRecentes = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() => _isLoading = true);
    try {
      final s = await FinanceService.soldeCaisse();
      final ventes = await FinanceService.dernieresVentes();
      setState(() {
        _solde = s;
        _ventesRecentes = ventes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Erreur chargement : $e");
    }
  }

  // Fonction pour Recharger ou Dépense
  Future<void> _afficherFenetre(String titre, String action) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(titre),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Montant en FCFA'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final m = double.tryParse(ctrl.text) ?? 0;
              if (m > 0) {
                try {
                  if (action == 'recharger') {
                    await FinanceService.recharger(m, 'Recharge manuelle');
                  } else {
                    await FinanceService.depenser(m, 'Dépense manuelle');
                  }
                  ctrl.clear();
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  _charger();
                } catch (e) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Accueil", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E2C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. CARTE SOLDE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SOLDE CAISSE',
                          style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_solde.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 2. BOUTONS D'ACTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionBtn("Recharger", Icons.add_card, Colors.green, () => _afficherFenetre('Recharger la caisse', 'recharger')),
                      _buildActionBtn("Vendre", Icons.point_of_sale, Colors.blue, () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => const VenteScreen()));
                        _charger(); // Met à jour le solde au retour
                      }),
                      _buildActionBtn("Dépense", Icons.receipt_long, Colors.orange, () => _afficherFenetre('Nouvelle dépense', 'depense')),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 3. BARRE DE RECHERCHE
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un produit ou une vente...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 4. VENTES RÉCENTES
                  const Text(
                    "Ventes récentes", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 12),
                  
                  if (_ventesRecentes.isEmpty)
                    const Center(child: Text("Aucune vente récente", style: TextStyle(color: Colors.grey)))
                  else
                    ..._ventesRecentes.map((vente) {
                      final montant = (vente['montant_total'] as num?)?.toDouble() ?? 0.0;
                      // On essaie de récupérer le mode, sinon on met 'Normal'
                      final mode = vente['mode_paiement'] ?? 'Normal'; 
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: Text(
                              mode.toString().substring(0, 1).toUpperCase(), 
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                            ),
                          ),
                          title: const Text("Vente", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(mode.toString()),
                          trailing: Text(
                            "${montant.toStringAsFixed(0)} FCFA",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }

  // Widget pour les boutons
  Widget _buildActionBtn(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}