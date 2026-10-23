import 'package:flutter/material.dart';
// ⚠️ N'oubliez pas de remettre vos vrais imports ici si nécessaire
// import '../stock/stock_screen.dart';
// import '../vente/vente_screen.dart';
import 'stock/produits_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  // Liste des menus
  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard},
    {'title': 'Produits', 'icon': Icons.inventory_2},
    {'title': 'Catégories', 'icon': Icons.category},
    {'title': 'Stocks', 'icon': Icons.store},
    {'title': 'Ventes', 'icon': Icons.point_of_sale},
    {'title': 'Achats', 'icon': Icons.shopping_cart},
    {'title': 'Rapports', 'icon': Icons.bar_chart},
    {'title': 'Utilisateurs', 'icon': Icons.people},
  ];

  // Liste des écrans
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildDashboardContent(), // Index 0 : Le dashboard
      // ⚠️ REMPLACEZ CES WIDGETS PAR VOS VRAIS ÉCRANS (ex: const StockScreen())
      const ProduitScreen(),
      const Center(child: Text("Écran Catégories")), 
      const Center(child: Text("Écran Stock")), 
      const Center(child: Text("Écran Ventes")), 
      const Center(child: Text("Écran Achats")), 
      const Center(child: Text("Écran Rapports")), 
      const Center(child: Text("Écran Utilisateurs")), 
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1E1E2C),
              title: const Text('Admin', style: TextStyle(color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(context)),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F6F8),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MENU LATÉRAL
  // ==========================================
  Widget _buildSidebar(BuildContext context) {
    return Material(
      color: const Color(0xFF1E1E2C),
      child: SizedBox(
        width: 250,
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              'Ma Facturation',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;
                  return ListTile(
                    leading: Icon(
                      _menuItems[index]['icon'],
                      color: isSelected ? Colors.blue : Colors.grey[400],
                    ),
                    title: Text(
                      _menuItems[index]['title'],
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.grey[300],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: Colors.white.withOpacity(0.05),
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      if (MediaQuery.of(context).size.width < 800) {
                        Navigator.pop(context); 
                      }
                    },
                  );
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.redAccent)),
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CONTENU DU DASHBOARD
  // ==========================================
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tableau de bord',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // Les 4 cartes avec les montants remis à 0 FCFA
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              _buildStatCard('RECETTES DU JOUR', '0 FCFA', Colors.blue),
              _buildStatCard('RECETTES DU MOIS', '0 FCFA', Colors.blueAccent),
              _buildStatCard('PRODUITS', '0', Colors.orange),
              _buildStatCard('ALERTES STOCK', '0', Colors.redAccent),
            ],
          ),
          
          const SizedBox(height: 24),

          const Text(
            'Évolution des ventes (7 derniers jours)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          // Emplacement de votre graphique
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text("[ Emplacement de votre graphique ]", style: TextStyle(color: Colors.grey)),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Historique des dernières ventes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Tableau avec défilement horizontal pour mobile
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text('REÇU', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('CAISSIER', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('MODE', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('DATE', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ACTION', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: [
                  // Ligne d'exemple avec 0 FCFA
                  DataRow(cells: [
                    const DataCell(Text('REC-001')),
                    const DataCell(Text('Admin')),
                    const DataCell(Text('0 FCFA')), // Prix remis à 0
                    const DataCell(Text('Espèce')),
                    const DataCell(Text('--/--/----')),
                    DataCell(ElevatedButton(onPressed: (){}, child: const Text('Reçu'))),
                  ]),
                  DataRow(cells: [
                    const DataCell(Text('REC-002')),
                    const DataCell(Text('Admin')),
                    const DataCell(Text('0 FCFA')), // Prix remis à 0
                    const DataCell(Text('Mobile')),
                    const DataCell(Text('--/--/----')),
                    DataCell(ElevatedButton(onPressed: (){}, child: const Text('Reçu'))),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Carte réutilisable
  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}