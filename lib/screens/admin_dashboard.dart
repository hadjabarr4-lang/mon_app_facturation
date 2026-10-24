import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/finance_service.dart';
import '../services/product_service.dart';

// ⚠️ VÉRIFIE BIEN CES IMPORTS (Lignes 5 à 8)
// Si tes fichiers sont nommés différemment, adapte-les ici.
import 'stock/produits_screen.dart';
import 'stock/categorie_screen.dart';
import 'stock/stock_screen.dart';
import 'vente/vente_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isDashboardLoading = true;

  // Variables pour les stats
  double _recettesJour = 0;
  double _recettesMois = 0;
  int _nbProduits = 0;
  int _nbAlertes = 0;
  List<Map<String, dynamic>> _ventes = [];

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

  @override
  void initState() {
    super.initState();
    _chargerDashboard();
  }

  Future<void> _chargerDashboard() async {
    try {
      final rJour = await FinanceService.recettesDuJour();
      final rMois = await FinanceService.recettesDuMois();
      final produits = await ProductService.tous();
      final ventes = await FinanceService.toutesLesVentes();

      setState(() {
        _recettesJour = rJour;
        _recettesMois = rMois;
        _nbProduits = produits.length;
        _nbAlertes = produits.where((p) => p.quantite <= p.seuilAlerte).length;
        _ventes = ventes;
        _isDashboardLoading = false;
      });
    } catch (e) {
      setState(() => _isDashboardLoading = false);
      debugPrint("Erreur dashboard: $e");
    }
  }

  // 👇 CETTE FONCTION REMPLACE L'ANCIENNE LISTE _screens 👇
  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const ProduitScreen(); 
      case 2:
        return const CategorieScreen(); 
      case 3:
        return const StockScreen();
      case 4:
        return const VenteScreen();
      case 5:
        return const Center(child: Text("Écran Achats (À venir)"));
      case 6:
        return const Center(child: Text("Écran Rapports (À venir)"));
      case 7:
        return const Center(child: Text("Écran Utilisateurs (À venir)"));
      default:
        return _buildDashboardContent();
    }
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
              child: _getSelectedScreen(), // 👈 Utilisation de la nouvelle fonction
            ),
          ),
        ],
      ),
    );
  }

  // --- MENU LATÉRAL ---
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
          ],
        ),
      ),
    );
  }

  // --- CONTENU DU DASHBOARD ---
  Widget _buildDashboardContent() {
    if (_isDashboardLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

          // 1. CARTES STATS
          Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: [
              _buildStatCard('RECETTES DU JOUR', '${_recettesJour.toStringAsFixed(0)} FCFA', Colors.blue),
              _buildStatCard('RECETTES DU MOIS', '${_recettesMois.toStringAsFixed(0)} FCFA', Colors.blueAccent),
              _buildStatCard('PRODUITS', '$_nbProduits', Colors.orange),
              _buildStatCard('ALERTES STOCK', '$_nbAlertes', Colors.redAccent),
            ],
          ),
          
          const SizedBox(height: 24),

          // 2. GRAPHIQUE
          const Text(
            'Évolution des ventes (7 derniers jours)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), 
                      FlSpot(3, 2), FlSpot(4, 5), FlSpot(5, 3), FlSpot(6, 4),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 3. TABLEAU DES VENTES
          const Text(
            'Historique des dernières ventes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

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
                ],
                rows: _ventes.map((vente) {
                  final date = vente['date'] != null 
                      ? vente['date'].toString().substring(0, 16).replaceAll('T', ' ') 
                      : '--/--/----';
                  final idCourt = vente['id'] != null && vente['id'].toString().length > 5 
                      ? vente['id'].toString().substring(vente['id'].toString().length - 5) 
                      : vente['id'].toString();
                      
                  return DataRow(cells: [
                    DataCell(Text(idCourt)),
                    const DataCell(Text('Admin')), 
                    DataCell(Text('${(vente['montant_total'] as num).toStringAsFixed(0)} FCFA')),
                    DataCell(Text(vente['mode_paiement'] ?? 'Espèces')),
                    DataCell(Text(date)),
                  ]);
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Carte de statistique
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