import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// --- VOS IMPORTS D'ÉCRANS ---
import 'package:mon_app_facturation/screens/stock/stock_screen.dart';
import 'package:mon_app_facturation/screens/vente/vente_screen.dart';
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'title': 'Dashboard'},
    {'icon': Icons.inventory_2, 'title': 'Produits'},
    {'icon': Icons.category, 'title': 'Catégories'},
    {'icon': Icons.warehouse, 'title': 'Stocks'},
    {'icon': Icons.point_of_sale, 'title': 'Ventes'},
    {'icon': Icons.shopping_cart, 'title': 'Achats'},
    {'icon': Icons.bar_chart, 'title': 'Rapports'},
    {'icon': Icons.people, 'title': 'Utilisateurs'},
  ];

  // --- LISTE DES ÉCRANS TEMPORAIRES ---
  final List<Widget> _screens = [
    const SizedBox(), // Index 0 (Dashboard géré à part)
    const StockScreen(), // Index 1 : Produits
    const Center(child: Text('Écran Catégories à créer')), // Index 2
    const StockScreen(), // Index 3 : Stocks
    const VenteScreen(), // Index 4 : Ventes
    const Center(child: Text('Écran Achats à créer')), // Index 5
    const Center(child: Text('Écran Rapports à créer')), // Index 6
    const Center(child: Text('Écran Utilisateurs à créer')), // Index 7
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ==========================================
          // 1. LE MENU LATÉRAL
          // ==========================================
          Material(
            color: const Color(0xFF1E1E2C),
            child: SizedBox(
              width: 250,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Ma Facturation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _menuItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(
                            _menuItems[index]['icon'],
                            color: _selectedIndex == index ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            _menuItems[index]['title'],
                            style: TextStyle(
                              color: _selectedIndex == index ? Colors.blue : Colors.white,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 2. LE CONTENU PRINCIPAL
          // ==========================================
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _selectedIndex == 0
                  ? _buildDashboardContent()
                  : _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. LE CONTENU DU DASHBOARD
  // ==========================================
  Widget _buildDashboardContent() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre aligné à droite (le bouton a été retiré)
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Tableau de bord',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Les 4 Cartes de statistiques (Chiffres à 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard('RECETTES DU JOUR', '0 F', Colors.blue),
              _buildStatCard('RECETTES DU MOIS', '0 F', Colors.green), // Modifié à 0
              _buildStatCard('PRODUITS', '0', Colors.orange),           // Modifié à 0
              _buildStatCard('ALERTES STOCK', '0', Colors.red),
            ],
          ),
          const SizedBox(height: 30),

          // Le Graphique
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Évolution des ventes (7 derniers jours)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        titlesData: const FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            // Ligne complètement plate à 0
                            spots: const [
                              FlSpot(0, 0), 
                              FlSpot(1, 0), 
                              FlSpot(2, 0),
                              FlSpot(3, 0), 
                              FlSpot(4, 0), // Modifié à 0
                              FlSpot(5, 0), // Modifié à 0
                              FlSpot(6, 0),
                            ],
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. LES CARTES DE STATISTIQUES
  // ==========================================
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: color, width: 5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}