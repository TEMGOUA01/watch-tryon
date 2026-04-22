// lib/services/formation_service.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/formationt.dart';

class FormationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream en temps réel (Temps réel pour l'Admin et Utilisateurs)
  static Stream<List<Formation>> watchFormations() {
    return _firestore.collection('formations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Formation.fromJson(doc.data(), doc.id)).toList();
    });
  }

  // Ancienne méthode Future (gardée au cas où)
  static Future<List<Formation>> getFormations() async {
    try {
      final snapshot = await _firestore.collection('formations').get();
      if (snapshot.docs.isEmpty) {
        await _seedInitialData();
        final newSnapshot = await _firestore.collection('formations').get();
        return newSnapshot.docs.map((doc) => Formation.fromJson(doc.data(), doc.id)).toList();
      }
      return snapshot.docs.map((doc) => Formation.fromJson(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des formations: $e');
      return [];
    }
  }

  // Ajouter une formation (Espace Admin)
  static Future<void> addFormation(Formation formation) async {
    await _firestore.collection('formations').add(formation.toJson());
  }

  // Supprimer une formation (Espace Admin)
  static Future<void> deleteFormation(String docId) async {
    await _firestore.collection('formations').doc(docId).delete();
  }

  static Future<void> _seedInitialData() async {
    final formations = [
      const Formation(
        id: '1',
        title: 'Les bases du trading de l\'or',
        description: 'Apprenez les fondamentaux pour commencer à investir sur le marché de l\'or.',
        imageUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=400&h=400&fit=crop',
        price: 90.0,
      ),
      const Formation(
        id: '2',
        title: 'Analyse technique avancée',
        description: 'Maîtrisez les outils et indicateurs pour évaluer les tendances du marché de l\'or.',
        imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400&h=400&fit=crop',
        price: 120.0,
      ),
    ];

    for (var formation in formations) {
      await _firestore.collection('formations').add(formation.toJson());
    }
  }
}
