import 'package:flutter/material.dart';
import '../../services/finance_service.dart';
import '../vente/vente_screen.dart';
class AccueilScreen extends StatefulWidget {
  const AccueilScreen({Key? key}) : super(key: key);

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  double _solde = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() => _isLoading = true);
    try {
      final s = await FinanceService.soldeCaisse();
      setState(() {
        _solde = s;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Erreur chargement : $e");
    }
  }

  // Fonction générique pour afficher la fenêtre de saisie
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
                  // On appelle la bonne fonction selon le bouton cliqué
                  if (action == 'recharger') {
                    await FinanceService.recharger(m, 'Recharge manuelle');
                  } else if (action == 'depense') {
                    await FinanceService.depenser(m, 'Dépense manuelle');
                  } else if (action == 'vendre') {
                    await FinanceService.vendre(m, 'Espèces');
                  }
                  
                  ctrl.clear();
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  _charger(); // Rafraîchir le solde
                  
                } catch (e) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Erreur DB : $e')),
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
        title: const Text("Accueil", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // CARTE SOLDE
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
                  
                  // BOUTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionBtn("Recharger", Icons.add_card, Colors.green, () => _afficherFenetre('Recharger la caisse', 'recharger')),
                      _buildActionBtn(
  "Vendre", 
  Icons.point_of_sale, 
  Colors.blue, 
  () async {
    // On ouvre le grand écran de vente
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VenteScreen()), 
    );
    // On met à jour le solde en revenant
    _charger(); 
  }
),
                      _buildActionBtn("Dépense", Icons.receipt_long, Colors.orange, () => _afficherFenetre('Nouvelle dépense', 'depense')),
                    ],
                  ),
                  
                  const SizedBox(height: 30),
                  const Text("Ventes récentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildActionBtn(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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