import 'package:flutter/material.dart';
import '../../models/produit.dart'; 
import '../../services/product_service.dart'; 

class ProduitScreen extends StatefulWidget {
  const ProduitScreen({Key? key}) : super(key: key);

  @override
  State<ProduitScreen> createState() => _ProduitScreenState();
}

class _ProduitScreenState extends State<ProduitScreen> {
  final _nomController = TextEditingController();
  final _codeBarreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixAchatController = TextEditingController();
  final _prixVenteController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _seuilController = TextEditingController(text: '5');
  
  String _categorieSelectionnee = 'Alimentation';
  final List<String> _categories = ['Alimentation', 'Entretien', 'Hygiène', 'Boissons'];

  List<Produit> _listeProduits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerProduits();
  }

  // 🔄 LECTURE : Utilisation de votre fonction `tous()`
  Future<void> _chargerProduits() async {
    setState(() => _isLoading = true);
    try {
      final produits = await ProductService.tous(); // <--- CORRIGÉ ICI
      setState(() {
        _listeProduits = produits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement : $e')),
      );
    }
  }

  // ➕ AJOUT : Utilisation de votre fonction `ajouter()`
  Future<void> _ajouterProduit() async {
    if (_nomController.text.isEmpty || _prixVenteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le nom et le prix de vente.')),
      );
      return;
    }

    final nouveauProduit = Produit(
      nom: _nomController.text,
      codeBarre: _codeBarreController.text,
      categorie: _categorieSelectionnee,
      prixAchat: double.tryParse(_prixAchatController.text) ?? 0.0,
      prixVente: double.tryParse(_prixVenteController.text) ?? 0.0,
      quantite: int.tryParse(_stockController.text) ?? 0,
      seuilAlerte: int.tryParse(_seuilController.text) ?? 5,
    );

    try {
      await ProductService.ajouter(nouveauProduit); // <--- CORRIGÉ ICI
      await _chargerProduits(); // On recharge la liste immédiatement

      _nomController.clear();
      _codeBarreController.clear();
      _descriptionController.clear();
      _prixAchatController.clear();
      _prixVenteController.clear();
      _stockController.text = '0';
      _seuilController.text = '5';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit ajouté avec succès !'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout : $e')),
      );
    }
  }

  // 🗑️ SUPPRESSION : Utilisation de votre fonction `supprimer()`
  Future<void> _supprimerProduit(String id) async {
    try {
      await ProductService.supprimer(id); // <--- CORRIGÉ ICI
      await _chargerProduits(); // Mise à jour immédiate
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Gestion des produits", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= FORMULAIRE =================
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '+ Nouveau produit',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16.0,
                      runSpacing: 16.0,
                      children: [
                        _buildTextField("Nom", _nomController, isDesktop),
                        _buildTextField("Code-barre", _codeBarreController, isDesktop),
                        _buildTextField("Description", _descriptionController, isDesktop),
                        SizedBox(
                          width: isDesktop ? 350 : double.infinity,
                          child: DropdownButtonFormField<String>(
                            value: _categorieSelectionnee,
                            decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
                            items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                            onChanged: (val) => setState(() => _categorieSelectionnee = val!),
                          ),
                        ),
                        _buildTextField("Prix achat", _prixAchatController, isDesktop, isNumber: true),
                        _buildTextField("Prix vente", _prixVenteController, isDesktop, isNumber: true),
                        _buildTextField("Stock", _stockController, isDesktop, isNumber: true),
                        _buildTextField("Seuil alerte", _seuilController, isDesktop, isNumber: true),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.photo),
                      label: const Text("Choisir une photo"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _ajouterProduit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================= LISTE DES PRODUITS =================
            const Text(
              'Liste des produits',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(const Color(0xFF2C3E50)),
                        headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        columns: const [
                          DataColumn(label: Text('PHOTO')),
                          DataColumn(label: Text('NOM')),
                          DataColumn(label: Text('CATÉGORIE')),
                          DataColumn(label: Text('PRIX ACHAT')),
                          DataColumn(label: Text('PRIX VENTE')),
                          DataColumn(label: Text('STOCK')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: _listeProduits.map((produit) {
                          return DataRow(cells: [
                            const DataCell(Icon(Icons.inventory, color: Colors.grey, size: 30)),
                            DataCell(Text(produit.nom, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(produit.categorie ?? 'Non définie')),
                            DataCell(Text('${produit.prixAchat.toStringAsFixed(0)} Fcfa')),
                            DataCell(Text('${produit.prixVente.toStringAsFixed(0)} Fcfa')),
                            DataCell(Text(produit.quantite.toString())),
                            DataCell(
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                                    child: const Text('Modifier'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => _supprimerProduit(produit.id!), 
                                    style: TextButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                                    child: const Text('Suppr.'),
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isDesktop, {bool isNumber = false}) {
    return SizedBox(
      width: isDesktop ? 350 : double.infinity,
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}