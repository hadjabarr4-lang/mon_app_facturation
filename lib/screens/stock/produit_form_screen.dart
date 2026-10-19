import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/produit.dart';
import '../../services/product_service.dart';

class ProduitFormScreen extends StatefulWidget {
  final String? codeBarre;
  const ProduitFormScreen({Key? key, this.codeBarre}) : super(key: key);
  @override
  State<ProduitFormScreen> createState() => _ProduitFormScreenState();
}

class _ProduitFormScreenState extends State<ProduitFormScreen> {
  final _nom = TextEditingController();
  final _prixAchat = TextEditingController();
  final _prixVente = TextEditingController();
  final _quantite = TextEditingController(text: '0');
  final _codeBarre = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    if (widget.codeBarre != null) _codeBarre.text = widget.codeBarre!;
  }

  Future<void> _choisirImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img != null) setState(() => _imagePath = img.path);
  }

  Future<void> _enregistrer() async {
    if (_nom.text.isEmpty) return;
    final p = Produit(
      nom: _nom.text,
      codeBarre: _codeBarre.text.isEmpty ? null : _codeBarre.text,
      imagePath: _imagePath,
      prixAchat: double.tryParse(_prixAchat.text) ?? 0,
      prixVente: double.tryParse(_prixVente.text) ?? 0,
      quantite: int.tryParse(_quantite.text) ?? 0,
    );
    await ProductService.ajouter(p);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau produit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _choisirImage,
              child: Container(
                width: 120, height: 120,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                child: _imagePath != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_imagePath!), fit: BoxFit.cover))
                    : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            _field(_nom, 'Nom du produit (ex: Beurre)'),
            _field(_prixAchat, 'Prix d\'achat (FCFA)', number: true),
            _field(_prixVente, 'Prix de vente (FCFA)', number: true),
            _field(_quantite, 'Quantité en stock', number: true),
            _field(_codeBarre, 'Code-barres (scanné ou manuel)'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(onPressed: _enregistrer, child: const Text('Enregistrer le produit')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {bool number = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    ),
  );
}