import 'package:flutter/material.dart';
import '../../services/finance_service.dart';

class RapportScreen extends StatefulWidget {
  const RapportScreen({Key? key}) : super(key: key);

  @override
  State<RapportScreen> createState() => _RapportScreenState();
}

class _RapportScreenState extends State<RapportScreen> {
  bool _isLoading = true;
  double _ca = 0;
  double _depenses = 0;
  double _benefice = 0;
  int _nbVentes = 0;

  @override
  void initState() {
    super.initState();
    _chargerRapports();
  }

  Future<void> _chargerRapports() async {
    setState(() => _isLoading = true);
    try {
      final ca = await FinanceService.chiffreAffaires();
      final dep = await FinanceService.totalDepenses();
      final ben = await FinanceService.benefice();
      final ventes = await FinanceService.toutesLesVentes();

      setState(() {
        _ca = ca;
        _depenses = dep;
        _benefice = ben;
        _nbVentes = ventes.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Erreur rapport : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Rapports", style: TextStyle(color: Colors.white)),
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
                  const Text(
                    "Résumé Financier",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: [
                      _buildStatCard('RECETTES (CA)', '${_ca.toStringAsFixed(0)} FCFA', Colors.green),
                      _buildStatCard('DÉPENSES', '${_depenses.toStringAsFixed(0)} FCFA', Colors.red),
                      _buildStatCard('BÉNÉFICE', '${_benefice.toStringAsFixed(0)} FCFA', Colors.blue),
                      _buildStatCard('NB VENTES', '$_nbVentes', Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Note :",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Le bénéfice est calculé en soustrayant les dépenses (achats et dépenses manuelles) du chiffre d'affaires (total des ventes).",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}