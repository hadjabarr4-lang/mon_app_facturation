import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/produit.dart';
import '../../services/product_service.dart';
import '../../utils/format.dart';
import '../stock/produit_form_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({Key? key}) : super(key: key);
  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  List<Produit> _produits = [];
  String _recherche = '';

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final p = await ProductService.tous();
    setState(() => _produits = p);
  }

  Future<void> _scanner() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _ScannerScreen()),
    );
    if (code != null) {
      final produit = await ProductService.parCodeBarre(code);
      if (produit != null) {
        _modifierQuantite(produit);
      } else {
        // Nouveau produit : ouvrir le formulaire avec le code pré-rempli
        Navigator.push(context, MaterialPageRoute(builder: (_) => ProduitFormScreen(codeBarre: code)));
      }
    }
  }

  Future<void> _modifierQuantite(Produit p) async {
    final ctrl = TextEditingController(text: p.quantite.toString());
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(p.nom),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Quantité actuelle : ${p.quantite}'),
            TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nouvelle quantité')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final q = int.tryParse(ctrl.text) ?? p.quantite;
              await ProductService.miseAJourQuantite(p.id!, q);
              Navigator.pop(context);
              _charger();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtres = _produits.where((p) => p.nom.toLowerCase().contains(_recherche.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Stock', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _recherche = v),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: filtres.isEmpty
                ? const Center(child: Text('Aucun produit'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtres.length,
                    itemBuilder: (context, i) {
                      final p = filtres[i];
                      final alerte = p.quantite <= p.seuilAlerte;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: p.imagePath != null && File(p.imagePath!).existsSync()
                              ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(p.imagePath!), width: 50, height: 50, fit: BoxFit.cover))
                              : Container(width: 50, height: 50, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.inventory_2)),
                          title: Text(p.nom),
                          subtitle: Text('Vente: ${Fmt.fcfa(p.prixVente)}  •  Stock: ${p.quantite}'),
                          trailing: alerte
                              ? const Icon(Icons.warning, color: Colors.red)
                              : IconButton(icon: const Icon(Icons.edit), onPressed: () => _modifierQuantite(p)),
                          onTap: () => _modifierQuantite(p),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'scan',
            onPressed: _scanner,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProduitFormScreen()));
              _charger();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

// ---------- Écran Scanner ----------
class _ScannerScreen extends StatefulWidget {
  const _ScannerScreen({Key? key}) : super(key: key);
  @override
  State<_ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<_ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner le code-barres')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_scanned) return;
          final code = capture.barcodes.first.rawValue;
          if (code != null) {
            _scanned = true;
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}