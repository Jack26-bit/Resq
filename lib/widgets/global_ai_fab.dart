import 'package:flutter/material.dart';
import '../theme/colors.dart';

class GlobalAiFabs extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const GlobalAiFabs({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'voice_ai',
            mini: true,
            onPressed: () {
              navigatorKey.currentState?.pushNamed('/voice_agent');
            },
            backgroundColor: const Color(0xFF00E5FF),
            elevation: 12,
            child: const Icon(Icons.mic, color: Colors.black, size: 20),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'gemini_ai',
            onPressed: () {
              navigatorKey.currentState?.pushNamed('/ai_help');
            },
            backgroundColor: C.primary,
            elevation: 12,
            child: const Icon(Icons.smart_toy_rounded, color: C.onPrimary),
          ),
        ],
      ),
    );
  }
}
