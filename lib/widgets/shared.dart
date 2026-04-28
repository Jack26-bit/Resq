import 'package:flutter/material.dart';
import '../theme/colors.dart';

// ─── News Ticker ────────────────────────────────────────────────────────────
class NewsTicker extends StatefulWidget {
  final String text;
  final Color bg;
  final Color fg;
  const NewsTicker({
    super.key,
    required this.text,
    this.bg = C.surfaceLowest,
    this.fg = C.outline,
  });
  @override
  State<NewsTicker> createState() => _NewsTickerState();
}

class _NewsTickerState extends State<NewsTicker> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 25))..repeat();
    _anim = Tween<double>(begin: 1.0, end: -1.5).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      color: widget.bg,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, child) => FractionalTranslation(
            translation: Offset(_anim.value, 0),
            child: child,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.text,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: widget.fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Top App Bar ─────────────────────────────────────────────────────────────
class ResQAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final VoidCallback? onMenu;
  final double height;

  const ResQAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions,
    this.onMenu,
    this.height = 64,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xB3131313),
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
        boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 20))],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: showBack ? () => Navigator.of(context).pop() : onMenu,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(showBack ? Icons.arrow_back : Icons.menu, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Nav Bar ───────────────────────────────────────────────────────────
class ResQBottomNav extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTap;

  const ResQBottomNav({super.key, required this.activeIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      {'icon': Icons.dashboard_outlined, 'activeIcon': Icons.dashboard, 'label': 'HOME'},
      {'icon': Icons.sos_outlined, 'activeIcon': Icons.sos, 'label': 'SOS'},
      {'icon': Icons.chat_bubble_outline, 'activeIcon': Icons.chat_bubble, 'label': 'MESH'},
      {'icon': Icons.smart_toy_outlined, 'activeIcon': Icons.smart_toy, 'label': 'AI'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xCC0A0A0A),
        border: Border(top: BorderSide(color: Color(0x0DFFFFFF))),
        boxShadow: [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, -10))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = activeIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  child: Container(
                    color: isActive ? C.surfaceHigh : Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? item['activeIcon'] as IconData : item['icon'] as IconData,
                          color: isActive ? Colors.white : const Color(0xFF666666),
                          size: 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: isActive ? Colors.white : const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Hybrid Link Header ─────────────────────────────────────────────────────
class HybridLinkHeader extends StatelessWidget {
  const HybridLinkHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xB3131313),
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
        boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Builder(
                  builder: (ctx) => GestureDetector(
                    onTap: () => Scaffold.of(ctx).openDrawer(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.menu, color: Colors.white, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_tethering, color: Color(0xFF00E5FF), size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'ECHO HYBRID LINK',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 2,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.group, color: Color(0xFF00E5FF), size: 12),
                            SizedBox(width: 4),
                            Text(
                              '14 PEERS NEARBY',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF00E5FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.cloud_done, color: Color(0xFF34C759), size: 16),
                    SizedBox(width: 4),
                    Icon(Icons.signal_cellular_alt, color: Color(0xFF00E5FF), size: 16),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pulse dot ────────────────────────────────────────────────────────────────
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  const PulseDot({super.key, this.color = Colors.white, this.size = 8});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.4 + _ctrl.value * 0.6),
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 3,
          color: C.onSurfaceVar,
        ),
      );
}
