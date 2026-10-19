import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../services/database_service.dart';
import '../../services/product_service.dart';
import '../../services/finance_service.dart';
import '../../utils/format.dart';
import '../../models/produit.dart';

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
  final _clientNom = TextEditingController();
  final _remarque = TextEditingController();
  final _acompte = TextEditingController(text: '0');
  final _recherche = TextEditingController();

  final List<LigneVente> _lignes = [];
  String _typeVente = 'normal';
  String _modePaiement = 'espèces';
  List<Produit> _produitsFiltres = [];

  double get _total => _lignes.fold(0, (s, l) => s + l.total);

  Future<void> _chercher(String q) async {
    final tous = await ProductService.tous();
    setState(() => _produitsFiltres = tous.where((p) => p.nom.toLowerCase().contains(q.toLowerCase())).toList());
  }

  void _ajouterProduit(Produit p) {
    setState(() {
      final existant = _lignes.indexWhere((l) => l.produit.id == p.id);
      if (existant >= 0) {
        _lignes[existant].quantite++;
      } else {
        _lignes.add(LigneVente(p, 1));
      }
      _produitsFiltres = [];
      _recherche.clear();
    });
  }

  Future<void> _valider() async {
    if (_lignes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajoutez au moins un produit')));
      return;
    }
    final acompte = double.tryParse(_acompte.text) ?? 0;
    final reste = _total - acompte;
    final idVente = const Uuid().v4();
    final db = await DatabaseService.database;

    await db.insert('ventes', {
      'id': idVente,
      'numero': 'V-${DateTime.now().millisecondsSinceEpoch}',
      'client_id': '',
      'client_nom': _clientNom.text.isEmpty ? 'Client comptoir' : _clientNom.text,
      'type_vente': _typeVente,
      'mode_paiement': _modePaiement,
      'montant_total': _total,
      'acompte': acompte,
      'reste_a_payer': reste,
      'statut': reste <= 0 ? 'payee' : 'credit',
      'remarque': _remarque.text,
      'date': DateTime.now().toIso8601String(),
    });

    for (var l in _lignes) {
      await db.insert('lignes_vente', {
        'id': const Uuid().v4(),
        'vente_id': idVente,
        'produit_id': l.produit.id,
        'produit_nom': l.produit.nom,
        'prix_unitaire': l.produit.prixVente,
        'quantite': l.quantite,
        'total': l.total,
      });
      // Décrémenter le stock
      await ProductService.miseAJourQuantite(l.produit.id!, l.produit.quantite - l.quantite);
    }

    if (mounted) {
      _afficherRecu(idVente, acompte, reste);
    }
  }

  void _afficherRecu(String idVente, double acompte, double reste) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('✅ Vente enregistrée'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Client : ${_clientNom.text.isEmpty ? "Comptoir" : _clientNom.text}'),
              Text('Type : ${_typeVente == "normal" ? "Normal" : "Crédit"}'),
              Text('Mode : $_modePaiement'),
              const Divider(),
              ..._lignes.map((l) => Text('${l.produit.nom} x${l.quantite} = ${Fmt.fcfa(l.total)}')),
              const Divider(),
              Text('TOTAL : ${Fmt.fcfa(_total)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Acompte : ${Fmt.fcfa(acompte)}'),
              Text('Reste à payer : ${Fmt.fcfa(reste)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              if (_remarque.text.isNotEmpty) ...[
                const Divider(),
                Text('Remarque : ${_remarque.text}'),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('Fermer')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final acompte = double.tryParse(_acompte.text) ?? 0;
    final reste = _total - acompte;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Nouvelle vente'), backgroundColor: const Color(0xFF1E293B), iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client
            TextField(controller: _clientNom, decoration: const InputDecoration(labelText: 'Nom du client', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 12),

            // Recherche produit
            TextField(
              controller: _recherche,
              onChanged: _chercher,
              decoration: const InputDecoration(hintText: 'Rechercher un produit à ajouter', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
            ),
            if (_produitsFiltres.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: _produitsFiltres.take(5).map((p) => ListTile(
                    title: Text(p.nom),
                    subtitle: Text('${Fmt.fcfa(p.prixVente)} • Stock: ${p.quantite}'),
                    onTap: () => _ajouterProduit(p),
                  )).toList(),
                ),
              ),
            const SizedBox(height: 15),

            // Lignes
            ..._lignes.map((l) => Card(
              child: ListTile(
                title: Text(l.produit.nom),
                subtitle: Text('${Fmt.fcfa(l.produit.prixVente)} x ${l.quantite}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => setState(() { if (l.quantite > 1) l.quantite--; else _lignes.remove(l); })),
                    Text(Fmt.fcfa(l.total)),
                    IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: () => setState(() => l.quantite++)),
                  ],
                ),
              ),
            )),

            const SizedBox(height: 15),
            // Type de vente
            const Text('Type de vente', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: RadioListTile<String>(title: const Text('Normal'), value: 'normal', groupValue: _typeVente, onChanged: (v) => setState(() => _typeVente = v!))),
                Expanded(child: RadioListTile<String>(title: const Text('Crédit'), value: 'credit', groupValue: _typeVente, onChanged: (v) => setState(() => _typeVente = v!))),
              ],
            ),

            // Mode de paiement
            const Text('Modalité de paiement', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _modePaiement,
              items: const [
                DropdownMenuItem(value: 'espèces', child: Text('Espèces')),
                DropdownMenuItem(value: 'wave', child: Text('Wave')),
                DropdownMenuItem(value: 'orange_money', child: Text('Orange Money')),
                DropdownMenuItem(value: 'carte', child: Text('Carte bancaire')),
              ],
              onChanged: (v) => setState(() => _modePaiement = v!),
              decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 12),

            // Acompte
            TextField(controller: _acompte, keyboardType: TextInputType.number, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'Acompte à payer (FCFA)', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 12),

            // Remarque
            TextField(controller: _remarque, maxLines: 3, decoration: const InputDecoration(labelText: 'Remarque / Instructions client', border: OutlineInputBorder(), filled: true, fillColor: Colors.white)),
            const SizedBox(height: 20),

            // Résumé
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Montant total'), Text(Fmt.fcfa(_total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Acompte'), Text(Fmt.fcfa(acompte))]),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Reste à payer', style: TextStyle(color: Colors.red)), Text(Fmt.fcfa(reste), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton.icon(
                onPressed: _valider,
                icon: const Icon(Icons.check),
                label: const Text('Valider et générer le reçu', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}