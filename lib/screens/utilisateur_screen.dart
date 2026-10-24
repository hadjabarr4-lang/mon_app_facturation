import 'package:flutter/material.dart';
import '../models/utilisateur.dart';
import '../services/utilisateur_service.dart';

class UtilisateurScreen extends StatefulWidget {
  const UtilisateurScreen({Key? key}) : super(key: key);

  @override
  State<UtilisateurScreen> createState() => _UtilisateurScreenState();
}

class _UtilisateurScreenState extends State<UtilisateurScreen> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _roleSelectionne = 'Caissier';
  
  List<Utilisateur> _utilisateurs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerUtilisateurs();
  }

  Future<void> _chargerUtilisateurs() async {
    setState(() => _isLoading = true);
    final users = await UtilisateurService.tous();
    setState(() {
      _utilisateurs = users;
      _isLoading = false;
    });
  }

  Future<void> _ajouterUtilisateur() async {
    if (_nomController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs.')));
      return;
    }

    final nouveau = Utilisateur(
      nom: _nomController.text,
      email: _emailController.text,
      motDePasse: _passwordController.text,
      role: _roleSelectionne,
    );

    try {
      await UtilisateurService.ajouter(nouveau);
      _nomController.clear();
      _emailController.clear();
      _passwordController.clear();
      await _chargerUtilisateurs();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Utilisateur créé !'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Utilisateurs & Caissiers", style: TextStyle(color: Colors.white)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(controller: _nomController, decoration: const InputDecoration(labelText: 'Nom complet', border: OutlineInputBorder())),
                          const SizedBox(height: 12),
                          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                          const SizedBox(height: 12),
                          TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder())),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _roleSelectionne,
                            decoration: const InputDecoration(labelText: 'Rôle', border: OutlineInputBorder()),
                            items: ['Admin', 'Caissier'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                            onChanged: (val) => setState(() => _roleSelectionne = val!),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _ajouterUtilisateur,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: const Text('Créer l\'utilisateur'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text("Liste des utilisateurs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _utilisateurs.length,
                      itemBuilder: (context, index) {
                        final u = _utilisateurs[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: u.role == 'Admin' ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                            child: Icon(Icons.person, color: u.role == 'Admin' ? Colors.blue : Colors.grey),
                          ),
                          title: Text(u.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${u.email} • ${u.role}'),
                          trailing: TextButton(
                            onPressed: () async {
                              await UtilisateurService.supprimer(u.id!);
                              _chargerUtilisateurs();
                            },
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