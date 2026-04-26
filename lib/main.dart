import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/colors.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/sos_screen.dart';
import 'screens/live_map_screen.dart';
import 'screens/community_screen.dart';
import 'screens/ai_help_screen.dart';
import 'screens/local_incidents_screen.dart';
import 'screens/disaster_screen.dart';
import 'screens/war_screen.dart';
import 'screens/radio_screen.dart';
import 'screens/translate_screen.dart';
import 'widgets/shared.dart';
import 'widgets/app_drawer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'widgets/global_ai_fab.dart';
import 'screens/voice_agent_screen.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: C.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const EchoApp());
}

class EchoApp extends StatelessWidget {
  const EchoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      title: 'ECHO',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      darkTheme: buildTheme(),
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: child,
          floatingActionButton: GlobalAiFabs(navigatorKey: globalNavigatorKey),
        );
      },
      initialRoute: '/',
      routes: {
        '/': (_) => const SignupScreen(),
        '/home': (_) => const AppShell(initialIndex: 2),
        '/map': (_) => const AppShell(initialIndex: 1),
        '/sos': (_) => const AppShell(initialIndex: 3),
        '/ai_help': (_) => const AiHelpScreen(),
        '/community': (_) => const AppShell(initialIndex: 4),
        '/radio': (_) => const AppShell(initialIndex: 0),
        '/local': (_) => const LocalIncidentsScreen(),
        '/disaster': (_) => const DisasterScreen(),
        '/war': (_) => const WarScreen(),
        '/translate': (_) => const TranslateScreen(),
        '/voice_agent': (_) => const VoiceAgentScreen(),
      },
    );
  }
}

// ─── Persistent Shell with IndexedStack ──────────────────────────────────────
class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _navIndex;

  // Screens in the shell — order must match nav items
  static const _pages = [
    RadioScreen(),
    LiveMapScreen(),
    HomeScreen(),
    SosScreen(),
    CommunityScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _navIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const HybridLinkHeader(),
          Expanded(
            child: IndexedStack(
              index: _navIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: ResQBottomNav(
        activeIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}
