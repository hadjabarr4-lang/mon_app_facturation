import 'package:flutter/material.dart';
import '../../models/achat.dart';
import '../../models/produit.dart';
import '../../services/achat_service.dart';
import '../../services/product_service.dart';

class AchatScreen extends StatefulWidget {
  const AchatScreen({Key? key}) : super(key: key);

  @override
  State<AchatScreen> createState() => _AchatScreenState();
}

class _AchatScreenState extends State<AchatScreen> {
  List<Produit> _produits = [];
  List<Achat> _achats = [];
  bool _isLoading = true;

  Produit? _produitSelectionne;
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();
  final _fournisseurController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);
    final prods = await ProductService.tous();
    final achats = await AchatService.tousLesAchats();
    setState(() {
      _produits = prods;
      _achats = achats;
      _isLoading = false;
    });
  }

  Future<void> _enregistrerAchat() async {
    if (_produitSelectionne == null || _quantiteController.text.isEmpty || _prixController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    final qte = int.tryParse(_quantiteController.text) ?? 0;
    final prixU = double.tryParse(_prixController.text) ?? 0.0;

    if (qte <= 0 || prixU <= 0) return;

    final nouvelAchat = Achat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      produitId: _produitSelectionne!.id!,
      produitNom: _produitSelectionne!.nom,
      quantite: qte,
      prixUnitaire: prixU,
      total: qte * prixU,
      fournisseur: _fournisseurController.text.isEmpty ? 'Inconnu' : _fournisseurController.text,
      date: DateTime.now().toIso8601String(),
    );

    try {
      await AchatService.enregistrerAchat(nouvelAchat);
      _quantiteController.clear();
      _prixController.clear();
      _fournisseurController.clear();
      setState(() => _produitSelectionne = null);
      await _chargerDonnees(); 

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Achat enregistré et stock mis à jour !'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Achats", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E2C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          DropdownButtonFormField<Produit>(
                            value: _produitSelectionne,
                            decoration: const InputDecoration(labelText: 'Produit', border: OutlineInputBorder()),
                            items: _produits.map((p) => DropdownMenuItem(value: p, child: Text(p.nom))).toList(),
                            onChanged: (val) => setState(() => _produitSelectionne = val),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: TextField(controller: _quantiteController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantité', border: OutlineInputBorder()))),
                              const SizedBox(width: 12),
                              Expanded(child: TextField(controller: _prixController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix achat', border: OutlineInputBorder()))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(controller: _fournisseurController, decoration: const InputDecoration(labelText: 'Fournisseur', border: OutlineInputBorder())),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _enregistrerAchat,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              child: const Text('Enregistrer l\'achat'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Historique des achats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('DATE')),
                          DataColumn(label: Text('PRODUIT')),
                          DataColumn(label: Text('QTÉ')),
                          DataColumn(label: Text('TOTAL')),
                          DataColumn(label: Text('FOURNISSEUR')),
                        ],
                        rows: _achats.map((a) => DataRow(cells: [
                          DataCell(Text(a.date.substring(0, 10))),
                          DataCell(Text(a.produitNom)),
                          DataCell(Text(a.quantite.toString())),
                          DataCell(Text('${a.total.toStringAsFixed(0)} F')),
                          DataCell(Text(a.fournisseur)),
                        ])).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}