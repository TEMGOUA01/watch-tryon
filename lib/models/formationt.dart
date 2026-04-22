// lib/models/formationt.dart
class Formation {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;

  const Formation({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

  factory Formation.fromJson(Map<String, dynamic> json, [String? docId]) {
    return Formation(
      id: docId ?? (json['id']?.toString() ?? ''),
      title: json['title'] as String? ?? 'Sans titre',
      description: json['description'] as String? ?? 'Aucune description',
      imageUrl: json['imageUrl'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      // 'id' n'est pas sauvegardé dans le document car il devient l'ID du document Firestore
    };
  }
}
