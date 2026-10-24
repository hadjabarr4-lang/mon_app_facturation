class Achat {
  final String id;
  final String produitId;
  final String produitNom;
  final int quantite;
  final double prixUnitaire;
  final double total;
  final String fournisseur;
  final String date;

  Achat({
    required this.id,
    required this.produitId,
    required this.produitNom,
    required this.quantite,
    required this.prixUnitaire,
    required this.total,
    required this.fournisseur,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produit_id': produitId,
      'produit_nom': produitNom,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
      'total': total,
      'fournisseur': fournisseur,
      'date': date,
    };
  }

  factory Achat.fromMap(Map<String, dynamic> map) {
    return Achat(
      id: map['id'],
      produitId: map['produit_id'],
      produitNom: map['produit_nom'],
      quantite: map['quantite'],
      prixUnitaire: (map['prix_unitaire'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      fournisseur: map['fournisseur'],
      date: map['date'],
    );
  }
}