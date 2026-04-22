import 'package:flutter/material.dart';
import '../constants/profile_avatars.dart';
import '../services/language_service.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../widgets/aureus_background.dart';
import 'admin_formations_screen.dart';
import 'admin_signals_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_mining_transactions_screen.dart';
import 'mining_machines_screen.dart';

class CompteScreen extends StatefulWidget {
  const CompteScreen({super.key});

  @override
  State<CompteScreen> createState() => _CompteScreenState();
}

class _CompteScreenState extends State<CompteScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  late final LanguageService _languageService;
  UserProfile? _profile;
  String _selectedAvatar = ProfileAvatars.options.first;
  bool _loadingProfile = true;
  String? _error;

  // L'email administrateur codé en dur (à modifier avec le vôtre)
  bool get _isAdmin {
    final email = FirebaseAuth.instance.currentUser?.email;
    return email == 'tem@gmail.com';
  }

  @override
  void initState() {
    super.initState();
    _languageService = LanguageService();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await UserService.instance.fetchCurrentUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
          _selectedAvatar = ProfileAvatars.sanitize(
            profile?.avatar.isNotEmpty == true
                ? profile!.avatar
                : ProfileAvatars.defaultForUid(currentUid),
          );
          _nomController.text = profile?.name ?? '';
          _emailController.text =
              profile?.email ?? FirebaseAuth.instance.currentUser?.email ?? '';
          _telephoneController.text = profile?.phone ?? '';
          _ageController.text = (profile?.age ?? 0) > 0 ? profile!.age.toString() : '';
          _loadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;

    return ListenableBuilder(
      listenable: _languageService,
      builder: (context, child) {
        return AureusBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(_languageService.getText('mon_compte')),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              foregroundColor: Colors.white,
            ),
            body: SafeArea(
              child: _loadingProfile
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.secondaryColor))
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              padding: EdgeInsets.only(
                                left: isTablet ? 32.0 : 16.0,
                                right: isTablet ? 32.0 : 16.0,
                                top: 16.0,
                                bottom: 32.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section Photo de profil
                                  _buildProfileSection(),
                                  const SizedBox(height: 32),

                                  // Informations personnelles
                                  _buildSectionTitle(_languageService.getText('informations_personnelles')),
                                  _buildInfoCard(
                                    icon: Icons.person_outline,
                                    title: _languageService.getText('nom_complet'),
                                    controller: _nomController,
                                  ),
                                  _buildInfoCard(
                                    icon: Icons.cake_outlined,
                                    title: 'Âge',
                                    controller: _ageController,
                                  ),
                                  _buildInfoCard(
                                    icon: Icons.email_outlined,
                                    title: _languageService.getText('email'),
                                    controller: _emailController,
                                  ),
                                  _buildInfoCard(
                                    icon: Icons.phone_outlined,
                                    title: _languageService.getText('telephone'),
                                    controller: _telephoneController,
                                  ),

                                  const SizedBox(height: 32),

                                  // Statistiques
                                  _buildSectionTitle(_languageService.getText('mes_statistiques')),
                                  _buildStatisticsSection(isLandscape),

                                  const SizedBox(height: 32),

                                  // Zone Admin (Visible uniquement pour l'admin)
                                  if (_isAdmin) ...[
                                    _buildSectionTitle('Zone Administrateur'),
                                    _buildActionCard(
                                      icon: Icons.admin_panel_settings_outlined,
                                      title: 'Gérer les Formations',
                                      subtitle: 'Ajouter, modifier ou supprimer',
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFormationsScreen()));
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _buildActionCard(
                                      icon: Icons.signal_cellular_alt,
                                      title: 'Gérer les Signaux',
                                      subtitle: 'Créer, modifier les statuts WIN/LOSS',
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSignalsScreen()));
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _buildActionCard(
                                      icon: Icons.dashboard_customize,
                                      title: 'Dashboard Complet',
                                      subtitle: 'Vue complète signaux + stats + liste',
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    _buildActionCard(
                                      icon: Icons.payments_outlined,
                                      title: 'Valider paiements mining',
                                      subtitle: 'Confirmer ou rejeter les depots manuels',
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMiningTransactionsScreen()));
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Actions
                                  _buildSectionTitle(_languageService.getText('actions')),
                                  _buildActionCard(
                                    icon: Icons.settings_outlined,
                                    title: _languageService.getText('parametres'),
                                    subtitle: _languageService.getText('gerer_preferences'),
                                    onTap: () {},
                                  ),
                                  _buildActionCard(
                                    icon: Icons.memory,
                                    title: 'Machines de mining',
                                    subtitle: 'Acheter et suivre vos machines',
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MiningMachinesScreen()));
                                    },
                                  ),
                                  _buildActionCard(
                                    icon: Icons.help_outline,
                                    title: _languageService.getText('aide_support'),
                                    subtitle: _languageService.getText('centre_aide'),
                                    onTap: () {},
                                  ),
                                  _buildActionCard(
                                    icon: Icons.language_outlined,
                                    title: _languageService.getText('langue'),
                                    subtitle: _languageService.getCurrentLanguageName(),
                                    onTap: _showLanguageDialog,
                                  ),
                                  _buildActionCard(
                                    icon: Icons.info_outline,
                                    title: _languageService.getText('a_propos'),
                                    subtitle: _languageService.getText('version'),
                                    onTap: () {},
                                  ),

                                  const SizedBox(height: 32),

                                  // Boutons d'action finaux
                                  _buildSaveAndLogoutButtons(),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              gradient: AppTheme.goldGradient,
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 46,
                backgroundColor: AppTheme.surfaceColor,
                child: Text(
                  _selectedAvatar,
                  style: const TextStyle(fontSize: 42),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _nomController.text.isEmpty
                ? (FirebaseAuth.instance.currentUser?.displayName ?? '-')
                : _nomController.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.secondaryColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              _languageService.getText('membre_premium').toUpperCase(),
              style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: ProfileAvatars.options.map((avatar) {
              final isSelected = avatar == _selectedAvatar;
              return InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => setState(() => _selectedAvatar = avatar),
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppTheme.secondaryColor.withValues(alpha: 0.22)
                        : AppTheme.surfaceColor,
                    border: Border.all(
                      color: isSelected ? AppTheme.secondaryColor : Colors.white24,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(avatar, style: const TextStyle(fontSize: 20)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(bool isLandscape) {
    if (isLandscape) {
      return Row(
        children: [
          Expanded(child: _buildStatCard(icon: Icons.school_outlined, title: _languageService.getText('formations'), value: '3')),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(icon: Icons.forum_outlined, title: _languageService.getText('messages'), value: '12')),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: _buildStatCard(icon: Icons.school_outlined, title: _languageService.getText('formations'), value: '3')),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(icon: Icons.forum_outlined, title: _languageService.getText('messages'), value: '12')),
        ],
      );
    }
  }

  Widget _buildSaveAndLogoutButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: AppTheme.buttonHeight,
          decoration: BoxDecoration(
            gradient: AppTheme.goldGradient,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            boxShadow: [
              BoxShadow(color: AppTheme.secondaryColor.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: ElevatedButton(
            onPressed: _profile == null ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
            ),
            child: const Text(
              'Enregistrer les modifications',
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: AppTheme.buttonHeight,
          child: OutlinedButton(
            onPressed: () => AuthService.instance.signOut(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadius)),
            ),
            child: Text(
              _languageService.getText('se_deconnecter'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await UserService.instance.updateProfile(uid, {
      'name': _nomController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _telephoneController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'avatar': _selectedAvatar,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil enregistré avec succès')),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondaryColor, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required TextEditingController controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: AppTheme.glassDecoration(borderRadiusVal: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.secondaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor)),
                TextField(
                  controller: controller,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, color: Colors.white30, size: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: AppTheme.glassDecoration(borderRadiusVal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.secondaryColor, size: 32),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondaryColor), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: AppTheme.glassDecoration(borderRadiusVal: 16.0),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.secondaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500), maxLines: 1),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textSecondaryColor, fontSize: 13), maxLines: 1),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondaryColor),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: Text(_languageService.getText('choisir_langue'), style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Français', style: TextStyle(color: Colors.white)),
                trailing: _languageService.isFrench ? const Icon(Icons.check, color: AppTheme.secondaryColor) : null,
                onTap: () {
                  _languageService.changeLanguage('fr');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('English', style: TextStyle(color: Colors.white)),
                trailing: _languageService.isEnglish ? const Icon(Icons.check, color: AppTheme.secondaryColor) : null,
                onTap: () {
                  _languageService.changeLanguage('en');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
