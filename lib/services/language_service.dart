// lib/services/language_service.dart
import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  Locale _currentLocale = const Locale('fr', 'FR');

  Locale get currentLocale => _currentLocale;

  bool get isFrench => _currentLocale.languageCode == 'fr';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  void changeLanguage(String languageCode) {
    switch (languageCode) {
      case 'fr':
        _currentLocale = const Locale('fr', 'FR');
        break;
      case 'en':
        _currentLocale = const Locale('en', 'US');
        break;
      default:
        _currentLocale = const Locale('fr', 'FR');
    }
    notifyListeners();
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      default:
        return 'Français';
    }
  }

  String getCurrentLanguageName() {
    return getLanguageName(_currentLocale.languageCode);
  }

  // Méthodes pour obtenir les textes traduits
  String getText(String key) {
    switch (_currentLocale.languageCode) {
      case 'en':
        return _getEnglishText(key);
      case 'fr':
      default:
        return _getFrenchText(key);
    }
  }

  String _getFrenchText(String key) {
    switch (key) {
      case 'accueil':
        return 'Accueil';
      case 'machines':
        return 'Machines';
      case 'ia':
        return 'IA';
      case 'forum':
        return 'Forum';
      case 'compte':
        return 'Compte';
      case 'mon_compte':
        return 'Mon Compte';
      case 'membre_premium':
        return 'Membre Premium';
      case 'bienvenue_mrk':
        return 'Bienvenue sur MRK';
      case 'bonjour':
        return 'Bonjour !';
      case 'decouvrez_message':
        return 'Découvrez nos formations et échangez sur le marché de l\'or.';
      case 'acceder_formations':
        return 'Accéder aux formations';
      case 'discuter_ia':
        return 'Discuter avec l\'IA';
      case 'rejoindre_forum':
        return 'Rejoindre le forum';
      case 'informations_personnelles':
        return 'Informations personnelles';
      case 'nom_complet':
        return 'Nom complet';
      case 'age':
        return 'Âge';
      case 'email':
        return 'Email';
      case 'telephone':
        return 'Téléphone';
      case 'mes_statistiques':
        return 'Mes statistiques';
      case 'formations':
        return 'Formations';
      case 'nos_formations':
        return 'Nos Formations';
      case 'messages':
        return 'Messages';
      case 'actions':
        return 'Actions';
      case 'parametres':
        return 'Paramètres';
      case 'gerer_preferences':
        return 'Gérer vos préférences';
      case 'aide_support':
        return 'Aide & Support';
      case 'centre_aide':
        return 'Centre d\'aide et contact';
      case 'langue':
        return 'Langue';
      case 'a_propos':
        return 'À propos';
      case 'version':
        return 'Version 1.0.0';
      case 'se_deconnecter':
        return 'Se déconnecter';
      case 'choisir_langue':
        return 'Choisir la langue';
      case 'langue_francaise':
        return 'Langue française';
      case 'english_language':
        return 'English language';
      case 'annuler':
        return 'Annuler';
      case 'assistant_ia':
        return 'Assistant IA - Aureus';
      case 'ia_reflechit':
        return 'IA réfléchit...';
      case 'poser_question_or':
        return 'Posez votre question sur le marché de l\'or...';
      case 'forum_de_discussion':
        return 'Forum de discussion';
      case 'connexion':
        return 'Connexion';
      case 'creer_compte':
        return 'Créer un compte';
      case 'adresse_email':
        return 'Adresse email';
      case 'mot_de_passe':
        return 'Mot de passe';
      case 'se_connecter':
        return 'Se connecter';
      case 'inscription':
        return 'Inscription';
      case 'enregistrer':
        return 'Enregistrer';
      default:
        return key;
    }
  }

  String _getEnglishText(String key) {
    switch (key) {
      case 'accueil':
        return 'Home';
      case 'machines':
        return 'Machines';
      case 'ia':
        return 'AI';
      case 'forum':
        return 'Forum';
      case 'compte':
        return 'Account';
      case 'mon_compte':
        return 'My Account';
      case 'membre_premium':
        return 'Premium Member';
      case 'bienvenue_mrk':
        return 'Welcome to MRK';
      case 'bonjour':
        return 'Hello!';
      case 'decouvrez_message':
        return 'Discover our courses and discuss the gold market.';
      case 'acceder_formations':
        return 'Go to courses';
      case 'discuter_ia':
        return 'Chat with AI';
      case 'rejoindre_forum':
        return 'Join the forum';
      case 'informations_personnelles':
        return 'Personal Information';
      case 'nom_complet':
        return 'Full Name';
      case 'age':
        return 'Age';
      case 'email':
        return 'Email';
      case 'telephone':
        return 'Phone';
      case 'mes_statistiques':
        return 'My Statistics';
      case 'formations':
        return 'Courses';
      case 'nos_formations':
        return 'Our Courses';
      case 'messages':
        return 'Messages';
      case 'actions':
        return 'Actions';
      case 'parametres':
        return 'Settings';
      case 'gerer_preferences':
        return 'Manage your preferences';
      case 'aide_support':
        return 'Help & Support';
      case 'centre_aide':
        return 'Help center and contact';
      case 'langue':
        return 'Language';
      case 'a_propos':
        return 'About';
      case 'version':
        return 'Version 1.0.0';
      case 'se_deconnecter':
        return 'Logout';
      case 'choisir_langue':
        return 'Choose Language';
      case 'langue_francaise':
        return 'French language';
      case 'english_language':
        return 'English language';
      case 'annuler':
        return 'Cancel';
      case 'assistant_ia':
        return 'AI Assistant - Aureus';
      case 'ia_reflechit':
        return 'AI is thinking...';
      case 'poser_question_or':
        return 'Ask your question about the gold market...';
      case 'forum_de_discussion':
        return 'Discussion Forum';
      case 'connexion':
        return 'Login';
      case 'creer_compte':
        return 'Create an account';
      case 'adresse_email':
        return 'Email address';
      case 'mot_de_passe':
        return 'Password';
      case 'se_connecter':
        return 'Sign in';
      case 'inscription':
        return 'Registration';
      case 'enregistrer':
        return 'Save';
      default:
        return key;
    }
  }
}
