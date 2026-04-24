import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'widgets/shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'ECHO',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      darkTheme: buildTheme(),
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (_) => const SignupScreen(),
        '/home': (_) => const AppShell(initialIndex: 0),
        '/map': (_) => const AppShell(initialIndex: 1),
        '/sos': (_) => const AppShell(initialIndex: 2),
        '/community': (_) => const AppShell(initialIndex: 3),
        '/local': (_) => const LocalIncidentsScreen(),
        '/disaster': (_) => const DisasterScreen(),
        '/war': (_) => const WarScreen(),
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
    HomeScreen(),
    LiveMapScreen(),
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
      body: IndexedStack(
        index: _navIndex,
        children: _pages,
      ),
      bottomNavigationBar: ResQBottomNav(
        activeIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}
