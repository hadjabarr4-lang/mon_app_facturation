class Categorie {
  final String? id;
  final String nom;
  final String? description;

  Categorie({this.id, required this.nom, this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
    };
  }

  factory Categorie.fromMap(Map<String, dynamic> map) {
    return Categorie(
      id: map['id'],
      nom: map['nom'],
      description: map['description'],
    );
  }
}