class Produit {
  final String? id;
  final String nom;
  final String? codeBarre;
  final String? imagePath;
  final double prixAchat;
  final double prixVente;
  final int quantite;
  final int seuilAlerte;
  final String? categorie;

  Produit({
    this.id,
    required this.nom,
    this.codeBarre,
    this.imagePath,
    this.prixAchat = 0,
    this.prixVente = 0,
    this.quantite = 0,
    this.seuilAlerte = 5,
    this.categorie,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nom': nom,
    'code_barre': codeBarre,
    'image_path': imagePath,
    'prix_achat': prixAchat,
    'prix_vente': prixVente,
    'quantite': quantite,
    'seuil_alerte': seuilAlerte,
    'categorie': categorie,
    'date_creation': DateTime.now().toIso8601String(),
  };

  factory Produit.fromMap(Map<String, dynamic> m) => Produit(
    id: m['id'],
    nom: m['nom'],
    codeBarre: m['code_barre'],
    imagePath: m['image_path'],
    prixAchat: (m['prix_achat'] as num?)?.toDouble() ?? 0,
    prixVente: (m['prix_vente'] as num?)?.toDouble() ?? 0,
    quantite: m['quantite'] ?? 0,
    seuilAlerte: m['seuil_alerte'] ?? 5,
    categorie: m['categorie'],
  );
}