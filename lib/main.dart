import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/formations_screen.dart';
import 'screens/my_mining_machines_screen.dart';
import 'screens/forum_screen.dart';
import 'screens/compte_screen.dart';
import 'services/language_service.dart';
import 'screens/registration_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/admin_management_screen.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Register background message handler before runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = LanguageService();
    return ListenableBuilder(
      listenable: languageService,
      builder: (context, child) {
        return MaterialApp(
          title: 'FitCurve App',
          debugShowCheckedModeBanner: false,
          locale: languageService.currentLocale,
          supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        if (snapshot.hasData) {
          return FutureBuilder(
            future: UserService.instance.fetchCurrentUserProfile(),
            builder: (context, profileSnap) {
              if (profileSnap.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }

              if (profileSnap.data == null) {
                return const RegistrationScreen();
              }

              // Initialize notifications once user is confirmed logged in
              WidgetsBinding.instance.addPostFrameCallback((_) {
                NotificationService().initialize(context);
              });

              return FutureBuilder<bool>(
                future: UserService.instance.isCurrentUserAdmin(),
                builder: (context, adminSnap) {
                  if (adminSnap.connectionState == ConnectionState.waiting) {
                    return const LoadingScreen();
                  }
                  if (adminSnap.data == true) {
                    return const AdminManagementScreen();
                  }
                  return const MainScreen();
                },
              );
            },
          );
        }

        return const WelcomeScreen();
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo AureusGold
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: AppTheme.secondaryColor,
                  size: 50,
                ),
                const SizedBox(width: 15),
                Text(
                  'AureusGold',
                  style: AppTheme.welcomeTitleStyle.copyWith(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            // Indicateur de chargement
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.surfaceColor),
              strokeWidth: 3,
            ),
            const SizedBox(height: 30),
            Text(
              'Chargement...',
              style: AppTheme.welcomeSubtitleStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FormationsScreen(),
    const MyMiningMachinesScreen(),
    const ForumScreen(),
    const CompteScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: LanguageService().getText('accueil'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.school),
            label: LanguageService().getText('formations'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.memory),
            label: LanguageService().getText('machines'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.forum),
            label: LanguageService().getText('forum'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: LanguageService().getText('compte'),
          ),
        ],
      ),
    );
  }
}
