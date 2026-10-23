import 'package:flutter/material.dart';
import '../../models/categorie.dart';
import '../../services/categorie_service.dart';

class CategorieScreen extends StatefulWidget {
  const CategorieScreen({Key? key}) : super(key: key);

  @override
  State<CategorieScreen> createState() => _CategorieScreenState();
}

class _CategorieScreenState extends State<CategorieScreen> {
  final _nomController = TextEditingController();
  final _descController = TextEditingController();
  List<Categorie> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerCategories();
  }

  Future<void> _chargerCategories() async {
    setState(() => _isLoading = true);
    final cats = await CategorieService.tous();
    setState(() {
      _categories = cats;
      _isLoading = false;
    });
  }

  Future<void> _ajouterCategorie() async {
    if (_nomController.text.isEmpty) return;
    final nouvelleCat = Categorie(nom: _nomController.text, description: _descController.text);
    await CategorieService.ajouter(nouvelleCat);
    _nomController.clear();
    _descController.clear();
    _chargerCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Catégories", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white, elevation: 1, iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
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
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _nomController, decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()))),
                        const SizedBox(width: 16),
                        Expanded(child: TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(onPressed: _ajouterCategorie, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('Ajouter')),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading ? const Center(child: CircularProgressIndicator()) : Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ListView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return ListTile(
                    title: Text(cat.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(cat.description ?? ''),
                    trailing: TextButton(
                      onPressed: () async { await CategorieService.supprimer(cat.id!); _chargerCategories(); },
                      child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}