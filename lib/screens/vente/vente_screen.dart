import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../services/finance_service.dart';
import '../../models/produit.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class VenteScreen extends StatefulWidget {
  const VenteScreen({Key? key}) : super(key: key);

  @override
  State<VenteScreen> createState() => _VenteScreenState();
}

class LigneVente {
  final Produit produit;
  int quantite;
  LigneVente(this.produit, this.quantite);
  double get total => produit.prixVente * quantite;
}

class _VenteScreenState extends State<VenteScreen> {
  // Contrôleurs
  final _clientNomController = TextEditingController();
  final _searchController = TextEditingController();
  final _acompteController = TextEditingController(text: '0');
  final _remarqueController = TextEditingController();

  // Variables d'état
  List<Produit> _produits = [];
  List<Produit> _produitsFiltres = [];
  List<LigneVente> _panier = [];
  String _modePaiement = 'Espèces';
  String _typeVente = 'Normal';

  @override
  void initState() {
    super.initState();
    _chargerProduits();
    _searchController.addListener(_filtrerProduits);
  }

  @override
  void dispose() {
    _clientNomController.dispose();
    _searchController.dispose();
    _acompteController.dispose();
    _remarqueController.dispose();
    super.dispose();
  }

  Future<void> _chargerProduits() async {
    try {
      final prods = await ProductService.tous();
      setState(() {
        _produits = prods;
        _produitsFiltres = [];
      });
    } catch (e) {
      debugPrint("Erreur de chargement des produits : $e");
    }
  }

  void _filtrerProduits() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _produitsFiltres = []);
    } else {
      setState(() {
        _produitsFiltres = _produits
            .where((p) => p.nom.toLowerCase().contains(query) && p.quantite > 0)
            .toList();
      });
    }
  }

  void _ajouterAuPanier(Produit produit) {
    setState(() {
      final index = _panier.indexWhere((item) => item.produit.id == produit.id);
      if (index != -1) {
        // Le produit est déjà dans le panier
        if (_panier[index].quantite < produit.quantite) {
          _panier[index].quantite++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stock maximum atteint pour ce produit.')),
          );
        }
      } else {
        // Nouveau produit
        _panier.add(LigneVente(produit, 1));
      }
      _searchController.clear();
      _produitsFiltres = [];
    });
  }

  double get _total {
    return _panier.fold(0, (sum, item) => sum + item.total);
  }

  double get _resteAPayer {
    final acompte = double.tryParse(_acompteController.text) ?? 0;
    final reste = _total - acompte;
    return reste < 0 ? 0 : reste;
  }

  Future<void> _validerVente() async {
    if (_panier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le panier est vide !'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      // 1. Enregistrer la vente dans la caisse
      await FinanceService.vendre(_total, _modePaiement);

      // 2. Déduire le stock pour chaque produit
      for (var item in _panier) {
        await ProductService.deduireStock(item.produit.id!, item.quantite);
      }

      // 3. Générer le reçu PDF
      await _genererRecu();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vente validée avec succès !'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Retour à l'accueil
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _genererRecu() async {
    final pdf = pw.Document();
    final client = _clientNomController.text.isEmpty ? "Client Inconnu" : _clientNomController.text;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text('MON APP FACTURATION', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 10),
              pw.Text('Client : $client'),
              pw.Text('Date : ${DateTime.now().toString().substring(0, 16)}'),
              pw.Divider(),
              pw.Text('Détails :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              ..._panier.map((item) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${item.quantite}x ${item.produit.nom}'),
                    pw.Text('${item.total.toStringAsFixed(0)} FCFA'),
                  ],
                );
              }),
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${_total.toStringAsFixed(0)} FCFA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('Merci de votre visite !')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Recu_$client.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Nouvelle vente", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E2C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client
            TextField(
              controller: _clientNomController,
              decoration: const InputDecoration(labelText: 'Nom du client', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 16),

            // Recherche
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Rechercher un produit à ajouter',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            
            // Résultats de recherche
            if (_produitsFiltres.isNotEmpty)
              Container(
                color: Colors.white,
                constraints: const BoxConstraints(maxHeight: 150),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _produitsFiltres.length,
                  itemBuilder: (context, index) {
                    final p = _produitsFiltres[index];
                    return ListTile(
                      title: Text(p.nom),
                      subtitle: Text('Stock: ${p.quantite} | ${p.prixVente} FCFA'),
                      onTap: () => _ajouterAuPanier(p),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),
            
            // Panier
            const Text("Panier", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (_panier.isEmpty)
               const Padding(
                 padding: EdgeInsets.all(8.0),
                 child: Text("Aucun article dans le panier", style: TextStyle(color: Colors.grey)),
               )
            else
              ..._panier.map((item) => Card(
                child: ListTile(
                  title: Text(item.produit.nom),
                  subtitle: Text('${item.total.toStringAsFixed(0)} FCFA'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            if (item.quantite > 1) {
                              item.quantite--;
                            } else {
                              _panier.remove(item);
                            }
                          });
                        },
                      ),
                      Text('${item.quantite}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          if (item.quantite < item.produit.quantite) {
                            setState(() => item.quantite++);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )),

            const SizedBox(height: 16),
            const Divider(),

            // Type de vente
            const Text("Type de vente", style: TextStyle(fontWeight: FontWeight.bold)),
            RadioGroup<String>(
  groupValue: _typeVente,
  onChanged: (val) => setState(() => _typeVente = val!),
  child: const Row(
    children: [
      Radio<String>(value: 'Normal'),
      Text('Normal'),
      SizedBox(width: 20),
      Radio<String>(value: 'Crédit'),
      Text('Crédit'),
    ],
  ),
),

            // Modalité
            const Text("Modalité de paiement", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _modePaiement,
              decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
              items: ['Espèces', 'Mobile Money', 'Carte'].map((mode) => DropdownMenuItem(value: mode, child: Text(mode))).toList(),
              onChanged: (val) => setState(() => _modePaiement = val!),
            ),
            const SizedBox(height: 16),

            // Acompte et Remarque
            TextField(
              controller: _acompteController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Acompte à payer (FCFA)', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _remarqueController,
              decoration: const InputDecoration(labelText: 'Remarque / Instructions client', border: OutlineInputBorder(), filled: true, fillColor: Colors.white, alignLabelWithHint: true),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Résumé
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Montant total', style: TextStyle(fontSize: 16)),
                      Text('${_total.toStringAsFixed(0)} FCFA', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Acompte'),
                      Text('${(double.tryParse(_acompteController.text) ?? 0).toStringAsFixed(0)} FCFA'),
                    ]),
                    const Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Reste à payer', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      Text('${_resteAPayer.toStringAsFixed(0)} FCFA', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Bouton Valider
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _validerVente,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Valider et générer le reçu', style: TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}